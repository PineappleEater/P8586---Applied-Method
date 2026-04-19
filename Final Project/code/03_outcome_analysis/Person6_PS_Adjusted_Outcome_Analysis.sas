/*==============================================================================*/
/* Person 6: PS-Adjusted Outcome Analysis on the Matched Cohort                */
/*                                                                              */
/* What this script does:                                                       */
/* 1. Reads the matched dataset created by Person 5                             */
/* 2. Checks whether the matched pairs look correct                             */
/* 3. Computes event rates for DIED and med_comp by treatment group             */
/* 4. Runs conditional logistic regression using matchto as the matched stratum */
/* 5. Adds a matched-pair sensitivity analysis based on discordant pairs        */
/* 6. Creates paper-ready summary tables, forest-plot data, and CSV exports     */
/*                                                                              */
/* NOTE: Update PROJECT_DIR only if this folder is moved.                       */
/*==============================================================================*/

options nodate nonumber;
ods graphics on;

%let PROJECT_DIR = D:\OneDrive\Desktop\Academic\Biostats Courses\P8586---Applied-Method\Final Project;
%let MATCHED_DATA = matches;
%let TREAT_VAR    = colectomy_open;   /* 1 = open, 0 = laparoscopic */
%let PAIR_VAR     = matchto;

libname proj "&PROJECT_DIR.";


/*==============================================================================*/
/* STEP 0: Quick dataset check                                                  */
/*==============================================================================*/

title "Matched Dataset Variables";
proc contents data=proj.&MATCHED_DATA. varnum;
run;
title;

proc sql;
    create table work.match_qc as
    select &PAIR_VAR.,
           count(*) as n_in_pair,
           sum(case when &TREAT_VAR. = 1 then 1 else 0 end) as n_open,
           sum(case when &TREAT_VAR. = 0 then 1 else 0 end) as n_lap
    from proj.&MATCHED_DATA.
    group by &PAIR_VAR.;
quit;

title "QC: Matched Pair Structure";
proc freq data=work.match_qc;
    tables n_in_pair n_open n_lap / missing;
run;
title;


/*==============================================================================*/
/* Reusable macro for each matched-cohort outcome                               */
/*==============================================================================*/

%macro matched_outcome(outcome=, outcome_label=);

/*----------------------------------------*/
/* A. Prepare outcome-specific dataset    */
/*----------------------------------------*/
data work.analysis_&outcome.;
    set proj.&MATCHED_DATA.;
    where not missing(&PAIR_VAR.)
      and not missing(&TREAT_VAR.)
      and not missing(&outcome.);
run;

proc sort data=work.analysis_&outcome.;
    by &PAIR_VAR.;
run;


/*----------------------------------------*/
/* B. Event rates by treatment arm        */
/*----------------------------------------*/
proc sql;
    create table work.event_rates_&outcome. as
    select "&outcome_label." as Outcome length=60,
           &TREAT_VAR. as colectomy_open,
           count(*) as N,
           sum(case when &outcome. = 1 then 1 else 0 end) as Events,
           calculated Events / calculated N as Risk format=percent8.2
    from work.analysis_&outcome.
    group by &TREAT_VAR.;
quit;

data work.event_rates_fmt_&outcome.;
    set work.event_rates_&outcome.;
    length Treatment $20 EventSummary $30;
    Treatment = ifc(colectomy_open = 1, "Open", "Laparoscopic");
    EventSummary = cats(put(Events, comma8.), "/", put(N, comma8.),
                        " (", put(Risk, percent8.2), ")");
    keep Outcome Treatment EventSummary;
run;

proc sort data=work.event_rates_fmt_&outcome.;
    by Outcome;
run;

proc transpose data=work.event_rates_fmt_&outcome.
               out=work.event_rates_wide_&outcome.(drop=_name_);
    by Outcome;
    id Treatment;
    var EventSummary;
run;

title "&outcome_label.: Event Rates by Treatment Group";
proc print data=work.event_rates_&outcome. noobs label;
    var Outcome colectomy_open N Events Risk;
    label colectomy_open = "Treatment (1=Open, 0=Laparoscopic)";
run;
title;


/*----------------------------------------*/
/* C. Pair-level outcome layout           */
/*----------------------------------------*/
data work.pairs_&outcome.(keep=&PAIR_VAR. open_outcome lap_outcome);
    retain open_outcome lap_outcome;
    set work.analysis_&outcome.;
    by &PAIR_VAR.;

    if first.&PAIR_VAR. then call missing(open_outcome, lap_outcome);

    if &TREAT_VAR. = 1 then open_outcome = &outcome.;
    else if &TREAT_VAR. = 0 then lap_outcome = &outcome.;

    if last.&PAIR_VAR. then output;
run;

proc sql;
    create table work.pair_pattern_&outcome. as
    select "&outcome_label." as Outcome length=60,
           sum(case when open_outcome = 1 and lap_outcome = 1 then 1 else 0 end) as Both_Event,
           sum(case when open_outcome = 0 and lap_outcome = 0 then 1 else 0 end) as Neither_Event,
           sum(case when open_outcome = 1 and lap_outcome = 0 then 1 else 0 end) as Open_Only_Event,
           sum(case when open_outcome = 0 and lap_outcome = 1 then 1 else 0 end) as Lap_Only_Event
    from work.pairs_&outcome.;
quit;

title "&outcome_label.: Pair-Level Event Pattern";
proc print data=work.pair_pattern_&outcome. noobs;
run;
title;


/*----------------------------------------*/
/* D. Primary analysis: conditional logit */
/*----------------------------------------*/
ods exclude all;
ods output ParameterEstimates=work.clogit_pe_&outcome.;

proc logistic data=work.analysis_&outcome.;
    strata &PAIR_VAR.;
    model &outcome.(event='1') = &TREAT_VAR. / clodds=wald;
run;

ods exclude none;

data work.clogit_result_&outcome.;
    length Outcome $60 Method $40 Effect $30;
    set work.clogit_pe_&outcome.;
    where Variable = "&TREAT_VAR.";

    Outcome = "&outcome_label.";
    Method  = "Conditional logistic";
    Effect  = "Open vs laparoscopic";
    OR      = exp(Estimate);
    LowerCL = exp(Estimate - 1.96 * StdErr);
    UpperCL = exp(Estimate + 1.96 * StdErr);
    PValue  = ProbChiSq;

    keep Outcome Method Effect Estimate StdErr OR LowerCL UpperCL PValue;
    format OR LowerCL UpperCL 8.3 PValue pvalue6.4;
run;


/*----------------------------------------*/
/* E. Sensitivity: matched-pair OR        */
/*    Uses discordant pairs only          */
/*----------------------------------------*/
proc sql noprint;
    select sum(case when open_outcome = 1 and lap_outcome = 0 then 1 else 0 end),
           sum(case when open_outcome = 0 and lap_outcome = 1 then 1 else 0 end)
      into :discordant_open_&outcome.,
           :discordant_lap_&outcome.
    from work.pairs_&outcome.;
quit;

data work.matchedpair_result_&outcome.;
    length Outcome $60 Method $40 Effect $30;

    Outcome = "&outcome_label.";
    Method  = "Matched-pair OR";
    Effect  = "Open vs laparoscopic";

    Discordant_OpenOnly = input(symget("discordant_open_&outcome."), best12.);
    Discordant_LapOnly  = input(symget("discordant_lap_&outcome."), best12.);

    if Discordant_OpenOnly > 0 and Discordant_LapOnly > 0 then do;
        Estimate = log(Discordant_OpenOnly / Discordant_LapOnly);
        StdErr   = sqrt((1 / Discordant_OpenOnly) + (1 / Discordant_LapOnly));
        OR       = exp(Estimate);
        LowerCL  = exp(Estimate - 1.96 * StdErr);
        UpperCL  = exp(Estimate + 1.96 * StdErr);
        ZValue   = Estimate / StdErr;
        PValue   = 2 * (1 - probnorm(abs(ZValue)));
    end;
    else do;
        call missing(Estimate, StdErr, OR, LowerCL, UpperCL, ZValue, PValue);
    end;

    keep Outcome Method Effect Discordant_OpenOnly Discordant_LapOnly
         Estimate StdErr OR LowerCL UpperCL PValue;
    format OR LowerCL UpperCL 8.3 PValue pvalue6.4;
run;


/*----------------------------------------*/
/* F. Outcome-specific summary table      */
/*----------------------------------------*/
data work.results_&outcome.;
    set work.clogit_result_&outcome.
        work.matchedpair_result_&outcome.;
run;

proc sort data=work.results_&outcome.;
    by Outcome;
run;

data work.summary_&outcome.;
    merge work.results_&outcome.(in=a)
          work.event_rates_wide_&outcome.;
    by Outcome;
    if a;

    length OR_95CI $40;
    OR_95CI = cats(put(OR, 6.3), " (",
                    put(LowerCL, 6.3), ", ",
                    put(UpperCL, 6.3), ")");
run;

title "&outcome_label.: Paper-Ready Summary";
proc print data=work.summary_&outcome. noobs label;
    var Outcome Method Open Laparoscopic OR_95CI PValue;
    label Open         = "Open events / N (%)"
          Laparoscopic = "Laparoscopic events / N (%)"
          OR_95CI      = "OR (95% CI)";
run;
title;

%mend matched_outcome;


/*==============================================================================*/
/* Run both Person 6 outcomes                                                   */
/*==============================================================================*/

%matched_outcome(
    outcome=DIED,
    outcome_label=%str(In-hospital mortality (DIED))
);

%matched_outcome(
    outcome=med_comp,
    outcome_label=%str(Medical complications (med_comp))
);


/*==============================================================================*/
/* Combine outputs across outcomes                                              */
/*==============================================================================*/

data proj.person6_event_rates;
    set work.event_rates_DIED
        work.event_rates_med_comp;
run;

data proj.person6_pair_patterns;
    set work.pair_pattern_DIED
        work.pair_pattern_med_comp;
run;

data proj.person6_ps_outcome_results;
    set work.clogit_result_DIED
        work.matchedpair_result_DIED
        work.clogit_result_med_comp
        work.matchedpair_result_med_comp;
run;

data proj.person6_paper_summary;
    set work.summary_DIED
        work.summary_med_comp;
run;


/*==============================================================================*/
/* Forest plot data                                                             */
/*==============================================================================*/

data proj.person6_forest_plot_data;
    set proj.person6_ps_outcome_results;
    length RowLabel $100 OR_95CI $40;

    if Outcome = "In-hospital mortality (DIED)" then OutcomeOrder = 1;
    else if Outcome = "Medical complications (med_comp)" then OutcomeOrder = 2;

    if Method = "Conditional logistic" then MethodOrder = 1;
    else if Method = "Matched-pair OR" then MethodOrder = 2;

    RowLabel = catx(" - ", Outcome, Method);
    OR_95CI  = cats(put(OR, 6.3), " (",
                    put(LowerCL, 6.3), ", ",
                    put(UpperCL, 6.3), ")");
run;

proc sort data=proj.person6_forest_plot_data;
    by OutcomeOrder MethodOrder;
run;

title "Forest Plot Source Data";
proc print data=proj.person6_forest_plot_data noobs;
    var Outcome Method OR LowerCL UpperCL PValue;
run;
title;

title "PS-Adjusted Outcome Analysis: Forest Plot";
proc sgplot data=proj.person6_forest_plot_data;
    scatter y=RowLabel x=OR /
            xerrorlower=LowerCL
            xerrorupper=UpperCL
            markerattrs=(symbol=squarefilled size=10);
    refline 1 / axis=x lineattrs=(pattern=shortdash thickness=1);
    xaxis type=log min=0.25 max=8
          label="Odds Ratio (Open vs Laparoscopic)";
    yaxis discreteorder=data reverse label="";
run;
title;


/*==============================================================================*/
/* Optional CSV exports for paper / slides                                      */
/*==============================================================================*/

proc export data=proj.person6_event_rates
    outfile="&PROJECT_DIR.\person6_event_rates.csv"
    dbms=csv replace;
run;

proc export data=proj.person6_pair_patterns
    outfile="&PROJECT_DIR.\person6_pair_patterns.csv"
    dbms=csv replace;
run;

proc export data=proj.person6_ps_outcome_results
    outfile="&PROJECT_DIR.\person6_ps_outcome_results.csv"
    dbms=csv replace;
run;

proc export data=proj.person6_paper_summary
    outfile="&PROJECT_DIR.\person6_paper_summary.csv"
    dbms=csv replace;
run;

proc export data=proj.person6_forest_plot_data
    outfile="&PROJECT_DIR.\person6_forest_plot_data.csv"
    dbms=csv replace;
run;


/*==============================================================================*/
/* Final display                                                                */
/*==============================================================================*/

title "Final Person 6 Summary Table";
proc print data=proj.person6_paper_summary noobs label;
    var Outcome Method Open Laparoscopic OR_95CI PValue;
    label Open         = "Open events / N (%)"
          Laparoscopic = "Laparoscopic events / N (%)"
          OR_95CI      = "OR (95% CI)";
run;
title;
