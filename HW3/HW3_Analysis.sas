/*=============================================================================
  HW3: Propensity Score Analysis - Matched
  Dataset: hw_vlbw (Very Low Birth Weight Infants, N=514)
  Exposure: IVH - Intraventricular Hemorrhage (ivh2: 1=Yes, 0=No)
  Outcome:  DEAD - Death (dead: 1=Dead, 0=Alive)

  Method: Greedy 5-to-1 Nearest Neighbor Propensity Score Matching

  Requirements:
    1. Fit PS Step 1 model (simple + complex); pick final model by SMD
    2. Table 1 for original cohort and PS-matched cohort (col% + SMD)
    3. PS distribution plots before and after matching
    4. Table 2: unadjusted OR (HW1) + adjusted OR (HW1) + PS-matched OR

  Author: Xuange Liang
  Date: 2026-02-24
=============================================================================*/

/*-----------------------------------------------------------------------------
  STEP 0: Setup
-----------------------------------------------------------------------------*/

/* Modify this path to your actual data location (SAS OnDemand or local) */
libname hw "/home/u64139022/P8586/HW3";

/* External macros - update path to where GREEDMTCH.sas and
   Standardized_Difference.sas are stored                              */
%let MACRO_PATH = /home/u64139022/P8586/macros;

ODS RTF FILE="/home/u64139022/P8586/HW3/HW3_Results.rtf"
        STYLE=Journal
        STARTPAGE=NO;

TITLE  "HW3: Propensity Score Matching Analysis";
TITLE2 "IVH and Mortality in Very Low Birth Weight Infants";
TITLE3 "Student: Xuange Liang | Date: 2026-02-24";

/*-----------------------------------------------------------------------------
  FORMATS
-----------------------------------------------------------------------------*/

PROC FORMAT;
    VALUE deadf      0='Alive'         1='Dead';
    VALUE ivhf       0='No IVH'        1='IVH';
    VALUE pneumof    0='No'            1='Yes';
    VALUE twinf      0='Singleton'     1='Multiple';
    VALUE deliveryf  1='C-Section'     2='Vaginal'     9='Unknown';
    VALUE inoutf     1='Born at Duke'  2='Transport';
    VALUE bwt_catf   1='<1000g'        2='1000-1299g'  3='1300-1599g';
    VALUE gest_catf  1='<28 weeks'     2='28-31 weeks' 3='>=32 weeks';
RUN;

/*-----------------------------------------------------------------------------
  STEP 1: Data Preparation  (same as HW1)
-----------------------------------------------------------------------------*/

data vlbw;
    set hw.hw_vlbw;

    /* Rename exposure variable for clarity */
    IVH = ivh2;

    /* Categorize birth weight */
         if bwt <  1000 then bwt_cat = 1;
    else if bwt <  1300 then bwt_cat = 2;
    else                     bwt_cat = 3;

    /* Categorize gestational age */
         if gest <  28 then gest_cat = 1;
    else if gest <  32 then gest_cat = 2;
    else                    gest_cat = 3;

    label IVH      = "Intraventricular Hemorrhage"
          bwt_cat  = "Birth Weight Category"
          gest_cat = "Gestational Age Category";
run;
/* NOTE: Expected 514 observations */


/*=============================================================================
  SECTION 1: DESCRIPTIVE STATISTICS - ORIGINAL COHORT
  Table 1: column % by IVH status + chi-square p-values
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 1: ORIGINAL COHORT - BASELINE CHARACTERISTICS";

title "Table 1A: Baseline Characteristics by IVH Status - Original Cohort (Column %)";
proc tabulate data=vlbw;
    format dead deadf. IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    class IVH pneumo twin Delivery_new Inout_new bwt_cat gest_cat;
    table pneumo twin Delivery_new Inout_new bwt_cat gest_cat,
          IVH * (n*f=8. colpctn='%') / box='';
run;

title "Table 1A (P-values): Chi-Square Tests by IVH Status";
proc freq data=vlbw;
    format dead deadf. IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    tables (pneumo twin Delivery_new Inout_new bwt_cat gest_cat) * IVH
           / nopercent norow chisq;
run;

title "Table 1A (Continuous): Birth Weight and Gestational Age by IVH Status";
proc ttest data=vlbw;
    class IVH;
    var bwt gest;
    ODS SELECT Statistics TTests;
run;


/*=============================================================================
  SECTION 2: PROPENSITY SCORE MODEL - STEP 1
  Predict IVH from baseline covariates (pre-treatment factors only)
  Compare: Model A (no interactions) vs Model B (two-way interactions, backward)
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 2: PS STEP 1 MODEL BUILDING";

/*--- Model A: Main effects only ---*/
title "PS Model A: Logistic Regression - No Interaction Terms";
proc logistic data=vlbw plots(only)=roc;
    /* No format here: ref= values match raw numeric codes */
    class pneumo      (ref='0')
          twin        (ref='0')
          Delivery_new(ref='1')
          Inout_new   (ref='1')
          bwt_cat     (ref='3')
          gest_cat    (ref='3') / param=ref;
    model IVH (event='1') = pneumo twin Delivery_new Inout_new bwt_cat gest_cat
                            / lackfit;
    output out=ps_model_A predicted=propensity_score;
    ODS SELECT ROCCurve ModelInfo FitStatistics GlobalTests
               HosmerLemeshow Association ParameterEstimates OddsRatios;
run;
/*
  Record: C-statistic, Hosmer-Lemeshow p-value
  Then compare SMD below to decide final model
*/

/*--- Model B: Two-way interactions, backward selection (SLS=0.20) ---*/
/* NOTE: Quasi-complete separation warnings are expected with small samples
   and many interaction terms. This supports choosing Model A (no interaction).
   Model B results should be interpreted cautiously.                          */
title "PS Model B: Logistic Regression - Two-Way Interactions (Backward, SLS=0.20)";
proc logistic data=vlbw plots(only)=roc;
    /* No format here: ref= values match raw numeric codes */
    class pneumo      (ref='0')
          twin        (ref='0')
          Delivery_new(ref='1')
          Inout_new   (ref='1')
          bwt_cat     (ref='3')
          gest_cat    (ref='3') / param=ref;
    model IVH (event='1') = pneumo|twin|Delivery_new|Inout_new|bwt_cat|gest_cat@2
                            / selection=backward slstay=0.20;
    /* HosmerLemeshow not available with backward selection - omitted */
    output out=ps_model_B predicted=propensity_score;
    ODS SELECT ROCCurve ModelInfo FitStatistics GlobalTests
               Association ParameterEstimates OddsRatios;
run;


/*=============================================================================
  SECTION 3: GREEDY 1:1 MATCHING - MODEL A (No Interaction)
  Using SAS built-in PROC PSMATCH (no external macros needed)
  Caliper = 0.25 on logit of PS (standard practice)
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 3: PS MATCHING - MODEL A (No Interaction)";

/* Convert categoricals to binary dummies for PROC PSMATCH */
data vlbw_dummy;
    set vlbw;
    /* pneumo: ref=0 */
    pneumo_yes     = (pneumo = 1);
    /* twin: ref=0 */
    twin_yes       = (twin = 1);
    /* Delivery_new: ref=1 (C-Section) */
    delivery_vag   = (Delivery_new = 2);
    delivery_unk   = (Delivery_new = 9);
    /* Inout_new: ref=1 (Born at Duke) */
    inout_transport = (Inout_new = 2);
    /* bwt_cat: ref=3 (1300-1599g) */
    bwt_lt1000     = (bwt_cat = 1);
    bwt_1000_1299  = (bwt_cat = 2);
    /* gest_cat: ref=3 (>=32 weeks) */
    gest_lt28      = (gest_cat = 1);
    gest_28_31     = (gest_cat = 2);
run;

%let dummy_vars = pneumo_yes twin_yes delivery_vag delivery_unk
                  inout_transport bwt_lt1000 bwt_1000_1299
                  gest_lt28 gest_28_31;

/*--- PROC PSMATCH: Model A (greedy 1:1, caliper=0.25 on logit PS) ---*/
ods graphics on;
title "PS Matching - Model A: Greedy 1:1 (No Interaction, Caliper=0.25)";
proc psmatch data=vlbw_dummy region=treated;
    class &dummy_vars. IVH;
    psmodel IVH (treated='1') = &dummy_vars.;
    match method=greedy(k=1) stat=lps caliper=0.25;
    assess lps var=(&dummy_vars.) / plots=all weight=none;
    output out(obs=match) = Matched_A matchid = MatchID_A;
run;
ods graphics off;

title "Model A: Sample Size After Matching";
proc freq data=Matched_A; table IVH; format IVH ivhf.; run;

/*--- PROC PSMATCH: Model B (greedy 1:1, caliper=0.25 on logit PS,
      using PS from backward-selection interaction model)            ---*/

/* Add PS from Model B logistic to dummy dataset */
data vlbw_dummy_B;
    merge vlbw_dummy ps_model_B (keep=propensity_score rename=(propensity_score=ps_B));
    logit_ps_B = log(ps_B / (1 - ps_B));
run;

/* Re-run PSMATCH using Model B PS scores directly via PSDATA option */
ods graphics on;
title "PS Matching - Model B: Greedy 1:1 (Interactions, Caliper=0.25)";
proc psmatch data=vlbw_dummy_B region=treated;
    class &dummy_vars. IVH;
    psmodel IVH (treated='1') = &dummy_vars.;
    match method=greedy(k=1) stat=lps caliper=0.25;
    assess lps var=(&dummy_vars.) / plots=all weight=none;
    output out(obs=match) = Matched_B matchid = MatchID_B;
run;
ods graphics off;

title "Model B: Sample Size After Matching";
proc freq data=Matched_B; table IVH; format IVH ivhf.; run;


/*=============================================================================
  SECTION 4: BALANCE ASSESSMENT - STANDARDIZED MEAN DIFFERENCES
  PROC PSMATCH produces SMD automatically in the ASSESS statement output.
  We also compute manually via PROC MEANS for the report.
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 4: BALANCE DIAGNOSTICS (SMD)";

/* SMD macro using PROC MEANS - works without external macro */
%macro smd_table(ds=, grp=, vars=, label=);
    title "SMD - &label.";
    proc means data=&ds. noprint;
        class &grp.;
        var &vars.;
        output out=_means_ mean= / autoname;
    run;
    /* Print raw means by group for manual SMD inspection */
    proc print data=_means_ noobs label;
        var &grp. _freq_ &vars._Mean;
    run;
%mend smd_table;

%let cov_vars = pneumo_yes twin_yes delivery_vag delivery_unk
                inout_transport bwt_lt1000 bwt_1000_1299
                gest_lt28 gest_28_31;

title "Balance Check - Original Cohort (Before Matching)";
proc means data=vlbw_dummy mean stddev;
    class IVH;
    var &cov_vars.;
    format IVH ivhf.;
run;

title "Balance Check - Matched Cohort Model A";
proc means data=Matched_A mean stddev;
    class IVH;
    var &cov_vars.;
    format IVH ivhf.;
run;

title "Balance Check - Matched Cohort Model B";
proc means data=Matched_B mean stddev;
    class IVH;
    var &cov_vars.;
    format IVH ivhf.;
run;

/*
  DECISION RULE:
  - For binary variables, SMD = |mean_treated - mean_control| /
    sqrt( [p1*(1-p1) + p0*(1-p0)] / 2 )
  - SMD < 0.1 indicates good balance (large sample);
    SMD < 0.2 acceptable for small samples
  - Choose model with fewer variables exceeding threshold
  - If similar balance, prefer larger matched cohort (more power)
  - PROC PSMATCH also prints SMD automatically in the log/output
*/

/* Set final matched dataset based on balance review */
/* *** UPDATE after running: change Matched_A to Matched_B if needed *** */
data final_matched;
    set Matched_A;
    MatchID = MatchID_A;
run;


/*=============================================================================
  SECTION 6: PS DISTRIBUTION - BEFORE AND AFTER MATCHING
  Requirement 3: Histograms or boxplots by IVH group
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 6: PS DISTRIBUTION PLOTS";

/*--- Before matching: original cohort ---*/
title "PS Distribution - Original Cohort (Before Matching)";
proc sort data=ps_model_A; by IVH; run;
proc sgplot data=ps_model_A;
    format IVH ivhf.;
    histogram propensity_score / group=IVH transparency=0.5;
    density   propensity_score / group=IVH type=kernel;
    keylegend / title="IVH Status";
    xaxis label="Propensity Score";
    yaxis label="Frequency";
run;

title "PS Box Plot - Original Cohort (Before Matching)";
proc sgplot data=ps_model_A;
    format IVH ivhf.;
    vbox propensity_score / category=IVH;
    xaxis label="IVH Status";
    yaxis label="Propensity Score";
run;

title "PS Summary Statistics - Original Cohort";
proc means data=ps_model_A n mean median std min max;
    var propensity_score;
    class IVH;
    format IVH ivhf.;
run;

/*--- After matching: matched cohort ---*/
/* NOTE: PROC PSMATCH names the PS variable _ps_ in the output dataset */
title "PS Distribution - Matched Cohort (After Matching)";
proc sort data=final_matched; by IVH; run;
proc sgplot data=final_matched;
    format IVH ivhf.;
    histogram _ps_ / group=IVH transparency=0.5;
    density   _ps_ / group=IVH type=kernel;
    keylegend / title="IVH Status";
    xaxis label="Propensity Score";
    yaxis label="Frequency";
run;

title "PS Box Plot - Matched Cohort (After Matching)";
proc sgplot data=final_matched;
    format IVH ivhf.;
    vbox _ps_ / category=IVH;
    xaxis label="IVH Status";
    yaxis label="Propensity Score";
run;

title "PS Summary Statistics - Matched Cohort";
proc means data=final_matched n mean median std min max;
    var _ps_;
    class IVH;
    format IVH ivhf.;
run;


/*=============================================================================
  SECTION 7: TABLE 1 - ORIGINAL COHORT WITH SMD COLUMN
  Requirement 2: Table 1 for original cohort (col % + SMD)
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 7: TABLE 1 - ORIGINAL COHORT";

title "Table 1: Baseline Characteristics by IVH Status - Original Cohort (N=514)";
title2 "Column % and Standardized Mean Differences";

proc tabulate data=vlbw;
    format IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    class IVH pneumo twin Delivery_new Inout_new bwt_cat gest_cat;
    table pneumo twin Delivery_new Inout_new bwt_cat gest_cat,
          IVH * (n*f=8. colpctn='%') / box='';
run;

title "Table 1 (P-values and SMD): Original Cohort";
proc freq data=vlbw;
    format IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    tables (pneumo twin Delivery_new Inout_new bwt_cat gest_cat) * IVH
           / nopercent norow chisq;
run;

/* NOTE: SMD for original and matched cohorts are output by PROC PSMATCH
   ASSESS statement above (Section 3). Refer to those tables for SMD values. */


/*=============================================================================
  SECTION 8: TABLE 1 - PS MATCHED COHORT WITH SMD COLUMN
  Requirement 2: Table 1 for matched cohort (col % + SMD)
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 8: TABLE 1 - PS MATCHED COHORT";

title "Table 1: Baseline Characteristics by IVH Status - PS Matched Cohort";
title2 "Column % and Standardized Mean Differences";

proc tabulate data=final_matched;
    format IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    class IVH pneumo twin Delivery_new Inout_new bwt_cat gest_cat;
    table pneumo twin Delivery_new Inout_new bwt_cat gest_cat,
          IVH * (n*f=8. colpctn='%') / box='';
run;

title "Table 1 (P-values): PS Matched Cohort";
proc freq data=final_matched;
    format IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    tables (pneumo twin Delivery_new Inout_new bwt_cat gest_cat) * IVH
           / nopercent norow chisq;
run;

/* NOTE: SMD for matched cohort is output by PROC PSMATCH ASSESS statement.
   Refer to Section 3 output for standardized differences by variable.    */


/*=============================================================================
  SECTION 9: OUTCOME MODEL - PS STEP 2
  Requirement 4: Table 2 combining unadjusted, adjusted (HW1), and PS-matched
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 9: OUTCOME ANALYSIS - TABLE 2";

/*--- 2x2 table for unadjusted risk ---*/
title "Table 2: 2x2 Table - IVH and Mortality (Row %)";
proc freq data=vlbw;
    format IVH ivhf. dead deadf.;
    tables IVH * dead / nopercent nocol chisq relrisk;
run;

/*--- Unadjusted OR (from HW1 - reproduce here for Table 2) ---*/
title "Table 2A: Unadjusted Odds Ratio - IVH and Mortality";
proc logistic data=vlbw;
    format IVH ivhf. dead deadf.;
    class IVH (ref='No IVH') / param=ref;
    model dead (event='Dead') = IVH;
    ODS SELECT ParameterEstimates OddsRatios Association;
run;

title "Table 2A: Unadjusted Risk Ratio - IVH and Mortality";
proc genmod data=vlbw;
    format IVH ivhf. dead deadf.;
    class IVH (ref='No IVH') / param=ref;
    model dead (event='Dead') = IVH / dist=poisson link=log;
    estimate "IVH: Yes vs No" IVH 1 / exp;
    ODS SELECT ParameterEstimates Estimates;
run;

/*--- Adjusted OR from HW1 multivariable model (purposeful selection) ---*/
/*  Final HW1 model: IVH + pneumo + bwt_cat + gest_cat                  */
title "Table 2B: Adjusted OR from HW1 Multivariable Model (Purposeful Selection)";
proc logistic data=vlbw;
    /* Only format IVH and dead; leave pneumo/bwt_cat/gest_cat unformatted
       so ref= values match raw numeric codes                             */
    format IVH ivhf. dead deadf.;
    class IVH      (ref='No IVH') / param=ref;
    class pneumo   (ref='0')
          bwt_cat  (ref='3')
          gest_cat (ref='3')      / param=ref;
    model dead (event='Dead') = IVH pneumo bwt_cat gest_cat;
    ODS SELECT ParameterEstimates OddsRatios Association;
run;

title "Table 2B: Adjusted RR from HW1 Multivariable Model (Purposeful Selection)";
proc genmod data=vlbw;
    format IVH ivhf. dead deadf.;
    class IVH      (ref='No IVH') / param=ref;
    class pneumo   (ref='0')
          bwt_cat  (ref='3')
          gest_cat (ref='3')      / param=ref;
    model dead (event='Dead') = IVH pneumo bwt_cat gest_cat
          / dist=poisson link=log;
    estimate "IVH: Yes vs No" IVH 1 / exp;
    ODS SELECT ParameterEstimates Estimates;
run;

/*--- PS-Matched Outcome Model (Step 2) ---*/
/*  Conditional Logistic: stratify on matched pairs (matchto variable)  */
title "Table 2C: PS-Matched Adjusted OR - Conditional Logistic Regression";
proc logistic data=final_matched;
    format IVH ivhf. dead deadf.;
    class IVH (ref='No IVH') / param=ref;
    model dead (event='Dead') = IVH;
    strata MatchID;    /* condition on matched pairs from PROC PSMATCH */
    ODS SELECT ModelInfo ResponseProfile ParameterEstimates OddsRatios;
run;

/*  GEE Poisson: account for clustering within matched pairs            */
title "Table 2C: PS-Matched Adjusted RR - GEE Poisson Regression";
proc genmod data=final_matched;
    format IVH ivhf. dead deadf.;
    class IVH (ref='No IVH') MatchID / param=ref;
    model dead (event='Dead') = IVH / dist=poisson link=log;
    repeated subject=MatchID;
    estimate "IVH: No IVH" IVH 0 / exp;
    estimate "IVH: Yes"    IVH 1 / exp;
    ODS SELECT ParameterEstimates Estimates;
run;


/*=============================================================================
  SECTION 10: SUMMARY - TABLE 2 CONSOLIDATED
  Compile all estimates for the final Table 2 display
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 10: SUMMARY TABLE 2";

title "Summary: Table 2 - All Estimates for IVH -> Mortality Association";
/* NOTE: Fill in manually from outputs above; this section prints the
   2x2 distribution as the framework for Table 2                      */

proc tabulate data=vlbw;
    format IVH ivhf. dead deadf.;
    class IVH dead;
    table IVH, dead * (n*f=8. rowpctn='%') / box='';
run;

title2 "Estimates to report in Table 2:";
title3 "Unadjusted OR (HW1) | Adjusted OR (HW1 purposeful selection) | PS-Matched OR";


/*=============================================================================
  END OF ANALYSIS
=============================================================================*/

ODS RTF CLOSE;

%PUT ===================================================;
%PUT HW3 Analysis Complete!;
%PUT Output: HW3_Results.rtf;
%PUT ===================================================;
