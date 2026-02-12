/*=============================================================================
  HW1: Multivariable Regression Analysis
  Dataset: hw_vlbw (Very Low Birth Weight Infants)
  Exposure: IVH (Intraventricular Hemorrhage)
  Outcome: DEAD (Death)

  Author: Xuange Liang
  Date: February 4, 2026
=============================================================================*/

/*-----------------------------------------------------------------------------
  STEP 0: Setup and Data Import
-----------------------------------------------------------------------------*/

/* Set library path - modify this to your actual data location */
libname hw "/home/u64139022/P8586/HW1";

/*=============================================================================
  OUTPUT TO WORD DOCUMENT
=============================================================================*/
/* Start ODS RTF output for Word document */
ODS RTF FILE="/home/u64139022/P8586/HW1/HW1_Results.rtf" 
        STYLE=Journal
        STARTPAGE=NO;

/* Set title for the document */
TITLE "HW1: Multivariable Regression Analysis";
TITLE2 "IVH and Mortality in Very Low Birth Weight Infants";
TITLE3 "Student: Xuange Liang | Date: February 4, 2026";

/* Define formats for all variables */
PROC FORMAT;
    VALUE deadf 0='Alive' 1='Dead';
    VALUE ivhf 0='No' 1='Yes';
    VALUE pneumof 0='No' 1='Yes';
    VALUE twinf 0='No' 1='Yes';
    VALUE deliveryf 1='C-Section' 2='Vaginal' 9='Unknown';
    VALUE inoutf 1='Born at Duke' 2='Transport';
    /* For categorized continuous variables (if needed) */
    VALUE bwt_catf 1='<1000g' 2='1000-1299g' 3='1300-1599g';
    VALUE gest_catf 1='<28 weeks' 2='28-31 weeks' 3='>=32 weeks';
RUN;

/* Check the data structure - NOT included in output */
ODS RTF EXCLUDE ALL;
proc contents data=hw.hw_vlbw;
run;

/* Preview the data - NOT included in output */
proc print data=hw.hw_vlbw (obs=20);
run;
ODS RTF EXCLUDE NONE;

/* Create analysis dataset with categorized continuous variables */
data vlbw_analysis;
    set hw.hw_vlbw;

    /* Categorize birth weight */
    if bwt < 1000 then bwt_cat = 1;
    else if bwt < 1300 then bwt_cat = 2;
    else bwt_cat = 3;

    /* Categorize gestational age */
    if gest < 28 then gest_cat = 1;
    else if gest < 32 then gest_cat = 2;
    else gest_cat = 3;

    /* Rename variables for consistency */
    IVH = ivh2;

    label bwt_cat = "Birth Weight Category"
          gest_cat = "Gestational Age Category"
          IVH = "Intraventricular Hemorrhage";
run;

/* Check sample size and missing values */
ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 1: SAMPLE DESCRIPTION";

title "Table: Sample Size and Missing Data";
proc means data=vlbw_analysis n nmiss maxdec=0;
    var DEAD IVH bwt gest pneumo twin;
run;

title "Table: Frequency Distribution of Key Variables";
proc freq data=vlbw_analysis;
    tables DEAD IVH pneumo Delivery_new twin Inout_new bwt_cat gest_cat / missing nocum;
run;


/*-----------------------------------------------------------------------------
  STEP 1: Descriptive Statistics
-----------------------------------------------------------------------------*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 2: BASELINE CHARACTERISTICS";

/*=== Table 1: Distribution of covariates by EXPOSURE (IVH) - Column Percentage ===*/

title "Table 1: Distribution of Baseline Factors by IVH Status (Column %)";
proc freq data=vlbw_analysis;
    format DEAD deadf. IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    tables (pneumo Delivery_new twin Inout_new bwt_cat gest_cat)*IVH
           / nopercent norow chisq;
run;

/* For continuous variables - compare means by IVH status */
title "Table 1 (continued): Continuous Variables by IVH Status";
proc ttest data=vlbw_analysis;
    class IVH;
    var bwt gest;
    ODS SELECT Statistics TTests Equality;
run;


/*=== Table 2: Distribution of covariates by OUTCOME (DEAD) - Row Percentage ===*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 3: MORTALITY BY CHARACTERISTICS";

title "Table 2: Mortality Outcomes by Covariate Levels (Row %)";
proc freq data=vlbw_analysis;
    format DEAD deadf. IVH ivhf. pneumo pneumof. twin twinf.
           Delivery_new deliveryf. Inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    tables (IVH pneumo Delivery_new twin Inout_new bwt_cat gest_cat)*DEAD
           / nopercent nocol chisq;
run;

/* For continuous variables - compare means by DEAD status */
title "Table 2 (continued): Continuous Variables by Mortality Status";
proc ttest data=vlbw_analysis;
    class DEAD;
    var bwt gest;
    ODS SELECT Statistics TTests Equality;
run;


/*-----------------------------------------------------------------------------
  STEP 2: Unadjusted Association between IVH and DEAD
-----------------------------------------------------------------------------*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 4: UNADJUSTED ASSOCIATION";

/*=== Unadjusted Odds Ratio (Logistic Regression) ===*/
title "Table 3A: Unadjusted Odds Ratio - IVH and Mortality";
proc logistic data=vlbw_analysis;
    class IVH (ref='0') / param=ref;
    model DEAD (event='1') = IVH;
    ODS SELECT ClassLevelInfo ModelInfo ResponseProfile FitStatistics 
               GlobalTests ParameterEstimates OddsRatios Association;
run;

/*=== Unadjusted Risk Ratio (Poisson Regression with Log Link) ===*/
title "Table 3B: Unadjusted Risk Ratio - IVH and Mortality";
proc genmod data=vlbw_analysis;
    class IVH (ref='0') / param=ref;
    model DEAD = IVH / dist=poisson link=log type3 wald;
    estimate "IVH Yes vs No" IVH 1 / exp;
    ODS SELECT ModelInfo ClassLevels ParameterEstimates Type3 Estimates;
run;

/*=== Cross-tabulation for Risk Calculation ===*/
title "Table 3C: 2x2 Table - IVH and Mortality";
proc freq data=vlbw_analysis;
    format IVH ivhf. DEAD deadf.;
    tables IVH*DEAD / nopercent nocol chisq relrisk;
run;


/*-----------------------------------------------------------------------------
  STEP 3: Univariate Analysis for Purposeful Selection
  Criterion: p < 0.25 -> Candidate list
-----------------------------------------------------------------------------*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 5: UNIVARIATE SCREENING (p<0.25)";

title "Table 4: Univariate Analysis - Each Covariate vs Mortality";

/* Reusable univariate logistic model to avoid repeated code blocks */
%macro uni_logit(var=, ref=, label=);
title2 "&label";
proc logistic data=vlbw_analysis;
    class &var (ref="&ref") / param=ref;
    model DEAD (event='1') = &var;
    ODS SELECT ParameterEstimates OddsRatios;
run;
%mend uni_logit;

%uni_logit(var=pneumo, ref=0, label=Pneumothorax);
%uni_logit(var=Delivery_new, ref=1, label=Delivery Mode);
%uni_logit(var=twin, ref=0, label=Multiple Gestation);
%uni_logit(var=Inout_new, ref=1, label=Birth Location);
%uni_logit(var=bwt_cat, ref=3, label=Birth Weight Categories);
%uni_logit(var=gest_cat, ref=3, label=Gestational Age Categories);

title2;


/*-----------------------------------------------------------------------------
  STEP 4: Multivariable Regression - Purposeful Selection Process
-----------------------------------------------------------------------------*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 6: MODEL BUILDING PROCESS";

/*=== Step 4a: Initial Full Model with all Candidate Variables ===*/
/* Include all variables with p < 0.25 from univariate analysis */

title "Step 1: Full Model with All Candidate Variables";
proc logistic data=vlbw_analysis;
    class IVH (ref='0')
          pneumo (ref='0')
          twin (ref='0')
          Delivery_new (ref='1')
          Inout_new (ref='1')
          bwt_cat (ref='3')
          gest_cat (ref='3') / param=ref;
    model DEAD (event='1') = IVH pneumo twin Delivery_new Inout_new bwt_cat gest_cat;
    ODS SELECT Type3 ParameterEstimates OddsRatios Association;
run;

/*=== Alternative: Model with Birth Weight Only (sensitivity analysis) ===*/
title "Step 2: Sensitivity Analysis - Model without Gestational Age";
proc logistic data=vlbw_analysis;
    class IVH (ref='0')
          pneumo (ref='0')
          bwt_cat (ref='3') / param=ref;
    model DEAD (event='1') = IVH pneumo bwt_cat;
    ODS SELECT Type3 ParameterEstimates OddsRatios Association;
run;

/*=== Final Logistic Regression Model (Adjusted Odds Ratios) ===*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 7: FINAL MULTIVARIABLE MODELS";

title "Table 5A: Final Logistic Regression Model - Adjusted Odds Ratios";
proc logistic data=vlbw_analysis;
    class IVH (ref='0')
          pneumo (ref='0')
          bwt_cat (ref='3')
          gest_cat (ref='3') / param=ref;
    model DEAD (event='1') = IVH pneumo bwt_cat gest_cat;
    ODS OUTPUT OddsRatios=aOR;
    ODS SELECT Type3 ParameterEstimates OddsRatios Association FitStatistics;
run;


/*=== Final Log-linear Poisson Model (Adjusted Risk Ratios) ===*/

title "Table 5B: Final Poisson Regression Model - Adjusted Risk Ratios";
proc genmod data=vlbw_analysis;
    class IVH (ref='0')
          pneumo (ref='0')
          bwt_cat (ref='3')
          gest_cat (ref='3') / param=ref;
    model DEAD = IVH pneumo bwt_cat gest_cat
          / dist=poisson link=log type3 wald;

    /* Estimate statements to get Risk Ratios */
    estimate "IVH Yes vs No"          IVH 1 / exp;
    estimate "Pneumo Yes vs No"       pneumo 1 / exp;
    estimate "BWT <1000g vs 1300-1599g"     bwt_cat 1 0 / exp;
    estimate "BWT 1000-1299g vs 1300-1599g" bwt_cat 0 1 / exp;
    estimate "Gest <28wk vs >=32wk"   gest_cat 1 0 / exp;
    estimate "Gest 28-31wk vs >=32wk" gest_cat 0 1 / exp;

    ODS OUTPUT Estimates=aRR;
    ODS SELECT ParameterEstimates Type3 Estimates;
run;


/*-----------------------------------------------------------------------------
  STEP 6: Summary Tables
-----------------------------------------------------------------------------*/

ODS RTF TEXT="^S={fontweight=bold fontsize=14pt}SECTION 8: SUMMARY";

/* Print summary of adjusted estimates */
title "Summary Table: Adjusted Odds Ratios (from Logistic Regression)";
proc print data=aOR noobs label;
    var Effect OddsRatioEst LowerCL UpperCL;
    format OddsRatioEst LowerCL UpperCL 8.3;
    label Effect="Variable"
          OddsRatioEst="Adjusted OR"
          LowerCL="95% CI Lower"
          UpperCL="95% CI Upper";
run;

title "Summary Table: Adjusted Risk Ratios (from Poisson Regression)";
proc print data=aRR noobs label;
    where Label contains "vs";
    var Label MeanEstimate MeanLowerCL MeanUpperCL ProbChiSq;
    format MeanEstimate MeanLowerCL MeanUpperCL 8.3 ProbChiSq pvalue6.4;
    label Label="Comparison"
          MeanEstimate="Adjusted RR"
          MeanLowerCL="95% CI Lower"
          MeanUpperCL="95% CI Upper"
          ProbChiSq="p-value";
run;

/*=============================================================================
  END OF ANALYSIS - CLOSE OUTPUT
=============================================================================*/

/* Close RTF output */
ODS RTF CLOSE;

/* Print completion message to log */
%PUT ===================================================;
%PUT Word document generated successfully!;
%PUT Location: /home/u64139022/P8586/HW1/HW1_Results.rtf;
%PUT ===================================================;
