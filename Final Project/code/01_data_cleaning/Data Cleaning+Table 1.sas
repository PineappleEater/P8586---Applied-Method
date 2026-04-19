/*==============================================================================*/
/*  Person 1: Data Cleaning, Variable Recoding, Descriptive Statistics (Table 1) */
/*  Project: Open vs. Laparoscopic Colectomy in Colorectal Cancer (NIS 2016-2018)*/
/*==============================================================================*/

/* ---- Library Setup ---- */
libname a "/home/u64134707/Applied Methods in Health Services and Outcome Research/Final Project";

/*==============================================================================*/
/* STEP 1: Explore the Raw Data                                                 */
/*==============================================================================*/

/* 1a. Check dataset structure */
proc contents data=a.proj1_2021_new order=varnum;
run;

/* 1b. Quick look at first 20 obs */
proc print data=a.proj1_2021_new (obs=20);
run;

/* 1c. Check frequencies of key categorical variables */
proc freq data=a.proj1_2021_new;
    tables DIED med_comp colectomy_open 
           DISPUNIFORM DQTR PAY1 PL_NCHS ZIPINC_QRTL 
           HOSP_BEDSIZE H_CONTRL HOSP_LOCATION HOSP_TEACH HOSP_REGION
           YEAR
           ahrq_pe urinary_comp pulmonary_comp cv_comp neuro_comp shock infection
           / missing;
run;

/* 1d. Check continuous variables */
proc means data=a.proj1_2021_new n nmiss mean std min q1 median q3 max;
    var AGE LOS TOTCHG TOTCHG_adj;
run;

/*==============================================================================*/
/* STEP 2: Data Cleaning & Variable Recoding                                    */
/*==============================================================================*/

data a.proj1_clean;
    set a.proj1_2021_new;

    /* ---- Age Groups ---- */
    if      AGE < 50       then AGE_CAT = 1;  /* <50 */
    else if 50 <= AGE < 65 then AGE_CAT = 2;  /* 50-64 */
    else if 65 <= AGE < 75 then AGE_CAT = 3;  /* 65-74 */
    else if AGE >= 75      then AGE_CAT = 4;  /* 75+ */

    /* ---- Primary Payer (PAY1) ---- */
    /* Original: 1=Medicare, 2=Medicaid, 3=Private, 4=Self-pay, 5=No charge, 6=Other */
    /* .A = special missing (shows as "A" in freq) - treat as missing                 */
    /* 68 regular missing + 5 special missing = 73 total missing                       */
    if      PAY1 = 1       then PAYER = 1; /* Medicare */
    else if PAY1 = 2       then PAYER = 2; /* Medicaid */
    else if PAY1 = 3       then PAYER = 3; /* Private Insurance */
    else if PAY1 in (4,5,6) then PAYER = 4; /* Self-pay/No charge/Other */
    else PAYER = .;  /* handles both . and .A */

    /* ---- Median Household Income Quartile (ZIPINC_QRTL) ---- */
    /* 1005 missing + 4 special missing = 1009 total missing     */
    /* Keep as is: 1=Q1(lowest) to 4=Q4(highest), missing stays missing */

    /* ---- Patient Location (PL_NCHS) ---- */
    /* 1=Central large metro, 2=Fringe large metro, 3=Medium metro, 
       4=Small metro, 5=Micropolitan, 6=Not metro                  */
    /* 149 missing */
    if      PL_NCHS in (1,2) then PATIENT_LOC = 1; /* Large metro */
    else if PL_NCHS in (3,4) then PATIENT_LOC = 2; /* Small/medium metro */
    else if PL_NCHS in (5,6) then PATIENT_LOC = 3; /* Rural/micropolitan */
    else PATIENT_LOC = .;

    /* ---- Hospital Location: CONFIRMED 0=Rural, 1=Urban ---- */
    /* No recoding needed, just apply correct format later       */

    /* ---- Complication variables: recode missing to 0 ---- */
    /* Confirmed from Step 1: missing = no complication          */
    /*   ahrq_pe:        59283 missing, 618 = 1                 */
    /*   urinary_comp:   52761 missing, 7140 = 1                */
    /*   pulmonary_comp: 56302 missing, 3599 = 1                */
    /*   cv_comp:        59301 missing, 600 = 1                 */
    /*   neuro_comp:     59760 missing, 141 = 1                 */
    /*   shock:          56980 missing, 2921 = 1                */
    /*   infection:      52513 missing, 7388 = 1                */

    array comp_vars {7} ahrq_pe urinary_comp pulmonary_comp cv_comp 
                        neuro_comp shock infection;
    do i = 1 to 7;
        if comp_vars{i} = . then comp_vars{i} = 0;
    end;

    /* ---- Verify med_comp consistency ---- */
    med_comp_check = (urinary_comp=1 or pulmonary_comp=1 or cv_comp=1 or 
                      neuro_comp=1 or shock=1 or infection=1);

    /* ---- Labels ---- */
    label AGE            = "Age (years)"
          AGE_CAT        = "Age Group"
          DIED           = "In-hospital Mortality"
          med_comp       = "Perioperative Medical Complications"
          colectomy_open = "Open Colectomy"
          LOS            = "Length of Stay (days)"
          TOTCHG         = "Total Charges ($)"
          TOTCHG_adj     = "Total Charges Adjusted ($)"
          PAY1           = "Primary Expected Payer (original)"
          PAYER          = "Primary Payer"
          ZIPINC_QRTL    = "Median Household Income Quartile"
          HOSP_BEDSIZE   = "Hospital Bed Size"
          H_CONTRL       = "Hospital Ownership"
          HOSP_LOCATION  = "Hospital Location"
          HOSP_TEACH     = "Teaching Hospital"
          HOSP_REGION    = "Hospital Region"
          PL_NCHS        = "Patient Location (NCHS)"
          PATIENT_LOC    = "Patient Location"
          DQTR           = "Discharge Quarter"
          YEAR           = "Calendar Year"
          DISPUNIFORM    = "Disposition of Patient"
          ahrq_pe        = "AHRQ Patient Safety Event"
          urinary_comp   = "Urinary Complication"
          pulmonary_comp = "Pulmonary Complication"
          cv_comp        = "Cardiovascular Complication"
          neuro_comp     = "Neurological Complication"
          shock          = "Shock"
          infection      = "Infection"
          med_comp_check = "Med Comp (Recalculated)"
          ;

    drop i;
run;

/* ---- Verify med_comp matches recalculated version ---- */
proc freq data=a.proj1_clean;
    tables med_comp * med_comp_check / missing;
    title "Verify med_comp vs Recalculated";
run;
title;
/* If they don't match perfectly, investigate. Once confirmed, drop med_comp_check */

/*==============================================================================*/
/* STEP 3: Missing Data Summary                                                 */
/*==============================================================================*/

proc means data=a.proj1_clean nmiss n;
    var AGE DIED LOS TOTCHG TOTCHG_adj colectomy_open med_comp
        PAYER ZIPINC_QRTL PATIENT_LOC
        HOSP_BEDSIZE H_CONTRL HOSP_LOCATION HOSP_TEACH HOSP_REGION
        DQTR YEAR
        ahrq_pe urinary_comp pulmonary_comp cv_comp neuro_comp shock infection;
    title "Missing Data Summary After Cleaning";
run;
title;

/* NOTE: Key missing counts from Step 1 output:                        */
/* AGE=0, DIED=0, LOS=0, colectomy_open=0, med_comp=0 -- good         */
/* TOTCHG/TOTCHG_adj = 519 missing (0.87%) -- acceptable               */
/* PAY1 = 73 missing (0.12%) -- very small                             */
/* ZIPINC_QRTL = 1009 missing (1.68%) -- acceptable                    */
/* PL_NCHS = 149 missing (0.25%) -- very small                         */
/* DQTR = 25 missing (0.04%) -- trivial                                */
/* Hospital vars (BEDSIZE, H_CONTRL, LOCATION, TEACH, REGION) = 0 -- good */
/* Decision: Keep all obs. Missing covariates are small %.              */
/*           SAS procedures handle missing automatically.               */

/*==============================================================================*/
/* STEP 4: Formats                                                              */
/*==============================================================================*/

proc format;
    value agecatf   1 = "<50"
                    2 = "50-64"
                    3 = "65-74"
                    4 = "75+";

    value payerf    1 = "Medicare"
                    2 = "Medicaid"
                    3 = "Private Insurance"
                    4 = "Self-pay/Other";

    value yesnof    0 = "No"
                    1 = "Yes";

    value openf     0 = "Laparoscopic"
                    1 = "Open";

    value bedsizef  1 = "Small"
                    2 = "Medium"
                    3 = "Large";

    value controlf  1 = "Government"
                    2 = "Private, not-for-profit"
                    3 = "Private, investor-owned";

    value hosplf    0 = "Rural"      /* CORRECTED: 0=Rural, 1=Urban */
                    1 = "Urban";

    value regionf   1 = "Northeast"
                    2 = "Midwest"
                    3 = "South"
                    4 = "West";

    value incomef   1 = "Q1 (Lowest)"
                    2 = "Q2"
                    3 = "Q3"
                    4 = "Q4 (Highest)";

    value patlocf   1 = "Large Metropolitan"
                    2 = "Small/Medium Metropolitan"
                    3 = "Rural/Micropolitan";
run;

/*==============================================================================*/
/* STEP 5: TABLE 1 - Descriptive Statistics by Treatment Group                  */
/*==============================================================================*/
/* Total: N=59,901                                                              */
/* Open (colectomy_open=1): N=36,340 (60.67%)                                  */
/* Laparoscopic (colectomy_open=0): N=23,561 (39.33%)                          */

/* ---- 5a. Sample Size by Group ---- */
proc freq data=a.proj1_clean;
    tables colectomy_open;
    format colectomy_open openf.;
    title "Treatment Group Distribution (N=59,901)";
run;

/* ---- 5b. Continuous Variables by Group ---- */
/* AGE: mean=66.3, SD=13.3, range 18-90 */
/* LOS: mean=7.6, SD=7.6, median=5, range 0-344 (highly skewed) */
/* TOTCHG_adj: mean=105,156, SD=113,040, median=75,580 (highly skewed) */

proc means data=a.proj1_clean n mean std median q1 q3 maxdec=2;
    class colectomy_open;
    var AGE LOS TOTCHG_adj;
    format colectomy_open openf.;
    title "Continuous Variables by Treatment Group";
run;

/* t-test for AGE (approximately normal) */
proc ttest data=a.proj1_clean;
    class colectomy_open;
    var AGE;
    format colectomy_open openf.;
    title "Age Comparison: Open vs Laparoscopic";
run;

/* Wilcoxon rank-sum for LOS and TOTCHG_adj (skewed) */
proc npar1way data=a.proj1_clean wilcoxon;
    class colectomy_open;
    var LOS TOTCHG_adj;
    format colectomy_open openf.;
    title "LOS and Charges Comparison (Wilcoxon)";
run;

/* ---- 5c. Categorical Variables by Group ---- */
proc freq data=a.proj1_clean;
    tables colectomy_open * AGE_CAT        / chisq nocol nopercent;
    tables colectomy_open * PAYER          / chisq nocol nopercent;
    tables colectomy_open * ZIPINC_QRTL    / chisq nocol nopercent;
    tables colectomy_open * PATIENT_LOC    / chisq nocol nopercent;
    tables colectomy_open * HOSP_BEDSIZE   / chisq nocol nopercent;
    tables colectomy_open * H_CONTRL       / chisq nocol nopercent;
    tables colectomy_open * HOSP_LOCATION  / chisq nocol nopercent;
    tables colectomy_open * HOSP_TEACH     / chisq nocol nopercent;
    tables colectomy_open * HOSP_REGION    / chisq nocol nopercent;
    tables colectomy_open * YEAR           / chisq nocol nopercent;

    format colectomy_open openf.
           AGE_CAT agecatf.
           PAYER payerf.
           ZIPINC_QRTL incomef.
           PATIENT_LOC patlocf.
           HOSP_BEDSIZE bedsizef.
           H_CONTRL controlf.
           HOSP_LOCATION hosplf.
           HOSP_TEACH yesnof.
           HOSP_REGION regionf.;
    title "Categorical Variables by Treatment Group";
run;

/* ---- 5d. Outcome Variables by Group ---- */
proc freq data=a.proj1_clean;
    tables colectomy_open * DIED           / chisq nocol nopercent;
    tables colectomy_open * med_comp       / chisq nocol nopercent;
    tables colectomy_open * ahrq_pe        / chisq nocol nopercent;
    tables colectomy_open * urinary_comp   / chisq nocol nopercent;
    tables colectomy_open * pulmonary_comp / chisq nocol nopercent;
    tables colectomy_open * cv_comp        / chisq nocol nopercent;
    tables colectomy_open * neuro_comp     / chisq nocol nopercent;
    tables colectomy_open * shock          / chisq nocol nopercent;
    tables colectomy_open * infection      / chisq nocol nopercent;

    format colectomy_open openf.
           DIED yesnof.
           med_comp yesnof.
           ahrq_pe yesnof.
           urinary_comp yesnof.
           pulmonary_comp yesnof.
           cv_comp yesnof.
           neuro_comp yesnof.
           shock yesnof.
           infection yesnof.;
    title "Outcomes by Treatment Group";
run;
title;

/*==============================================================================*/
/* STEP 6: Standardized Differences (Pre-Matching) for Table 1                  */
/*==============================================================================*/
/* NOTE: Update the path to where the stddiff macro is saved on SAS server */

%include "/home/u64134707/Applied Methods in Health Services and Outcome Research/Final Project/Standardized_Difference.sas";

/* For the stddiff macro:                                                       */
/*   groupvar must be coded 0/1 -- colectomy_open is already 0/1, GOOD          */
/*   numvars = continuous variables                                              */
/*   charvars = categorical variables (binary must be 0/1)                       */
/*   NOTE: Multi-level categorical vars (AGE_CAT, PAYER, etc.) can be included  */

%stddiff(inds = a.proj1_clean, 
         groupvar = colectomy_open,
         numvars = AGE,
         charvars = AGE_CAT PAYER ZIPINC_QRTL PATIENT_LOC 
                    HOSP_BEDSIZE H_CONTRL HOSP_LOCATION HOSP_TEACH 
                    HOSP_REGION YEAR,
         stdfmt = 8.4,
         outds = a.stddiff_prematch);

proc print data=a.stddiff_prematch;
    title "Table 1: Standardized Differences (Baseline Covariates Only)";
run;
title;

/* Drop verification variable */
data a.proj1_clean;
    set a.proj1_clean;
    drop med_comp_check;
run;

/*==============================================================================*/
/* STEP 7: Clean Dataset is Ready for Team                                      */
/*==============================================================================*/

/* Final dataset: a.proj1_clean                                                 */
/* All team members use this dataset for their analyses                          */

/* Final check */
proc contents data=a.proj1_clean order=varnum;
    title "Final Clean Dataset Structure";
run;

proc means data=a.proj1_clean n nmiss mean std min max maxdec=2;
    var AGE DIED LOS TOTCHG_adj colectomy_open med_comp;
    title "Final Clean Dataset: Key Variable Summary";
run;
title;

/*==============================================================================*/
/* DATA DICTIONARY                                                              */
/*==============================================================================*/
/*                                                                              */
/* Dataset: a.proj1_clean                                                       */
/* Source: NIS (Nationwide Inpatient Sample) 2016-2018                           */
/* N = 59,901                                                                   */
/*                                                                              */
/* TREATMENT:                                                                   */
/*   colectomy_open    1=Open, 0=Laparoscopic                                   */
/*                     Open: 36,340 (60.67%) | Lap: 23,561 (39.33%)            */
/*                                                                              */
/* OUTCOMES:                                                                    */
/*   DIED              1=In-hospital death (1,028 = 1.72%)                     */
/*   med_comp          1=Any complication (15,144 = 25.28%)                    */
/*                                                                              */
/* PATIENT DEMOGRAPHICS:                                                        */
/*   AGE               Continuous, mean=66.3, SD=13.3, range 18-90             */
/*   AGE_CAT           1=<50, 2=50-64, 3=65-74, 4=75+                         */
/*   PAYER             1=Medicare(54%), 2=Medicaid(8%), 3=Private(33%),         */
/*                     4=Self-pay/Other(4%), .=missing(73 obs)                 */
/*   ZIPINC_QRTL       1-4 income quartile, .=missing(1,009 obs)              */
/*   PL_NCHS           1-6 urban-rural code, .=missing(149 obs)               */
/*   PATIENT_LOC       1=Large metro, 2=Small/med metro, 3=Rural/micro         */
/*                                                                              */
/* HOSPITAL:                                                                    */
/*   HOSP_BEDSIZE      1=Small(17%), 2=Medium(29%), 3=Large(54%)               */
/*   H_CONTRL          1=Govt(11%), 2=Private nonprofit(78%), 3=Investor(12%) */
/*   HOSP_LOCATION     0=Rural(8%), 1=Urban(92%)  ** NOTE: 0/1 not 1/2 **     */
/*   HOSP_TEACH        0=Non-teaching(29%), 1=Teaching(71%)                    */
/*   HOSP_REGION       1=NE(18%), 2=MW(23%), 3=South(39%), 4=West(20%)        */
/*                                                                              */
/* CLINICAL:                                                                    */
/*   LOS               Days, mean=7.6, median=5, range 0-344 (skewed)         */
/*   TOTCHG_adj        Adjusted charges, mean=$105K, median=$75.6K (skewed)   */
/*   YEAR              2016/2017/2018 (~33% each)                              */
/*   DQTR              1-4 quarter, .=missing(25 obs)                          */
/*   DISPUNIFORM       Disposition: 1=Routine, 5=Transfer, 6=HHC, 20=Died     */
/*                                                                              */
/* COMPLICATIONS (0/1, missing recoded to 0):                                  */
/*   ahrq_pe           1.03%                                                   */
/*   urinary_comp      11.92%                                                  */
/*   pulmonary_comp    6.01%                                                   */
/*   cv_comp           1.00%                                                   */
/*   neuro_comp        0.24%                                                   */
/*   shock             4.88%                                                   */
/*   infection         12.33%                                                  */
/*                                                                              */
/* IDs (do not use in analysis):                                               */
/*   HOSP_NIS          Hospital identifier                                     */
/*   KEY_NIS           Patient record identifier                               */
/*   DISPUNIFORM       Discharge disposition (not a covariate)                 */
/*   TOTCHG            Unadjusted charges (use TOTCHG_adj instead)            */
/*   year_qtr          Year-quarter string                                     */
/*   HOSP_LOCTEACH     Combined location/teaching (use separate vars instead) */
/*==============================================================================*/

