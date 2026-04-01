/*=============================================================================
  HW4: Propensity Score Analysis - IPTW (Inverse Probability of Treatment Weighting)
  Dataset: hw_vlbw (Very Low Birth Weight Infants, N=514)
  Exposure: IVH - Intraventricular Hemorrhage (ivh2: 1=Yes, 0=No)
  Outcome:  DEAD - Death (dead: 1=Dead, 0=Alive)

  Method: IPTW for ATE (Average Treatment Effect)

  Requirements:
    1. Fit PS Step 1 models (simple + complex); pick final model by SMD with IPTW weights
    2. Table 1 for original cohort and PS-IPTW cohort (col% + SMD)
    3. Scatter plot: IPTW weight vs. propensity score by IVH group
    4. Table 2: unadjusted OR/RR (HW1) + adjusted OR/RR (HW1) + PS-matched (HW3) + PS-IPTW

  Author: Xuange Liang
  Date: 2026-03-03
=============================================================================*/

/*-----------------------------------------------------------------------------
  STEP 0: Setup
-----------------------------------------------------------------------------*/

/* Modify this path to your actual data location */
libname hw "/home/u64139022/P8586/HW4";

ODS RTF FILE="/home/u64139022/P8586/HW4/HW4_Results.rtf"
        STYLE=Journal
        STARTPAGE=NO;

TITLE  "HW4: Propensity Score IPTW Analysis";
TITLE2 "IVH and Mortality in Very Low Birth Weight Infants";
TITLE3 "Student: Xuange Liang | Date: 2026-03-03";

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
  STEP 1: Data Preparation (same structure as HW1/HW3)
-----------------------------------------------------------------------------*/

data vlbw;
    set hw.hw_vlbw;

    /* Rename exposure variable */
    IVH = ivh2;

    /* Categorize birth weight */
         if bwt <  1000 then bwt_cat = 1;
    else if bwt <  1300 then bwt_cat = 2;
    else                     bwt_cat = 3;

    /* Categorize gestational age */
         if gest <  28 then gest_cat = 1;
    else if gest <  32 then gest_cat = 2;
    else                    gest_cat = 3;

    /* Create binary dummy variables for PROC PSMATCH */
    pneumo_yes      = (pneumo      = 1);
    twin_yes        = (twin        = 1);
    delivery_vag    = (Delivery_new = 2);
    delivery_unk    = (Delivery_new = 9);
    inout_transport = (Inout_new   = 2);
    bwt_lt1000      = (bwt_cat     = 1);
    bwt_1000_1299   = (bwt_cat     = 2);
    gest_lt28       = (gest_cat    = 1);
    gest_28_31      = (gest_cat    = 2);

    /* Patient ID for GEE repeated subject */
    pat_id = _n_;

    label IVH      = "Intraventricular Hemorrhage"
          bwt_cat  = "Birth Weight Category"
          gest_cat = "Gestational Age Category";
run;
/* NOTE: Expected 514 observations */

%let dummy_vars = pneumo_yes twin_yes delivery_vag delivery_unk
                  inout_transport bwt_lt1000 bwt_1000_1299
                  gest_lt28 gest_28_31;


/*=============================================================================
  SECTION 1: DESCRIPTIVE STATISTICS - ORIGINAL COHORT
  Table 1: column % by IVH status
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 1: ORIGINAL COHORT - BASELINE CHARACTERISTICS";

title "Table 1A: Baseline Characteristics by IVH Status - Original Cohort (N=514, Column %)";
proc tabulate data=vlbw;
    format IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    class IVH pneumo twin Delivery_new Inout_new bwt_cat gest_cat;
    table pneumo twin Delivery_new Inout_new bwt_cat gest_cat,
          IVH * (n*f=8. colpctn='%') / box='';
run;

title "Table 1A (P-values): Chi-Square Tests by IVH Status - Original Cohort";
proc freq data=vlbw;
    format IVH ivhf. pneumo pneumof. twin twinf.
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
  SECTION 2: PS STEP 1 MODEL BUILDING
  Predict IVH from baseline covariates
  Model A: main effects only
  Model B: two-way interactions, backward (SLS=0.20)
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 2: PS STEP 1 MODEL BUILDING";

/*--- Model A: Main effects only ---*/
title "PS Model A: Logistic Regression - No Interaction Terms";
proc logistic data=vlbw plots(only)=roc;
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

/*--- Model B: Two-way interactions, backward (SLS=0.20) ---*/
/* NOTE: Quasi-complete separation warnings are expected with small samples.
   Model B results should be interpreted cautiously.                        */
title "PS Model B: Logistic Regression - Two-Way Interactions (Backward, SLS=0.20)";
proc logistic data=vlbw plots(only)=roc;
    class pneumo      (ref='0')
          twin        (ref='0')
          Delivery_new(ref='1')
          Inout_new   (ref='1')
          bwt_cat     (ref='3')
          gest_cat    (ref='3') / param=ref;
    model IVH (event='1') = pneumo|twin|Delivery_new|Inout_new|bwt_cat|gest_cat@2
                            / selection=backward slstay=0.20;
    output out=ps_model_B predicted=propensity_score;
    ODS SELECT ROCCurve ModelInfo FitStatistics GlobalTests
               Association ParameterEstimates OddsRatios;
run;


/*=============================================================================
  SECTION 3: CALCULATE IPTW WEIGHTS (ATE)
  ATE weight:
    Treated (IVH=1): w = 1 / PS
    Control (IVH=0): w = 1 / (1 - PS)
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 3: IPTW WEIGHT CALCULATION (ATE)";

/*--- IPTW from Model A ---*/
data ps_IPTW_A;
    set ps_model_A;
    if IVH = 1 then ATE_IPTW = 1 / propensity_score;
    else if IVH = 0 then ATE_IPTW = 1 / (1 - propensity_score);
    pat_id = _n_;
run;

/*--- IPTW from Model B ---*/
data ps_IPTW_B;
    set ps_model_B;
    if IVH = 1 then ATE_IPTW = 1 / propensity_score;
    else if IVH = 0 then ATE_IPTW = 1 / (1 - propensity_score);
    pat_id = _n_;
run;

title "IPTW Weight Summary Statistics - Model A (ATE)";
proc means data=ps_IPTW_A n mean std median p25 p75 min max maxdec=4;
    var ATE_IPTW;
    class IVH;
    format IVH ivhf.;
run;

title "IPTW Weight Summary Statistics - Model B (ATE)";
proc means data=ps_IPTW_B n mean std median p25 p75 min max maxdec=4;
    var ATE_IPTW;
    class IVH;
    format IVH ivhf.;
run;


/*=============================================================================
  SECTION 4: BALANCE DIAGNOSTICS - SMD IN IPTW-WEIGHTED COHORT
  Use PROC MEANS with WEIGHT to compute weighted means, then compare SMD
  Also use PROC PSMATCH psweight for automated SMD output
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 4: BALANCE DIAGNOSTICS (IPTW-WEIGHTED SMD)";

/*--- Use PROC PSMATCH for ATE balance diagnostics.
      Feed in the propensity scores estimated earlier by PROC LOGISTIC through
      PSDATA. This avoids version-specific limitations in the PSMODEL syntax
      and keeps the balance check aligned with the exact PS used for weighting.
      SAS documentation examples show this older syntax pattern:
      - PSDATA treatvar=... ps=...
      - ASSESS ... / weight=ATEWGT
      - OUTPUT ... atewgt=...
-----------------------------------------------------------------------------*/

/* PROC PSMATCH for Model A - ATE */
ods graphics on;
title "Balance Diagnostics: PS-IPTW (ATE) - Model A via PROC PSMATCH";
proc psmatch data=ps_model_A region=allobs;
    class &dummy_vars. IVH;
    psdata treatvar=IVH(treated='1') ps=propensity_score;
    assess lps var=(&dummy_vars.) / plots=all weight=ATEWGT;
    output out(obs=all)=psmatch_IPTW_A atewgt=wt_ate;
run;
ods graphics off;

/* PROC PSMATCH for Model B - ATE */
ods graphics on;
title "Balance Diagnostics: PS-IPTW (ATE) - Model B via PROC PSMATCH";
proc psmatch data=ps_model_B region=allobs;
    class &dummy_vars. IVH;
    psdata treatvar=IVH(treated='1') ps=propensity_score;
    assess lps var=(&dummy_vars.) / plots=all weight=ATEWGT;
    output out(obs=all)=psmatch_IPTW_B atewgt=wt_ate;
run;
ods graphics off;

/*
  DECISION RULE:
  - Compare SMD from IPTW-weighted Model A vs. Model B
  - Choose model with fewer SMDs exceeding 0.10 (or 0.20 for small samples)
  - If similar balance, choose simpler model (Model A preferred for stability)
*/

/* *** After running, update this block if Model B is preferred *** */
/* Final IPTW dataset: use Model A weights */
data ps_IPTW_final;
    set ps_IPTW_A;
run;


/*=============================================================================
  SECTION 5: PS AND IPTW WEIGHT DISTRIBUTION PLOT
  Requirement 3: Scatter plot of weight vs. PS by IVH group
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 5: PS AND IPTW WEIGHT DISTRIBUTION";

title "Scatter Plot: IPTW Weight vs. Propensity Score by IVH Status (ATE, Model A)";
proc sgplot data=ps_IPTW_final;
    format IVH ivhf.;
    scatter x=propensity_score y=ATE_IPTW / group=IVH
            markerattrs=(size=6) transparency=0.3;
    xaxis label="Propensity Score" values=(0 to 0.8 by 0.1);
    yaxis label="IPTW Weight (ATE)";
    keylegend / title="IVH Status";
    title "Scatter Plot: IPTW Weight vs. Propensity Score by IVH Status";
run;

title "PS Distribution by IVH Status - Original Cohort (Before IPTW)";
proc sgplot data=ps_IPTW_final;
    format IVH ivhf.;
    histogram propensity_score / group=IVH transparency=0.4;
    density   propensity_score / group=IVH type=kernel;
    keylegend / title="IVH Status";
    xaxis label="Propensity Score";
    yaxis label="Frequency";
run;

title "IPTW Weight Distribution by IVH Status";
proc sgplot data=ps_IPTW_final;
    format IVH ivhf.;
    histogram ATE_IPTW / group=IVH transparency=0.4;
    keylegend / title="IVH Status";
    xaxis label="IPTW Weight (ATE)";
    yaxis label="Frequency";
run;

title "Summary: IPTW Weights by IVH Status";
proc means data=ps_IPTW_final mean std median min max maxdec=3;
    var propensity_score ATE_IPTW;
    class IVH;
    format IVH ivhf.;
run;


/*=============================================================================
  SECTION 6: TABLE 1 - PS-IPTW WEIGHTED COHORT
  Requirement 2: Table 1 comparing original vs. IPTW-weighted cohort
  PROC FREQ with WEIGHT statement applies IPTW weights
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 6: TABLE 1 - PS-IPTW WEIGHTED COHORT";

title "Table 1: Original Cohort (N=514) - Column % by IVH Status";
proc tabulate data=vlbw;
    format IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    class IVH pneumo twin Delivery_new Inout_new bwt_cat gest_cat;
    table pneumo twin Delivery_new Inout_new bwt_cat gest_cat,
          IVH * (n*f=8. colpctn='%') / box='';
run;

title "Table 1: PS-IPTW Weighted Cohort (ATE) - Column % and Chi-Square";
proc freq data=ps_IPTW_final;
    format IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    weight ATE_IPTW;
    tables (pneumo twin Delivery_new Inout_new bwt_cat gest_cat) * IVH
           / nopercent norow chisq;
run;

/* NOTE: SMD for IPTW-weighted cohort is output by PROC PSMATCH above (Section 4).
   Refer to those tables for standardized differences by variable.              */


/*=============================================================================
  SECTION 7: PS STEP 2 - IPTW OUTCOME MODEL
  Requirement 4: Fit weighted outcome model
  GEE with IPTW weights; use robust sandwich variance estimator
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 7: PS STEP 2 - IPTW OUTCOME MODEL";

/*--- Unadjusted OR (from HW1 - reproduce for Table 2) ---*/
title "Table 2A: Unadjusted Odds Ratio (HW1) - IVH and Mortality";
proc logistic data=vlbw;
    format IVH ivhf. dead deadf.;
    class IVH (ref='No IVH') / param=ref;
    model dead (event='Dead') = IVH;
    ODS SELECT ParameterEstimates OddsRatios Association;
run;

title "Table 2A: Unadjusted Risk Ratio (HW1) - IVH and Mortality";
proc genmod data=vlbw;
    format IVH ivhf. dead deadf.;
    class IVH (ref='No IVH') / param=ref;
    model dead (event='Dead') = IVH / dist=poisson link=log;
    estimate "IVH: Yes vs No" IVH 1 / exp;
    ODS SELECT ParameterEstimates Estimates;
run;

/*--- Adjusted OR/RR from HW1 multivariable model (purposeful selection) ---*/
/* Final HW1 model: IVH + pneumo + bwt_cat + gest_cat                       */
title "Table 2B: Adjusted OR from HW1 Multivariable Model";
proc logistic data=vlbw;
    format IVH ivhf. dead deadf.;
    class IVH      (ref='No IVH') / param=ref;
    class pneumo   (ref='0')
          bwt_cat  (ref='3')
          gest_cat (ref='3')      / param=ref;
    model dead (event='Dead') = IVH pneumo bwt_cat gest_cat;
    ODS SELECT ParameterEstimates OddsRatios Association;
run;

title "Table 2B: Adjusted RR from HW1 Multivariable Model";
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

/*--- 2x2 mortality table ---*/
title "Table 2 Distribution: IVH and Mortality (Row %)";
proc freq data=vlbw;
    format IVH ivhf. dead deadf.;
    tables IVH * dead / nopercent nocol chisq relrisk;
run;

/*--- PS-IPTW ATE Outcome Model: Logistic (OR) ---*/
title "Table 2D: PS-IPTW Adjusted OR (ATE) - Weighted Logistic via GEE";
proc genmod data=ps_IPTW_final;
    format IVH ivhf. dead deadf.;
    class IVH (ref='No IVH') pat_id / param=ref;
    model dead (event='Dead') = IVH / dist=bin link=logit;
    weight ATE_IPTW;
    repeated subject=pat_id;
    estimate "IVH: Yes vs No" IVH 1 / exp;
    ODS SELECT ParameterEstimates Estimates GEEEmpPEst;
run;

/*--- PS-IPTW ATE Outcome Model: Poisson (RR) ---*/
title "Table 2D: PS-IPTW Adjusted RR (ATE) - Weighted Poisson via GEE";
proc genmod data=ps_IPTW_final;
    format IVH ivhf. dead deadf.;
    class IVH (ref='No IVH') pat_id / param=ref;
    model dead (event='Dead') = IVH / dist=poisson link=log;
    weight ATE_IPTW;
    repeated subject=pat_id;
    estimate "IVH: Yes vs No" IVH 1 / exp;
    ODS SELECT ParameterEstimates Estimates GEEEmpPEst;
run;


/*=============================================================================
  SECTION 8: SUMMARY - TABLE 2 CONSOLIDATED
  All estimates: unadjusted + adjusted (HW1) + PS-matched (HW3) + PS-IPTW (HW4)
=============================================================================*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 8: SUMMARY - TABLE 2 CONSOLIDATED";

title "Summary Table 2: All Estimates for IVH -> Mortality Association";
title2 "(1) Unadjusted | (2) Adjusted HW1 | (3) PS-Matched HW3 | (4) PS-IPTW HW4";

proc tabulate data=vlbw;
    format IVH ivhf. dead deadf.;
    class IVH dead;
    table IVH, dead * (n*f=8. rowpctn='%') / box='';
run;

/*=============================================================================
  END OF ANALYSIS
=============================================================================*/

ODS RTF CLOSE;

%PUT ===================================================;
%PUT HW4 Analysis Complete!;
%PUT Output: HW4_Results.rtf;
%PUT ===================================================;
