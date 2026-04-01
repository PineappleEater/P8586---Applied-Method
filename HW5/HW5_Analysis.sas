/*=============================================================================
  HW5: Propensity Score Analysis - Stratification and Regression
  Dataset: hw_vlbw (Very Low Birth Weight Infants, N=514)
  Exposure: IVH - Intraventricular Hemorrhage (ivh2: 1=Yes, 0=No)
  Outcome:  DEAD - Death (dead: 1=Dead, 0=Alive)

  Methods:
    1. Fit PS step 1 logistic regression model (main effects only)
    2. Create PS quintile strata
    3. Fit PS-stratified outcome models
    4. Fit PS-regression outcome models
    5. Compare results with HW1, HW3, and HW4 estimates

  Requirements:
    1. Present PS step 1 model
    2. Present Table 1 by strata (column % by IVH status)
    3. Present two figures for stratification diagnostics
    4. Present Table 2 with unadjusted, adjusted, PS-matched, IPTW,
       PS-stratified, and PS-regression estimates

  Author: Xuange Liang
  Date: 2026-03-31
=============================================================================*/

/*-----------------------------------------------------------------------------
  STEP 0: Setup
-----------------------------------------------------------------------------*/

/* Modify this path to your actual data location */
%let projdir = /home/u64139022/P8586/HW5;
libname hw "&projdir";

ods _all_ close;
ods html path="&projdir"
         file="HW5_Analysis-results.html"
         gpath="&projdir"
         style=journal;

title  "HW5: Propensity Score Stratification and Regression";
title2 "IVH and Mortality in Very Low Birth Weight Infants";
title3 "Student: Xuange Liang | Date: 2026-03-31";

/*-----------------------------------------------------------------------------
  FORMATS
-----------------------------------------------------------------------------*/

proc format;
    value deadf      0='Alive'         1='Dead';
    value ivhf       0='No IVH'        1='IVH';
    value pneumof    0='No'            1='Yes';
    value twinf      0='Singleton'     1='Multiple';
    value deliveryf  1='C-Section'     2='Vaginal'     9='Unknown';
    value inoutf     1='Born at Duke'  2='Transport';
    value bwt_catf   1='<1000g'        2='1000-1299g'  3='1300-1599g';
    value gest_catf  1='<28 weeks'     2='28-31 weeks' 3='>=32 weeks';
run;

/*-----------------------------------------------------------------------------
  STEP 1: Data preparation
-----------------------------------------------------------------------------*/

data vlbw;
    set hw.hw_vlbw;

    IVH = ivh2;

         if bwt < 1000 then bwt_cat = 1;
    else if bwt < 1300 then bwt_cat = 2;
    else                    bwt_cat = 3;

         if gest < 28 then gest_cat = 1;
    else if gest < 32 then gest_cat = 2;
    else                   gest_cat = 3;
run;

/*=============================================================================
  SECTION 1: PS STEP 1 MODEL BUILDING
  Main-effects logistic regression model for IVH
=============================================================================*/

ods html text="^S={fontweight=bold fontsize=14pt}SECTION 1: PS STEP 1 MODEL BUILDING";

title "PS Model A: Logistic Regression - No Interaction Terms";
proc logistic data=vlbw plots(only)=roc;
    class pneumo       (ref='0')
          twin         (ref='0')
          delivery_new (ref='1')
          inout_new    (ref='1')
          bwt_cat      (ref='3')
          gest_cat     (ref='3') / param=ref;
    model IVH(event='1') =
          pneumo twin delivery_new inout_new bwt_cat gest_cat / lackfit;
    output out=ps_no_interaction predicted=propensity_score;
run;

/* Current run: C-statistic = 0.771 */

/*=============================================================================
  SECTION 2: CREATE FIVE PS QUINTILE STRATA
  Rank estimated PS into five groups of approximately equal size
=============================================================================*/

ods html text="^S={fontweight=bold fontsize=14pt}SECTION 2: CREATE FIVE PS QUINTILE STRATA";

proc rank data=ps_no_interaction out=ps_strata groups=5;
    var propensity_score;
    ranks ps_stratum0;
run;

data ps_strata;
    set ps_strata;
    ps_stratum = ps_stratum0 + 1;
run;

title "Table 1A: Propensity Score Range by Quintile Stratum";
proc means data=ps_strata min max mean n;
    class ps_stratum;
    var propensity_score;
run;

title "Table 1B: Exposure Distribution Across PS Quintile Strata";
proc freq data=ps_strata;
    tables ps_stratum*IVH / nopercent norow;
    format IVH ivhf.;
run;

/*=============================================================================
  SECTION 3: TABLE 1 - STRATIFIED BASELINE CHARACTERISTICS
  Present column percentages by IVH status within each PS stratum
=============================================================================*/

ods html text="^S={fontweight=bold fontsize=14pt}SECTION 3: TABLE 1 - STRATIFIED BASELINE CHARACTERISTICS";

proc sort data=ps_strata;
    by ps_stratum;
run;

title "Table 1C: Baseline Characteristics by IVH Status Within Each PS Quintile";
proc tabulate data=ps_strata;
    by ps_stratum;
    class IVH pneumo twin delivery_new inout_new bwt_cat gest_cat;
    format IVH ivhf. pneumo pneumof. twin twinf.
           delivery_new deliveryf. inout_new inoutf.
           bwt_cat bwt_catf. gest_cat gest_catf.;
    table pneumo twin delivery_new inout_new bwt_cat gest_cat,
          IVH * (n*f=8. colpctn='%') / box='';
run;

/*=============================================================================
  SECTION 4: FIGURES FOR PS STRATIFICATION
  Figure 1: distribution of patients across PS strata by IVH group
  Figure 2: PS distribution within each stratum by IVH group
=============================================================================*/

ods html text="^S={fontweight=bold fontsize=14pt}SECTION 4: FIGURES FOR PS STRATIFICATION";

ods graphics on;

title "Figure 1: Proportion of Patients at Each PS Stratum by Exposure Group";
proc freq data=ps_strata;
    tables ps_stratum*IVH / plots=freqplot(twoway=stacked scale=percent);
    format IVH ivhf.;
run;

title "Figure 2: Propensity Score Distribution by Stratum and Exposure Group";
proc sgpanel data=ps_strata;
    panelby ps_stratum / columns=3;
    vbox propensity_score / category=IVH;
    format IVH ivhf.;
    colaxis label="IVH Status";
    rowaxis label="Estimated Propensity Score";
run;

ods graphics off;

/*=============================================================================
  SECTION 5: PS STRATIFICATION OUTCOME MODELS
  OR from conditional logistic regression; RR from Poisson regression
=============================================================================*/

ods html text="^S={fontweight=bold fontsize=14pt}SECTION 5: PS STRATIFICATION OUTCOME MODELS";

title "Table 2A: PS-Stratified Adjusted OR - Conditional Logistic Regression";
proc logistic data=ps_strata;
    class IVH(ref='0') / param=ref;
    model dead(event='1') = IVH;
    strata ps_stratum;
run;
/* Current run: OR = 3.417 (95% CI: 1.973, 5.918) */

title "Table 2B: PS-Stratified Adjusted RR - Poisson Regression by PS Stratum";
proc genmod data=ps_strata;
    class IVH(ref='0') ps_stratum / param=ref;
    model dead(event='1') = IVH ps_stratum / dist=poisson link=log;
    estimate "IVH: Yes vs No" IVH 1 / exp;
run;
/* Current run: RR = 2.1786 (95% CI: 1.4152, 3.3539) */

/*=============================================================================
  SECTION 6: PS REGRESSION OUTCOME MODELS
  Adjust for estimated PS and PS-squared term
=============================================================================*/

ods html text="^S={fontweight=bold fontsize=14pt}SECTION 6: PS REGRESSION OUTCOME MODELS";

title "Table 2C: PS-Regression Adjusted OR - Logistic Model with PS and PS^2";
proc logistic data=ps_no_interaction;
    class IVH(ref='0') / param=ref;
    model dead(event='1') = IVH propensity_score propensity_score*propensity_score;
run;
/* Current run: OR = 3.383 (95% CI: 1.937, 5.909) */

title "Table 2D: PS-Regression Adjusted RR - Poisson Model with PS and PS^2";
proc genmod data=ps_no_interaction;
    class IVH(ref='0') / param=ref;
    model dead(event='1') = IVH propensity_score propensity_score*propensity_score
          / dist=poisson link=log;
    estimate "IVH: Yes vs No" IVH 1 / exp;
run;
/* Current run: RR = 2.1538 (95% CI: 1.3837, 3.3525) */

/*=============================================================================
  SECTION 7: SUPPORTING MODELS FOR TABLE 2
  Reproduce the HW1 estimates and carry forward HW3/HW4 values into report
=============================================================================*/

ods html text="^S={fontweight=bold fontsize=14pt}SECTION 7: SUPPORTING MODELS FOR TABLE 2";

title "Table 2E: Unadjusted Odds Ratio (HW1) - IVH and Mortality";
proc logistic data=vlbw;
    class IVH(ref='0') / param=ref;
    model dead(event='1') = IVH;
run;

title "Table 2F: Unadjusted Risk Ratio (HW1) - IVH and Mortality";
proc genmod data=vlbw;
    class IVH(ref='0') / param=ref;
    model dead(event='1') = IVH / dist=poisson link=log;
    estimate "IVH: Yes vs No" IVH 1 / exp;
run;

title "Table 2G: Adjusted Odds Ratio from HW1 Final Model";
proc logistic data=vlbw;
    class IVH(ref='0') pneumo(ref='0') bwt_cat(ref='3') gest_cat(ref='3') / param=ref;
    model dead(event='1') = IVH pneumo bwt_cat gest_cat;
run;

title "Table 2H: Adjusted Risk Ratio from HW1 Final Model";
proc genmod data=vlbw;
    class IVH(ref='0') pneumo(ref='0') bwt_cat(ref='3') gest_cat(ref='3') / param=ref;
    model dead(event='1') = IVH pneumo bwt_cat gest_cat / dist=poisson link=log;
    estimate "IVH: Yes vs No" IVH 1 / exp;
run;

/* Carry forward prior-homework estimates into the written Table 2:
   HW3 PS Matched OR = 3.86 (1.68, 8.86)
   HW3 PS Matched RR = 2.05 (1.35, 3.12)
   HW4 PS IPTW OR    = 3.34 (1.65, 6.76)
   HW4 PS IPTW RR    = 2.45 (1.53, 3.90)
*/

ods html close;

%put ===================================================;
%put HW5 Analysis Script Complete!;
%put Output: HW5_Analysis-results.html;
%put ===================================================;
