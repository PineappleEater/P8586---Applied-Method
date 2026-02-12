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

*********************
*Unadjusted Analysis*
*********************;

/*(1-1) Univariate Logistic regression model. */
proc format;
value surgery 0 = "No" 1 = "Yes";
run;
proc logistic data = UTERINE_CA1288;
format surgery surgery. ;
    class surgery (ref='Yes') / param=ref;
	model death (event='1') = surgery;
run;
/*surgery No vs Yes: OR=2.855 95%CI: 2.091 - 3.898 */

proc logistic data = UTERINE_CA1288;
format surgery surgery. ;
    class surgery (ref='No') / param=ref;
	model death (event='1') = surgery;
run;
/*surgery Yes vs No: OR=0.350 95%CI: 0.257 - 0.478*/

proc logistic data = UTERINE_CA1288 descending;
format surgery surgery. ;
    class surgery (ref='No') / param=ref;
	model death = surgery;
run;

/*(1-2) Univariate log-linear model with Poisson distribution*/
proc genmod data = UTERINE_CA1288;
    class surgery (ref='0') / param=ref;
	model death (event='1')  = surgery/dist=poisson link=log type3 wald;
	estimate "Surgery No"               surgery     0 /exp ;
    estimate "Surgery Yes"              Surgery     1 /exp ;
run;
/*Surgery Yes vs No : RR=0.4143 , 95%CI 0.3113 - 0.5515 */

proc genmod data = UTERINE_CA1288;
    class surgery (ref='1') / param=ref;
	model death (event='1') = surgery/dist=poisson link=log type3 wald;
	estimate "Surgery No"               surgery     1 /exp ;
    estimate "Surgery Yes"              Surgery     0 /exp ;
run;
/*Surgery No vs. Yes: RR=2.4135 , 95%CI 1.8133 3.2125 */


**************************
*Multivariable Regression*
**************************;

proc freq data = UTERINE_CA1288_model;
format &var_format.;
table (&baseline_factor2.)*surgery/nopercent norow chisq; /*Evaluate association between baseline factors and treamtent*/
table (&baseline_factor2.)*death/nopercent nocol chisq;   /*Evaluate association between baseline factors and outcome*/
run;

proc tabulate data = UTERINE_CA1288_MODEL;
format &var_format.;
class  surgery &baseline_factor2.;
table &baseline_factor2., 
      surgery*(n*f=8. colpctn='%')/box='';
run;

proc tabulate data = UTERINE_CA1288_MODEL;
format &var_format.;
class  death &baseline_factor2.;
table &baseline_factor2., 
      death*(n*f=8. rowpctn='%')/box='';
run;

*(4-1) Variable Selection Based on Science;
/*Based on science, prior studies, and/or the principles from the prior lecture (confounding, collinearity, etc.), 
choose the predictors and covariates that you believe are necessary, and run the multiple regression model.  */

proc logistic data = UTERINE_CA1288_MODEL;
format surgery surgeryf. ;
format cdcc2 cdcc2f. year_of_diagnosis_cat year_of_diagnosis_catf. stage2 stage2f. facility_type facility_typef.
       age_cat2 age_cat2f. insurance2 insurance2f. race2 race2f. income incomef. lnd lndf. grade2 grade2f. 
       BMI_cat BMI_catf. facility_location facility_locationf.;
class surgery (ref='No') / param=ref;
class cdcc2(ref='0') year_of_diagnosis_cat(ref='1998-2004') stage2(ref='I') facility_type(ref='Academic/Research Program')
      age_cat2(ref='41-59') insurance2 (ref='Private Insurance')
	  race2 (ref='White') income (ref='< $30,000')
	  grade2(ref='Well/Moderate') BMI_cat(ref='Normal(<25.0)') facility_location(ref='Eastern')/ param=ref;
model death (event='1') = surgery
                          cdcc2 year_of_diagnosis_cat stage2 facility_type /*Factors associated with both treatment and outcome*/
                          age_cat2 insurance2 /*Factors associated with outcome only*/
						  race2 income /*Factors associated with treatment only*/
						  grade2 BMI_cat facility_location  /*Factors not associated with neither treatment nor outcome, but adjusted in other literature*/
                          ;
run;
/*
NOTE: PROC LOGISTIC is modeling the probability that death=1.
NOTE: Convergence criterion (GCONV=1E-8) satisfied
*/
/*aOR = 0.517, 95%CI: 0.363-0.735 
Number of parameters = 27*/
/*Model overfitting*/
/*Multiple comparison a = 0.05/27 = 0.001852*/


*(2-2) Purposeful Selection;

*a.Run a univariate test for each covariate against outcome
    If p<.25 then put it on the:   Candidate list
    If p>.25 then put it on the:   Non-Candidate list;

*CANDIDATE LIST:
cdcc2 year_of_diagnosis_cat stage2 facility_type age_cat2 insurance2 (P<0.05 for all)
BMI_cat (p=0.1311), grade2 (p=0.1858), facility_location (p=0.0947);

*NON-CANDIDATE LIST:
Race2 (p=0.5443),income (p=0.2793); 

*b.Put all covariates from the Candidate list into a multivariate model;
proc logistic data = UTERINE_CA1288_MODEL;
format surgery surgeryf. ;
format cdcc2 cdcc2f. year_of_diagnosis_cat year_of_diagnosis_catf. stage2 stage2f. facility_type facility_typef.
       age_cat2 age_cat2f. insurance2 insurance2f. race2 race2f. income incomef. lnd lndf. grade2 grade2f. 
       BMI_cat BMI_catf. facility_location facility_locationf.;
class surgery (ref='No') / param=ref;
class cdcc2(ref='0') year_of_diagnosis_cat(ref='1998-2004') stage2(ref='I') facility_type(ref='Academic/Research Program')
      age_cat2(ref='41-59') insurance2 (ref='Private Insurance')
	  race2 (ref='White') income (ref='< $30,000')
	  grade2(ref='Well/Moderate') BMI_cat(ref='Normal(<25.0)') facility_location(ref='Eastern')/ param=ref;
model death (event='1') = surgery
                          cdcc2 year_of_diagnosis_cat stage2 facility_type
                          age_cat2 insurance2 BMI_cat grade2 facility_location
                          ;
run; /*BETA OF SURGERY= -0.6909*/


*c.Remove covariates from the model if they are not significant (p>.10) 
   and not a confounder (removal does not change a coefficient by more than 20%) 
   The model now includes significant predictors and confounders from the Candidate list;

proc logistic data = UTERINE_CA1288_MODEL;
format surgery surgeryf. ;
format cdcc2 cdcc2f. year_of_diagnosis_cat year_of_diagnosis_catf. stage2 stage2f. facility_type facility_typef.
       age_cat2 age_cat2f. insurance2 insurance2f. race2 race2f. income incomef. lnd lndf. grade2 grade2f. 
       BMI_cat BMI_catf. facility_location facility_locationf.;
class surgery (ref='No') / param=ref;
class cdcc2(ref='0') year_of_diagnosis_cat(ref='1998-2004') stage2(ref='I') facility_type(ref='Academic/Research Program')
      age_cat2(ref='41-59') insurance2 (ref='Private Insurance')
	  race2 (ref='White') income (ref='< $30,000')
	  grade2(ref='Well/Moderate') BMI_cat(ref='Normal(<25.0)') facility_location(ref='Eastern')/ param=ref;
model death (event='1') = surgery 
                          cdcc2 year_of_diagnosis_cat stage2 /*facility_type*/
                          age_cat2 insurance2 /*BMI_cat*/ /*grade2*/ /*facility_location*/
                          ;
run; 
*/1.remove facility_location: BETA OF SURGERY = -0.6749, change < 20%, drop*/
*/2.remove facility_type: BETA OF SURGERY = -0.6951, change < 20%, drop*/
*/3.remove grade2: BETA OF SURGERY = -0.6896, change < 20%, drop*/
*/4.remove BMI_cat: BETA OF SURGERY = -0.7090, change < 20%, drop*/

*d.Add covariates from the Non-Candidate list to the existing model if they are significant at p<.10);

proc logistic data = UTERINE_CA1288_MODEL;
format surgery surgeryf. ;
format cdcc2 cdcc2f. year_of_diagnosis_cat year_of_diagnosis_catf. stage2 stage2f. facility_type facility_typef.
       age_cat2 age_cat2f. insurance2 insurance2f. race2 race2f. income incomef. lnd lndf. grade2 grade2f. 
       BMI_cat BMI_catf. facility_location facility_locationf.;
class surgery (ref='No') / param=ref;
class cdcc2(ref='0') year_of_diagnosis_cat(ref='1998-2004') stage2(ref='I') facility_type(ref='Academic/Research Program')
      age_cat2(ref='41-59') insurance2 (ref='Private Insurance')
	  race2 (ref='White') income (ref='< $30,000')
	  grade2(ref='Well/Moderate') BMI_cat(ref='Normal(<25.0)') facility_location(ref='Eastern')/ param=ref;
model death (event='1') = surgery 
                          cdcc2 year_of_diagnosis_cat stage2 /*facility_type*/
                          age_cat2 insurance2 /*BMI_cat*/ /*grade2*/ /*facility_location*/
						  race2 income
                          ;
run; 
/*1.Add race2: P of race2 = 0.3676, Beta of treament = -0.6933, change <20%, P value < 0.1 for race*/
/*2.Add income: P of income = 0.3167, Beta of treatment = -0.7118, change <20%, P value <0.1 for income*/

/*f.Repeat step (3) from the previous list, but only for the newly added Non-Candidate variables*/ 

*********************************
Final Logistic regression model
**********************************;

proc logistic data = UTERINE_CA1288_MODEL;
format surgery surgeryf. ;
format cdcc2 cdcc2f. year_of_diagnosis_cat year_of_diagnosis_catf. stage2 stage2f. facility_type facility_typef.
       age_cat2 age_cat2f. insurance2 insurance2f. race2 race2f. income incomef. lnd lndf. grade2 grade2f. 
       BMI_cat BMI_catf. facility_location facility_locationf.;
class surgery (ref='No') / param=ref;
class cdcc2(ref='0') year_of_diagnosis_cat(ref='1998-2004') stage2(ref='I') facility_type(ref='Academic/Research Program')
      age_cat2(ref='41-59') insurance2 (ref='Private Insurance')
	  race2 (ref='White') income (ref='< $30,000')
	  grade2(ref='Well/Moderate') BMI_cat(ref='Normal(<25.0)') facility_location(ref='Eastern')/ param=ref;
model death (event='1') = surgery 
                          cdcc2 year_of_diagnosis_cat stage2 /*facility_type*/
                          age_cat2 insurance2 /*BMI_cat*/ /*grade2*/ /*facility_location*/
						  race2 income
                          ;
ODS OUTPUT OddsRatios = OR ParameterEstimates = Pvalue;
run; 
/*aOR of treatment on mortality = 0.503, 95%CI 0.356 0.713 */
/*No of parameter = 20*/
proc print data = OR;run;
proc print data = Pvalue;run;

/*
Multivariable model based on science
-2 Log L = 941.784 , DF = 27

Purposeful selection
-2 Log L = 949.965, DF = 20

model comparison using Log likelihood test
critical value = 949.965 - 941.784 = 8.8, with DF = 27-20 = 7
Chi - square test, P=0.2673 > 0.05

Two models based on sicence or purposeful selection are not statistically different. 
Two aOR are similar. But the model built on purposeful selection has less
parameters and less multiple comparison. 
*/

/*****************************************
Final Log-linear Poisson regression model
******************************************/

proc genmod data = UTERINE_CA1288_MODEL;
format surgery surgeryf. ;
format cdcc2 cdcc2f. year_of_diagnosis_cat year_of_diagnosis_catf. stage2 stage2f. facility_type facility_typef.
       age_cat2 age_cat2f. insurance2 insurance2f. race2 race2f. income incomef. lnd lndf. grade2 grade2f. 
       BMI_cat BMI_catf. facility_location facility_locationf.;
class surgery (ref='No') / param=ref;
class cdcc2(ref='0') year_of_diagnosis_cat(ref='1998-2004') stage2(ref='I') facility_type(ref='Academic/Research Program')
      age_cat2(ref='41-59') insurance2 (ref='Private Insurance')
	  race2 (ref='White') income (ref='< $30,000')
	  grade2(ref='Well/Moderate') BMI_cat(ref='Normal(<25.0)') facility_location(ref='Eastern')/ param=ref;
model death  = surgery 
                          cdcc2 year_of_diagnosis_cat stage2 
                          age_cat2 insurance2 
						  race2 income
						  /dist = Poisson link = log;
    
estimate "Surgery No"                     surgery     0 /exp ;
estimate "Surgery Yes"                    Surgery     1 /exp ;

estimate "Year of diagnosis 1998-2004"    year_of_diagnosis_cat 0 0 0 /exp ;
estimate "Year of diagnosis 2005-2007"    year_of_diagnosis_cat 1 0 0 /exp ;
estimate "Year of diagnosis 2008-2009"    year_of_diagnosis_cat 0 1 0 /exp ;
estimate "Year of diagnosis 2010-2011"    year_of_diagnosis_cat 0 0 1 /exp ;

estimate "Age 41-59"                      age_cat2 0 0 0 /exp ;
estimate "Age 60-69"                      age_cat2 1 0 0 /exp ;
estimate "Age 70-79"                      age_cat2 0 1 0 /exp ;
estimate "Age 80-89"                      age_cat2 0 0 1 /exp ;

estimate "Health Insurance Private Insurance"      insurance2 0 0 0 /exp ;
estimate "Health Insurance Medicaid/No insured"    insurance2 1 0 0 /exp ;
estimate "Health Insurance Medicare"               insurance2 0 1 0 /exp ;
estimate "Health Insurance Other/Unknown"          insurance2 0 0 1 /exp ;

estimate "Comorbidity No"                  cdcc2 0 0 /exp ;
estimate "Comorbidity Yes"                 cdcc2 1 0 /exp ;
estimate "Comorbidity Unknown"             cdcc2 0 1 /exp ;

estimate "Stage I"                         stage2 0 /exp ;
estimate "Stage II"                        stage2 1 /exp ;

estimate "Race White"                      race2 0 0 0 /exp;
estimate "Race Black"                      race2 1 0 0 /exp;  
estimate "Race Other"                      race2 0 1 0 /exp;  
estimate "Race Unknown"                    race2 0 0 1 /exp;  

estimate "Income < $30,000"                income 0 0 0 0/exp;
estimate "Income $30,000 - $35,999"        income 1 0 0 0/exp;
estimate "Income $36,000 - $45,999"        income 0 1 0 0/exp;
estimate "Income $46,000 +"                income 0 0 1 0/exp;
estimate "Income Unknown"                  income 0 0 0 1/exp;

ODS OUTPUT Estimates=aRR_purposeful;

run; 
/*surgery aRR=0.5904, 95%CI: 0.4338 - 0.8036*/ 
