/*==============================================================================*/
/*  Person 5: Propensity Score Estimation & Greedy 5->1 Digit Matching          */
/*==============================================================================*/

/* ---- Library Setup ---- */
libname a "/home/u64139368/sasuser.v94/Applied Method/project";
%include "/home/u64139368/sasuser.v94/Applied Method/project/GREEDMTCH.sas";
%include "/home/u64139368/sasuser.v94/Applied Method/project/Standardized_Difference.sas";


/*==============================================================================*/
/* STEP 1: Estimate the Propensity Score                                        */
/*==============================================================================*/
/* PS = Pr(colectomy_open = 1 | baseline covariates).                           */
/* Covariates chosen per Person 1's clean dataset. AGE kept continuous          */
/* in the PS model; AGE_CAT is evaluated for balance (not re-entered here).     */

proc logistic data=a.proj1_clean descending;
    class PAYER ZIPINC_QRTL PATIENT_LOC
          HOSP_BEDSIZE H_CONTRL HOSP_LOCATION HOSP_TEACH HOSP_REGION YEAR
          / param=ref ref=first;
    model colectomy_open = AGE PAYER ZIPINC_QRTL PATIENT_LOC
                           HOSP_BEDSIZE H_CONTRL HOSP_LOCATION HOSP_TEACH
                           HOSP_REGION YEAR
                           / rsquare lackfit;
    output out=a.propen prob=prob xbeta=logit_ps;
    title "Step 1: PS Model - Logistic Regression for colectomy_open";
run;
title;

/* Quick distribution check of PS by group */
proc means data=a.propen n mean std min q1 median q3 max maxdec=4;
    class colectomy_open;
    var prob logit_ps;
    title "Step 1b: PS Distribution by Treatment Group (Pre-Match)";
run;
title;


/*==============================================================================*/
/* STEP 2: Pre-Match PS Distribution Plot (Common Support Check)                */
/*==============================================================================*/

proc sgplot data=a.propen;
    density prob / group=colectomy_open type=kernel;
    xaxis label="Propensity Score (Pr open colectomy)" min=0 max=1;
    yaxis label="Density";
    keylegend / title="Treatment";
    title "Step 2: Pre-Match PS Distribution by Treatment Group";
run;
title;


/*==============================================================================*/
/* STEP 3: Greedy 5->1 Digit Matching (1:1 without replacement)                 */
/*==============================================================================*/
/* Macro signature: %GREEDMTCH(Lib, Dataset, depend, matches);                  */
/*   Lib     = permanent library                                                */
/*   Dataset = input dataset containing variable 'prob'                         */
/*   depend  = 0/1 treatment indicator (1 = case, 0 = control)                  */
/*   matches = name of output matched-pair dataset                              */
/*                                                                              */
/* Macro was edited to use HOSP_NIS + KEY_NIS as the patient identifiers.       */

%GREEDMTCH(a, propen, colectomy_open, matches);

/* Quick matched-cohort size check */
proc freq data=a.matches;
    tables colectomy_open;
    title "Step 3: Matched Cohort - Treatment Distribution (should be 1:1)";
run;
title;

proc sql;
    select count(distinct matchto) as n_pairs
    from a.matches;
    title "Step 3b: Number of matched pairs";
quit;
title;


/*==============================================================================*/
/* STEP 4: Post-Match Balance Assessment                                        */
/*==============================================================================*/
/* Same variable list as Person 1's pre-match %stddiff call for direct compare. */

%stddiff(inds     = a.matches,
         groupvar = colectomy_open,
         numvars  = AGE,
         charvars = AGE_CAT PAYER ZIPINC_QRTL PATIENT_LOC
                    HOSP_BEDSIZE H_CONTRL HOSP_LOCATION HOSP_TEACH
                    HOSP_REGION YEAR,
         stdfmt   = 8.4,
         outds    = a.stddiff_postmatch);

proc print data=a.stddiff_postmatch;
    title "Step 4: Standardized Differences (Post-Match)";
run;
title;


/*==============================================================================*/
/* STEP 5: Post-Match PS Distribution Plot                                      */
/*==============================================================================*/

proc sgplot data=a.matches;
    density prob / group=colectomy_open type=kernel;
    xaxis label="Propensity Score (Pr open colectomy)" min=0 max=1;
    yaxis label="Density";
    keylegend / title="Treatment";
    title "Step 5: Post-Match PS Distribution by Treatment Group";
run;
title;


/*==============================================================================*/
/* STEP 6: Love Plot (Pre- vs Post-Match Absolute SMD)                          */
/*==============================================================================*/
/* Combine pre-match and post-match SMD tables into one long-format dataset,    */
/* then plot |SMD| for each covariate, colored by pre/post.                     */

data pre_smd;
    length Phase $10;
    set a.stddiff_prematch;  /* produced by Person 1 in Data Cleaning step */
    Phase = "Pre-Match";
    Abs_SMD = abs(input(Stddiff, best12.));
run;

data post_smd;
    length Phase $10;
    set a.stddiff_postmatch;
    Phase = "Post-Match";
    Abs_SMD = abs(input(Stddiff, best12.));
run;

data a.loveplot_data;
    set pre_smd post_smd;
run;

proc sort data=a.loveplot_data;
    by VarName Phase;
run;

proc sgplot data=a.loveplot_data;
    scatter x=Abs_SMD y=VarName / group=Phase
            markerattrs=(size=10 symbol=circlefilled);
    refline 0.10 / axis=x lineattrs=(pattern=shortdash) label="|SMD|=0.10";
    xaxis label="Absolute Standardized Mean Difference" min=0;
    yaxis label="Covariate" discreteorder=data;
    keylegend / title="";
    title "Step 6: Love Plot - Covariate Balance Before vs After Matching";
run;
title;