
libname a "E:\OneDrive - Columbia University Irving Medical Center\Desktop\Today_P8586";

*************************
Clean up dataset
*************************;

data UTERINE_CA1288_model;
set a.UTERINE_CA1288;

IF race   =. THEN race   = 9;
IF income =. THEN income = 9;
IF cdcc   =. THEN cdcc   = 9;
IF grade  =. THEN grade  = 9;
BMI = weight_kg/((height_cm/100)**2);
     if BMI < 25.0 then BMI_cat = 1;
else if 25.0 <= BMI <30.0 then BMI_cat = 2;
else if BMI >= 30.0 then BMI_cat =3;

/*Clean dataset for small cells*/
age_cat2 = age_cat;
if age_cat = 2 then age_cat2 = 1;
     if age_cat in (1,2) then age_cat3 = 1;
else if age_cat = 3 then age_cat3 = 2;
else if age_cat = 4 then age_cat3 = 3;
else if age_cat = 5 then age_cat3 = 4;
race2 = race;
if race = 3 then race2=4;
insurance2 = insurance;
if insurance = 0 then insurance2 = 2;
cdcc2 = cdcc;
if cdcc = 2 then cdcc2 = 1;
     if stage in (1,2,3) then stage2 = 1;
else if stage = 4 then stage2 = 2;
grade2 = grade;
if grade = 2 then grade2 = 1;
     if year_of_diagnosis <= 2004 then year_of_diagnosis_cat = 1;
else if 2005<=year_of_diagnosis <= 2007 then year_of_diagnosis_cat = 2;
else if 2008<=year_of_diagnosis <= 2009 then year_of_diagnosis_cat = 3;
else if 2010<=year_of_diagnosis <= 2011 then year_of_diagnosis_cat = 4;
run;/*1288 observations and 26 variables.*/


PROC FORMAT;
VALUE age_catf 1='41-49' 2='50-59' 3='60-69' 4='70-79' 5='80-89';
VALUE age_cat2f 1='41-59' 3='60-69' 4='70-79' 5='80-89';
VALUE age_cat3f 1='41-59' 2='60-69' 3='70-79' 4='80-89';
VALUE racef 1='White' 2='Black' 3='Hispanic' 4='Other' 9='Unknown';
VALUE race2f 1='White' 2='Black' 4='Other' 9='Unknown';
VALUE insurancef 0='Not Insured' 1='Private Insurance' 2='Medicaid' 3='Medicare'  9='Other/Unknown'; 
VALUE insurance2f 1='Private Insurance' 2='Medicaid/No insured' 3='Medicare'  9='Other/Unknown'; 
VALUE incomef 1='< $30,000' 2='$30,000 - $35,999' 3='$36,000 - $45,999' 4='$46,000 +' 9='Unknown';
VALUE cdccf 0='0' 1='1' 2='2' 9='Unknown';
VALUE cdcc2f 0='0' 1='>=1' 9='Unknown';
VALUE stagef 1='I' 2='IA' 3='IB' 4='II' ;
value stage2f 1='I' 2='II';
VALUE gradef 1='Well' 2='Moderate' 3='Poorly' 9='Unknown';
VALUE grade2f 1='Well/Moderate' 3='Poorly' 9='Unknown';
VALUE lndf 0='No' 1='Yes';
VALUE deathf 0='Alive' 1='Dead';
VALUE facility_locationf 1='Eastern' 2='South' 3='Midwest' 4='West';
VALUE facility_typef 1='Academic/Research Program'  0='Non-Academic program';
VALUE surgeryf 1='Yes' 0='No';
VALUE BMI_catf 1='Normal(<25.0)' 2='Overweight(25.0-29.9)' 3='Obese(>=30)';
value year_of_diagnosis_catf 1="1998-2004" 2="2005-2007" 3="2008-2009" 4="2010-2011";
value surgery 0 = "No" 1 = "Yes";
run;

%let var_format = age_cat age_catf. race racef. insurance insurancef. income incomef. cdcc cdccf. stage stagef. 
              grade gradef. lnd lndf. death deathf. facility_location facility_locationf.
              facility_type facility_typef. facility_type facility_typef. surgery surgeryf. BMI_cat BMI_catf.
			  /*New variable*/
              age_cat2 age_cat2f. age_cat3 age_cat3f. race2 race2f. insurance2 insurance2f. cdcc2 cdcc2f. stage2 stage2f. grade2 grade2f.
			  year_of_diagnosis_cat year_of_diagnosis_catf.
			  /*other treatment variable*/
			  lnd lndf.;

%let baseline_factor2 = age_cat2 race2 insurance2 income BMI_cat cdcc2 stage2 grade2 
                        facility_location facility_type year_of_diagnosis_cat;

/*
Study qustion:
Is there association between surgery and dead?
Exposure: surgery; 
Outcome: dead
*/

*************************************************
Propensity Score Step 1 Logistic Regression Model
*************************************************;

*Include all baseline factors (pre-treatment factors);

*1) No INTERACTION term;

proc logistic data = UTERINE_CA1288_MODEL plots(only)=roc;
format cdcc2 cdcc2f. year_of_diagnosis_cat year_of_diagnosis_catf. stage2 stage2f. 
       facility_type facility_typef. age_cat2 age_cat2f. insurance2 insurance2f. 
       race2 race2f. income incomef. lnd lndf. grade2 grade2f. 
       BMI_cat BMI_catf. facility_location facility_locationf.;
class cdcc2(ref='0') year_of_diagnosis_cat(ref='1998-2004') stage2(ref='I') 
      facility_type(ref='Academic/Research Program') age_cat2(ref='41-59') 
      insurance2 (ref='Private Insurance') race2 (ref='White') income (ref='< $30,000')
	  grade2(ref='Well/Moderate') BMI_cat(ref='Normal(<25.0)') 
      facility_location(ref='Eastern')/ param=ref;
model surgery (event='1') = cdcc2 year_of_diagnosis_cat stage2 facility_type age_cat2 
                            insurance2 race2 income grade2 BMI_cat facility_location/lackfit;
output out=ps_no_interaction predicted=propensity_score;   
/*OUTPUT DATASET WITH PREDICTED PROBALITY AS PROPENSITY SCORE*/
run;
proc print data = ps_no_interaction (obs=20);
var surgery  propensity_score;
run;
/*
NOTE: PROC LOGISTIC is modeling the probability that surgery=1.
NOTE: Convergence criterion (GCONV=1E-8) satisfied.
NOTE: There were 1288 observations read from the data set WORK.UTERINE_CA1288_MODEL.
NOTE: The data set WORK.PS_NO_INTERACTION has 1288 observations and 30 variables.
NOTE: PROCEDURE LOGISTIC used (Total process time):
      real time           0.08 seconds
      cpu time            0.07 seconds
*/

/*
C-Statistics (Area under the curve) = 0.725 
Hosmer and Lemeshow Goodness-of-Fit Test P = 0.8742
*/

proc print data = ps_no_interaction (obs=10);
where surgery=1;
run; /*check propensity score among patients who underwent surgery*/
proc print data = ps_no_interaction (obs=10);
where surgery=0;
run; /*check propensity score among patients who did not undergo surgery*/


*2) Any Two-way INTERACTION term;

proc logistic data = UTERINE_CA1288_MODEL;
format cdcc2 cdcc2f. year_of_diagnosis_cat year_of_diagnosis_catf. stage2 stage2f. 
       facility_type facility_typef. age_cat2 age_cat2f. insurance2 insurance2f. 
       race2 race2f. income incomef. lnd lndf. grade2 grade2f. 
       BMI_cat BMI_catf. facility_location facility_locationf.;
class cdcc2(ref='0') year_of_diagnosis_cat(ref='1998-2004') stage2(ref='I') 
      facility_type(ref='Academic/Research Program') age_cat2(ref='41-59') 
      insurance2 (ref='Private Insurance') race2 (ref='White') income (ref='< $30,000')
	  grade2(ref='Well/Moderate') BMI_cat(ref='Normal(<25.0)') 
      facility_location(ref='Eastern')/ param=ref;
model surgery (event='1') = cdcc2|year_of_diagnosis_cat|stage2|facility_type|age_cat2|
                            insurance2|race2|income|grade2|BMI_cat|facility_location@2/lackfit;
output out=ps_any2_interaction predicted=propensity_score;   
/*OUTPUT DATASET WITH PREDICTED PROBALITY AS PROPENSITY SCORE*/
run;
/*
NOTE: PROC LOGISTIC is modeling the probability that surgery=1.
WARNING: There is possibly a quasi-complete separation of data points. The maximum likelihood
         estimate may not exist.
WARNING: The LOGISTIC procedure continues in spite of the above warning. Results shown are
         based on the last maximum likelihood iteration. Validity of the model fit is
         questionable.
*/

*3) Any Two-way INTERACTION term with BACKWARD ELIMINATION SLS = 0.20;
/*A significance level of 0.20 is required for a variable to stay in the model;*/

proc logistic data = UTERINE_CA1288_MODEL plots(only)=roc;
format cdcc2 cdcc2f. year_of_diagnosis_cat year_of_diagnosis_catf. stage2 stage2f. 
       facility_type facility_typef. age_cat2 age_cat2f. insurance2 insurance2f. 
       race2 race2f. income incomef. lnd lndf. grade2 grade2f. 
       BMI_cat BMI_catf. facility_location facility_locationf.;
class cdcc2(ref='0') year_of_diagnosis_cat(ref='1998-2004') stage2(ref='I') 
      facility_type(ref='Academic/Research Program') age_cat2(ref='41-59') 
      insurance2 (ref='Private Insurance') race2 (ref='White') income (ref='< $30,000')
	  grade2(ref='Well/Moderate') BMI_cat(ref='Normal(<25.0)') 
      facility_location(ref='Eastern')/ param=ref;
model surgery (event='1') = cdcc2|year_of_diagnosis_cat|stage2|facility_type|age_cat2|
                            insurance2|race2|income|grade2|BMI_cat|facility_location@2
                            /selection=backward slstay=0.20 lackfit;
output out=ps_any2b_interaction predicted=propensity_score;   
/*OUTPUT DATASET WITH PREDICTED PROBALITY AS PROPENSITY SCORE*/
run;
/*
NOTE: Convergence criterion (GCONV=1E-8) satisfied in Step 30.
NOTE: Under full-rank parameterizations, Type 3 effect tests are replaced by joint tests. The
      joint test for an effect is a test that all the parameters associated with that effect
      are zero. Such joint tests might not be equivalent to Type 3 effect tests under GLM
      parameterization.
NOTE: There were 1288 observations read from the data set WORK.UTERINE_CA1288_MODEL.
NOTE: The data set WORK.PS_ANY2_INTERACTION has 1288 observations and 30 variables.
NOTE: PROCEDURE LOGISTIC used (Total process time):
      real time           4.67 seconds
      cpu time            4.59 seconds
*/
/*C-statistics = 0.779; Hosmer and Lemeshow Goodness-of-Fit Test P = 0.8311*/

*************************************************************************
We need to decide between PS step 1 model without interaction term 
   and with any two-ways interaction term slstay=0.2
It seems like the latter has a better C-statistics, 
both have acceptable Hosmer and Lemeshow Goodness-of-Fit Test.
Final decision is based on balance statistics. 
************************************************************************;

***************************************
*Method 1: PS - Greedy 5 to 1 Matching;
***************************************;

*(1) PS no-interation term model;

*(1-1) Create required variables for macro;

data A.ps_no_interaction_2;
set ps_no_interaction;
*variables required for macro: patient identifier named PATIENTN, hospital identifier variable named HID;
        prob=propensity_score;
        PATIENTN=_n_;
        HID = 1;
run; /*1288 observations and 33 variables*/

*(1-2) call in macro;
%let PATH = E:\OneDrive - Columbia University Irving Medical Center\Desktop\Today_P8586;
%include "&PATH\GREEDMTCH.sas";
option mprint;
%GREEDMTCH
       (A, 	   /* Library Name */
        ps_no_interaction_2,   /* Data set of all patients*/
        Surgery,    /* Dependent variable that indicates Case or Control; Code 1 for Cases, 0 for Controls*/
        Greedy_matching_1    /* Output file of matched pairs*/
       );
*NOTE: There were 100 observations read from the data set A.MATCH5.
NOTE: There were 56 observations read from the data set A.MATCH4.
NOTE: There were 318 observations read from the data set A.MATCH3.
NOTE: There were 300 observations read from the data set A.MATCH2.
NOTE: There were 42 observations read from the data set A.MATCH1.
NOTE: The data set A.GREEDY_MATCHING_1 has 816 observations and 34 variables.;

*(1-3) Check Balance Statistics (Standarized Difference);
%let PATH = E:\OneDrive - Columbia University Irving Medical Center\Desktop\Today_P8586;
%include "&PATH\Standardized_Difference.sas";
%let char = age_cat2 race2 insurance2 income BMI_cat cdcc2 stage2 grade2 
            facility_location facility_type year_of_diagnosis_cat;

/*PS-1 no interaction model*/
%stddiff( inds = A.GREEDY_MATCHING_1,                        /*Data set Name*/
     groupvar = surgery,                                     /*Treatment variable*/
     numvars = ,                                             /*Continuous variables*/
     charvars = &char.,                                      /*Categorical varaibles*/
     wtvar = ,
     stdfmt = 8.4,
     outds = stddiff_result ); 

*(2) PS any two-way interation term model with slstay = 0.2;

*(2-1) Create required variables for macro;
data A.ps_any2b_interaction_2;
set ps_any2b_interaction;
*variables required for macro: patient identifier named PATIENTN, hospital identifier variable named HID;
        prob=propensity_score;
        PATIENTN=_n_;
        HID = 1;
run; /*1288 observations and 33 variables*/

*(2-2) call in macro;
%GREEDMTCH
       (A, 	   /* Library Name */
        ps_any2b_interaction_2,   /* Data set of all patients*/
        Surgery,    /* Dependent variable that indicates Case or Control; Code 1 for Cases, 0 for Controls*/
        Greedy_matching_2    /* Output file of matched pairs*/
       );
*NOTE: There were 158 observations read from the data set A.MATCH5.
NOTE: There were 42 observations read from the data set A.MATCH4.
NOTE: There were 252 observations read from the data set A.MATCH3.
NOTE: There were 246 observations read from the data set A.MATCH2.
NOTE: There were 30 observations read from the data set A.MATCH1.
NOTE: The data set A.GREEDY_MATCHING_2 has 728 observations and 34 variables.;

*(2-3) Check Balance Statistics (Standarized Difference);
%stddiff( inds = A.Greedy_matching_2,                        /*Data set Name*/
     groupvar = surgery,                                     /*Treatment variable*/
     numvars = ,                                             /*Continuous variables*/
     charvars = &char.,                                      /*Categorical varaibles*/
     wtvar = ,
     stdfmt = 8.4,
     outds = stddiff_result ); 

/*We decide to choose PS model w/o interaction terms for the overall balance it creates*/

*(3)Check PS distribution before & after matching;

*Histograms with frequency curve and normal curves;
*Original cohort (n=1288);
proc sort data=A.ps_no_interaction_2;by surgery;run;
proc sgplot data=A.ps_no_interaction_2;
        histogram propensity_score;
        density propensity_score /type=normal;
        density propensity_score /type=kernel;
		by surgery;
        run; 
proc means data=A.ps_no_interaction_2 n nmiss mean p50;
var prob;
class surgery;
run;

*Matched cohort (n=816);
proc sort data= A.GREEDY_MATCHING_1;by surgery;run;
proc sgplot data=A.GREEDY_MATCHING_1;
        histogram propensity_score;
        density propensity_score /type=normal;
        density propensity_score /type=kernel;
		by surgery;
        run; 
proc means data=A.GREEDY_MATCHING_1 mean p50;
var prob;
class surgery;
run;

*Box Plot;
*Original cohort (n=1288);	
proc sort data=A.ps_any2b_interaction_2;by surgery;run;
proc boxplot data=A.ps_any2b_interaction_2;
symbol width = 2;
plot propensity_score*surgery/
cboxes=black
cframe = white
idsymbol = circle
idcolor = black
font='times new roman' height=3.5
boxwidth=6
boxstyle=schematic
waxis = 2;
run;
*Matched cohort (n=728);
proc sort data=A.Greedy_matching_1;by surgery;run;
proc boxplot data=A.Greedy_matching_1;
symbol width = 2;
plot prob*surgery/
cboxes=black
cframe = white
idsymbol = circle
idcolor = black
font='times new roman' height=3.5
boxwidth=6
boxstyle=schematic
waxis = 2;
run;

*(4) Create Table 1 for original cohort and PS matched cohort;

/*Table 1 for original cohort*/
proc tabulate data = A.ps_no_interaction_2;
format &var_format.;
class  surgery &baseline_factor2.;
table &baseline_factor2., 
      surgery*(n*f=8. colpctn='%')/box='';
run;
proc freq data = A.ps_no_interaction_2;
format &var_format.;
table (&baseline_factor2.)* 
      surgery/chisq;
run;
%stddiff( inds = A.ps_no_interaction_2,                        /*Data set Name*/
     groupvar = surgery,                                     /*Treatment variable*/
     numvars = ,                                             /*Continuous variables*/
     charvars = &char.,                                      /*Categorical varaibles*/
     wtvar = ,
     stdfmt = 8.4,
     outds = stddiff_result ); 

/*Table 1 for matched cohort based on PS model without interaction term */
proc tabulate data = A.GREEDY_MATCHING_1;
format &var_format.;
class  surgery &baseline_factor2.;
table &baseline_factor2., 
      surgery*(n*f=8. colpctn='%')/box='';
run;
proc freq data = A.GREEDY_MATCHING_1;
format &var_format.;
table (&baseline_factor2.)* 
      surgery/chisq;
run;
%stddiff( inds = A.GREEDY_MATCHING_1,                        /*Data set Name*/
     groupvar = surgery,                                     /*Treatment variable*/
     numvars = ,                                             /*Continuous variables*/
     charvars = &char.,                                      /*Categorical varaibles*/
     wtvar = ,
     stdfmt = 8.4,
     outds = stddiff_result ); 

*(5) PS matched outcome model;
proc logistic data=A.Greedy_matching_1 ;
format Surgery Surgery.;
class surgery (ref='No')/param=ref;
model death (event='1') =  Surgery;
strata matchto;
run; /*aOR=0.522 95%CI: 0.349-0.781*/

proc genmod data=A.Greedy_matching_1 ;
format Surgery Surgery.;
class surgery (ref='No')/param=ref;
class matchto;
model death (event='1') =  Surgery/dist=Poisson link=log;
repeated subject = matchto;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aRR=0.621 95%CI: 0.463-0.832 */


******************************************************
*PSMATCH;
******************************************************;
data UTERINE_CA1288_model2;
set UTERINE_CA1288_model;

	 /*Switch to binary covariates*/
     age_59    = (age_cat3   = 1);
     age_cat3_6069     = (age_cat3   = 2); /*if age_cat3 = 2 then age_cat3_6069 = 1; else age_cat3_6069 = 0;*/
     age_cat3_7079     = (age_cat3   = 3);
     age_cat3_8089     = (age_cat3   = 4);

     RACE1       = (race2   = 1);
     RACE_Black       = (race2   = 2);
     RACE_OTHER       = (race2   = 4);
     RACE_UNKNOWN     = (race2   = 9);

     INSU_Medicaid  = (insurance2    = 2);
     INSU_Medicare  = (insurance2    = 3);
     INSU_Oth       = (insurance2    = 9);

     Income_30000    = (income  = 2);
     Income_36000    = (income  = 3);
     Income_46000    = (income  = 4);
     Income_Unknown  = (income  = 9);

     CDCC_1       = (cdcc2    = 1);
     CDCC_unk     = (cdcc2    = 9);

     stage2_2    = (stage2 = 2);

     grade2_3    = (grade2 = 3);
     grade2_9    = (grade2 = 9);

	 facility_location_South     = (facility_location  = 2);
     facility_location_Midwest   = (facility_location  = 3);
     facility_location_West      = (facility_location  = 4);

     facility_type_Academic      = (facility_type    = 1);
     
	 year_of_diagnosis_cat_2   = (year_of_diagnosis_cat  = 2);
     year_of_diagnosis_cat_3   = (year_of_diagnosis_cat  = 3);
     year_of_diagnosis_cat_4   = (year_of_diagnosis_cat  = 4);

run;

proc contents data = UTERINE_CA1288_model2 varnum;run;
	 
%let COVARS   = age_cat3_: RACE_: INSU_: Income_: CDCC_: stage2_: grade2_: facility_location_: 
                facility_type_: year_of_diagnosis_cat_:;

proc freq data = UTERINE_CA1288_model2;
table age_cat3_: RACE_: INSU_: Income_: CDCC_: stage2_: grade2_: facility_location_: 
                facility_type_: year_of_diagnosis_cat_:;
run;


*Ex1: Greedy Nearest Neighbor Matching;

ods graphics on;
proc psmatch data = UTERINE_CA1288_model2 region=treated;
  class &COVARS. surgery;
  psmodel surgery (treated='1')= &COVARS.;
  match method=greedy(k=1) stat=lps caliper=0.25;   /*lps = logit of propensity score*/
  assess lps var=(&COVARS.)/plots=all weight=none;
  output out(obs=match)=OutEx1 matchid=MatchID;
run;
ods graphics off;
/*
WORK.OUTEX1 has 888 observations and 55 variables (caliper = 0.25)
*/
proc sort data = OutEx1;by MatchID;run;
proc freq data = OutEx1;table MatchID;run;
proc print data = OutEx1 (obs=20);run;

proc logistic data=OutEx1 ;
class surgery (ref='0')/param=ref;
model death (event='1') =  Surgery;
strata matchID;
run; /*aOR=0.488 95%CI: 0.338-0.706*/ 
proc genmod data=OutEx1;
class surgery (ref='0') matchID/param=ref;
class matchID;
model death (event='1') =  Surgery/dist=Poisson link=log;
repeated subject = matchID;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aOR=0.537 95%CI: 0.390-0.738*/

%let baseline_factor3   =  age_59  age_cat3_: RACE1 RACE_: INSU_: Income_: CDCC_: stage2_: grade2_: facility_location_: 
                facility_type_: year_of_diagnosis_cat_:;


proc tabulate data = OutEx1;
class  surgery &baseline_factor3.;
table &baseline_factor3., 
      surgery*(n*f=8. colpctn='%')/box='';
run;
proc freq data = OutEx1;
format &var_format.;
table (&baseline_factor3.)* 
      surgery/chisq;
run;


******************************************************
*Homework 4                                          *
*Method 2: Inverse Probability of Treatment Weighting ;
******************************************************;

******************
IPTW for ATE
******************;

*(1)Calculate IPTW weight;
data ps_IPTW1;
set ps_no_interaction;
if surgery=1 then ATE_IPTW=1/propensity_score;
else if surgery=0 then ATE_IPTW=1/(1-propensity_score);
run;

data ps_IPTW2;
set ps_any2b_interaction;
if surgery=1 then ATE_IPTW=1/propensity_score;
else if surgery=0 then ATE_IPTW=1/(1-propensity_score);
run;

*(2)Balance Diagnostics to Choose PS Model;

%stddiff( inds = ps_IPTW1, /*Data set Name*/
     groupvar = surgery,  /*Treatment variable*/
     numvars = ,          /*Continuous variables*/
     charvars = &char.,   /*Categorical varaibles*/
     wtvar = ATE_IPTW,
     stdfmt = 8.4,
     outds = stddiff_result ); 

%stddiff( inds = ps_IPTW2, /*Data set Name*/
     groupvar = surgery,  /*Treatment variable*/
     numvars = ,          /*Continuous variables*/
     charvars = &char.,   /*Categorical varaibles*/
     wtvar = ATE_IPTW,
     stdfmt = 8.4,
     outds = stddiff_result ); 

/*Choose the PS step 1 model based on smallest SMD and consistency with PS matching if multiple PS methods are involved*/

*(3)Check PS and IPTW weights distribution;
proc sgplot data=ps_IPTW1;
format surgery surgery.;
scatter x=propensity_score y=ATE_IPTW / group=surgery;
TITLE "Scatter Plot of Weight vs. Propensity Score by Surgery (ATE)";
XAXIS LABEL="Propensity Score";
YAXIS LABEL="IPTW Weight";
KEYLEGEND / TITLE="Surgery Type";
run;
proc sort data = ps_IPTW1; by surgery;run;
proc print data=ps_IPTW1 noobs;
var surgery propensity_score ATE_IPTW;
run;
proc means data =  ps_IPTW1 mean std median p25 p75 min max maxdec=2;
var ATE_IPTW;
class surgery;
run;
proc means data =  ps_IPTW1 mean std median p25 p75 min max maxdec=2;
var ATE_IPTW;
run;

*(4)Create PS-IPTW table 1;
proc freq data = ps_IPTW1;
format &var_format.;
weight ATE_IPTW;
table (&baseline_factor2.)*surgery/nopercent norow chisq;
run;

*(5) PS-IPTW ATE outcome model;
data ps_IPTW1;set ps_IPTW1;pat_id = _n_;run; 

proc genmod data=ps_IPTW1;
format surgery surgery.;
class Surgery (ref='No')/param=ref;
class pat_id;
model death (event='1') =  Surgery/dist=bin link=logit;
weight ATE_IPTW;
repeated subject=pat_id;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aOR=0.3514 95%CI: 0.2777 0.4330 */

proc genmod data=ps_IPTW1;
format surgery surgery.;
class Surgery (ref='No')/param=ref;
class pat_id;
model death (event='1') =  Surgery/dist=poisson link=log;
weight ATE_IPTW;
repeated subject=pat_id;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aRR=0.5954 95%CI: 0.4447-0.7972*/


******************
IPTW for ATT
******************;

*(1)Calculate IPTW weight;
data ps_IPTW1_ATT;
set ps_no_interaction;
if surgery=1 then ATT_IPTW=1;
else if surgery=0 then ATT_IPTW=propensity_score/(1-propensity_score);
run;

data ps_IPTW2_ATT;
set ps_any2b_interaction;
if surgery=1 then ATT_IPTW=1;
else if surgery=0 then ATT_IPTW=propensity_score/(1-propensity_score);
run;

*(2)Balance Diagnostics to Choose PS Model;

%stddiff( inds = ps_IPTW1_ATT, /*Data set Name*/
     groupvar = surgery,  /*Treatment variable*/
     numvars = ,          /*Continuous variables*/
     charvars = &char.,   /*Categorical varaibles*/
     wtvar = ATT_IPTW,
     stdfmt = 8.4,
     outds = stddiff_result ); 

%stddiff( inds = ps_IPTW2_ATT, /*Data set Name*/
     groupvar = surgery,  /*Treatment variable*/
     numvars = ,          /*Continuous variables*/
     charvars = &char.,   /*Categorical varaibles*/
     wtvar = ATT_IPTW,
     stdfmt = 8.4,
     outds = stddiff_result ); 

/*Choose the PS step 1 model based on smallest SMD*/

*(3)Check PS and IPTW ATT weights distribution;
proc sgplot data=ps_IPTW1_ATT;
format surgery surgery.;
scatter x=propensity_score y=ATT_IPTW / group=surgery;
TITLE "Scatter Plot of Weight vs. Propensity Score by Surgery (ATT)";
XAXIS LABEL="Propensity Score";
YAXIS LABEL="IPTW Weight";
KEYLEGEND / TITLE="Surgery Type";
run;
proc sort data = ps_IPTW1_ATT; by surgery;run;
proc print data=ps_IPTW1_ATT noobs;
var surgery propensity_score ATT_IPTW;
run;
proc means data =  ps_IPTW1_ATT mean std median p25 p75 min max maxdec=2;
var ATT_IPTW;
class surgery;
run;

*(4)Create PS-IPTW ATT table 1;
proc freq data = ps_IPTW1_ATT;
format &var_format.;
weight ATT_IPTW;
table (&baseline_factor2.)*surgery/nopercent norow chisq;
run;

*(4) PS IPTW ATT outcome model;

data ps_IPTW1_ATT;set ps_IPTW1_ATT;pat_id = _n_;run; 

proc genmod data=ps_IPTW1_ATT;
format surgery surgery.;
class Surgery (ref='No')/param=ref;
class pat_id;
model death (event='1') =  Surgery/dist=bin link=logit;
weight ATT_IPTW;
repeated subject=pat_id;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aOR=0.351 95%CI: 0.2741-0.4364 */

proc genmod data=ps_IPTW1_ATT;
format surgery surgery.;
class Surgery (ref='No')/param=ref;
class pat_id;
model death (event='1') =  Surgery/dist=poisson link=log;
weight ATT_IPTW;
repeated subject=pat_id;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aRR=0.586 95%CI: 0.4299-0.7988 */


******************
PSMATCH FOR IPTW
******************;

****************
      ATT
****************;

proc psmatch data = ps_no_interaction;
  class &char. surgery;
  psmodel surgery (treated='1')= &char.;
  psweight weight=wt_att / treat=surgery estimand=ATT;
  assess lps var=(&char.)/plots=all weight=wt_att;/*lps = logit of propensity score*/
  output out=OutEx1a ps=_ps weight=wt_att;
run;
proc print data = OutEx1a (obs=20);run; /*wt_att*/

proc psmatch data = ps_any2b_interaction;
  class &char. surgery;
  psmodel surgery (treated='1')= &char.;
  psweight weight=wt_att / treat=surgery estimand=ATT;
  assess lps var=(&char.)/plots=all weight=wt_att;/*lps = logit of propensity score*/
  output out=OutEx1b ps=_ps weight=wt_att;
run;
proc print data = OutEx1b (obs=20);run; /*wt_att*/

*(2)Balance Diagnostics to Choose PS Model;

%stddiff( inds = OutEx1a, /*Data set Name*/
     groupvar = surgery,  /*Treatment variable*/
     numvars = ,          /*Continuous variables*/
     charvars = &char.,   /*Categorical varaibles*/
     wtvar = wt_att,
     stdfmt = 8.4,
     outds = stddiff_result ); 

%stddiff( inds = OutEx1b, /*Data set Name*/
     groupvar = surgery,  /*Treatment variable*/
     numvars = ,          /*Continuous variables*/
     charvars = &char.,   /*Categorical varaibles*/
     wtvar = wt_att,
     stdfmt = 8.4,
     outds = stddiff_result ); 

/*Choose the PS step 1 model based on smallest SMD*/

*(3)Check PS and IPTW weights distribution;
proc sgplot data=OutEx1a;
format surgery surgery.;
scatter x=propensity_score y=wt_att / group=surgery;
TITLE "Scatter Plot of Weight vs. Propensity Score by Surgery (ATT)";
XAXIS LABEL="Propensity Score";
YAXIS LABEL="IPTW Weight";
KEYLEGEND / TITLE="Surgery Type";
run;
proc means data = OutEx1a mean std median p25 p75 min max maxdec=2;
var wt_att;
class surgery;
run;

*(4)Create PS-IPTW table 1;
proc freq data = OutEx1a;
format &var_format.;
weight wt_att;
table (&baseline_factor2.)*surgery/nopercent norow chisq;
run;

*(5) PS-IPTW ATT outcome model;
data OutEx1a;set OutEx1a;pat_id = _n_;run; 

proc genmod data = OutEx1a;
format surgery surgery.;
class Surgery (ref='No')/param=ref;
class pat_id;
model death (event='1') =  Surgery/dist=bin link=logit;
weight wt_att;
repeated subject=pat_id;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aOR=0.3510 95%CI: 0.2741 0.4364*/ /*0.35 (0.27-0.44)*/

proc genmod data = OutEx1a;
format surgery surgery.;
class Surgery (ref='No')/param=ref;
class pat_id;
model death (event='1') =  Surgery/dist=poisson link=log;
weight wt_att;
repeated subject=pat_id;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aRR=0.5860 95%CI: 0.4299 0.7988*/


***********************************
         ATE need more work 
***********************************;

proc freq data = ps_no_interaction;
table surgery;
run;

proc psmatch data=ps_no_interaction;
  class &char. surgery;
  psmodel surgery(treated='1') = &char.;
  psweight weight=wt_ate / treat=surgery estimand=ATE;
  assess lps var=(&char.) / plots=all weight=wt_ate;
  output out=OutEx2a ps=_ps weight=wt_ate;
run;
proc print data = OutEx2a (obs=20);run; 
proc print data=OutEx2a(obs=20);
  var surgery _ps wt_ate;
run;


***********************************
*Homework 5                       *
*PS Stratification                *
***********************************;

*(1) Create PS stratum variable( groups dependent on sample size);
proc rank data=ps_no_interaction out=ps_no_interaction_stra5 groups=5; 
 var propensity_score;
 ranks ps_pred_rank;
run; 
proc print data = ps_no_interaction_stra5 (obs = 20);run;
proc freq data = ps_no_interaction_stra5;
table ps_pred_rank;
run;

*(2)Check the distribution of PS at each stratum ;
proc means data=ps_no_interaction_stra5 min max;
 var propensity_score;
 class ps_pred_rank;
run;
proc means data=ps_no_interaction_stra5;
 var propensity_score;
 class ps_pred_rank surgery;
run;
proc freq data=ps_no_interaction_stra5;
table surgery*ps_pred_rank/nopercent nocol;
run;

*(3) Distribution of selected characteristics by surgery at each quintile stratum;
proc tabulate data = ps_no_interaction_stra5;
format race2 race2f. cdcc2 cdcc2f. stage2 stage2f. 
       facility_type facility_typef. 
       facility_location facility_locationf.;
class  ps_pred_rank surgery race2 cdcc2 Stage2 facility_location facility_type;
table race2 cdcc2 Stage2 facility_location facility_type, 
      ps_pred_rank*surgery*(n*f=8. colpctn='%')/box='';
run;

*(4) Outcome Model for PS stratification ; 
proc logistic data=ps_no_interaction_stra5;
 format surgery surgery.;
 class surgery (ref='No')/param=ref;
model death (event='1') =  surgery ;
strata ps_pred_rank;
run;/*aOR = 0.533 95%CI: 0.380-0.747*/

proc genmod data = ps_no_interaction_stra5;
format Surgery Surgery.;
class surgery (ref='No')/param=ref;
model death (event='1')=Surgery ps_pred_rank
                    /dist=Poisson link=log;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aRR = 0.599 95%CI:0.441-0.815 */

/*Further adjusting for PS in each stratum*/
proc logistic data = ps_no_interaction_stra5;
 format surgery surgery.;
 class surgery (ref='No')/param=ref;
model death (event='1') =  surgery propensity_score;
strata ps_pred_rank;
run;/*aOR = 0.538 95%CI: 0.383-0.755 */

proc genmod data = ps_no_interaction_stra5;
format Surgery Surgery.;
class surgery (ref='No')/param=ref;
model death (event='1')=Surgery propensity_score ps_pred_rank
                    /dist=Poisson link=log;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run; /*aRR = 0.606 95%CI:0.447-0.826*/


***********************************
*Homework 5                       *
*PS Regression                    *
***********************************;
proc logistic data=ps_no_interaction;
 format surgery surgery.;
 class surgery (ref='No')/param=ref;
model death (event='1') =  surgery propensity_score propensity_score*propensity_score;
run;/*aOR = 0.536, 95%CI:0.382-0.752*/
/*Restricted Cubic Spline*/
proc logistic data=ps_no_interaction;
 format surgery surgery.;
 class surgery (ref='No')/param=ref;
 effect spl_ps = spline(propensity_score / naturalcubic basis=tpf(noint) knotmethod=percentiles(5));
model death (event='1') =  surgery spl_ps;
run;/*aOR = 0.534, 95%CI:0.381-0.750*/
/* WORK.PS_NO_INTERACTION_SPLINE has 1288 observations and 30 variables.*/

proc genmod data=ps_no_interaction;
 format surgery surgery.;
 class surgery (ref='No')/param=ref;
model death (event='1') =  surgery propensity_score propensity_score*propensity_score;
estimate "Surgery No"    surgery 0/exp;
estimate "Surgery Yes"   surgery 1/exp;
run;/*aRR = 0.923, 95%CI:0.885-0.962*/






