/* *********************************************************************/
/* Perform a Logistic Regression and save the propensity score data set*/
/* STUDY.Propen for all patients in the observational study.           */
/* Statistic Name = PROB                                               */
/* Note: PARMLABEL is a SAS Verion 8.0 option.                         */
/* *********************************************************************/
/*
LIBNAME STUDY 'D:\INTERVEN';
PROC LOGISTIC DATA=STUDY.SEarly Descend;
MODEL interven = ptage male white mhprevmi mhangina mhchf mhptca mhcabg mhdiab mhsmoke killip1 pulsecd2 bpsyscd2 admitmi cpcd
tincd/SELECTION = STEPWISE RISKLIMITS LACKFIT RSQUARE PARMLABEL;
OUTPUT OUT= STUDY.Propen prob=prob ;
RUN;
*/
*GREEDMTCH(STUDY,Propen,interven,Matches);        /* Call statement for Greedy Match Macro */


/* *************************************/
/* Greedy 5->1 Digit Matching Macro    */
/* *************************************/
%MACRO GREEDMTCH
       (Lib, 	   /* Library Name */
        Dataset,   /* Data set of all patients*/
        depend,    /* Dependent variable that indicates Case or Control; Code 1 for Cases, 0 for Controls*/
        matches    /* Output file of matched pairs*/
       );

/* Macro to sort the Cases and Controls dataset */
%MACRO SORTCC;
proc sort data=tcases
out=&LIB..Scase;
by prob;
run;

proc sort data=tctrl
out=&LIB..Scontrol;
by prob randnum;
run;
%MEND SORTCC;

/****** Macro to Create the initial Case and Control Data Sets ******/
%MACRO INITCC(digits);
data tcases (drop=cprob) tctrl (drop=aprob) ;
set &LIB..&dataset. ;
	/* Create the data set of Controls*/
	if &depend. = 0 and prob ne .
	then do;
	cprob = Round(prob,&digits.);
	Cmatch = 0;
	Length RandNum 8;
	RandNum=ranuni(1234567);
	Label RandNum='Uniform Randomization Score';
	output tctrl;
	end;

	/* Create the data set of Cases */
	else if &depend. = 1 and prob ne .
	then do;
	Cmatch = 0;
	aprob =Round(prob,&digits.);
	output tcases;
	end;
run;
%SORTCC;
%MEND INITCC;

/****** Macro to Perform the Match ******/
%MACRO MATCH (MATCHED,DIGITS);
data &lib..&matched. (drop=Cmatch randnum aprob cprob start oldi curctrl matched);
/* select the cases data set */
set &lib..SCase ;
curob + 1;
matchto = curob;
	if curob = 1 then do;
	start = 1;
	oldi = 1;
	end;
/* select the controls data set */
DO i = start to n;
	set &lib..Scontrol point= i nobs = n;
	if i gt n then goto startovr;
	if _Error_ = 1 then abort;
	curctrl = i;
/* output control if match found */
	if aprob = cprob then
	do;
		Cmatch = 1;
		output &lib..&matched.;
		matched = curctrl;
		goto found;
	end;
/* exit do loop if out of potential matches */
	else if cprob gt aprob then goto nextcase;

	startovr: if i gt n then goto nextcase;
END; /* end of DO LOOP */

/* If no match was found, put pointer Posters back*/
nextcase:
if Cmatch=0 then start = oldi;
/* If a match was found, output case and increment pointer */
found:
if Cmatch = 1 then do;
	oldi = matched + 1;
	start = matched + 1;
	set &lib..SCase point = curob;
	output &lib..&matched.;
end;
retain oldi start;
if _Error_=1 then _Error_=0;
run;

/* Get files of unmatched cases and controls.                           */
/* NIS 2016-2018 patient identifiers:                                   */
/*   HOSP_NIS  = Hospital identifier                                    */
/*   KEY_NIS   = Patient record identifier                              */
/* (Original macro template used HID / PATIENTN — replaced throughout.) */

proc sort data=&lib..scase out=sumcase;
     by HOSP_NIS KEY_NIS;
run;

proc sort data=&lib..scontrol out=sumcontrol;
     by HOSP_NIS KEY_NIS;
run;

proc sort data=&lib..&matched. out=smatched (keep=HOSP_NIS KEY_NIS matchto);
     by HOSP_NIS KEY_NIS;
run;

data tcases (drop=matchto);
     merge sumcase(in=a) smatched;
     by HOSP_NIS KEY_NIS;

     if a and matchto = . ;
     cmatch = 0;
     aprob =Round(prob,&digits.);
run;

data tctrl (drop=matchto);
     merge sumcontrol(in=a) smatched;
     by HOSP_NIS KEY_NIS;

     if a and matchto = . ;
     cmatch = 0;
     cprob = Round(prob,&digits.);
run;

%SORTCC
%MEND MATCH;

/* Note: This section can be modified to try variations of the basic    */
/* algorithm. Create file of cases and controls                         */

%INITCC(.00001);

   %MATCH(Match5,.0001);  /* Do a 5-digit match                         */
   %MATCH(Match4,.001);   /* Do a 4-digit match on remaining unmatched  */
   %MATCH(Match3,.01);    /* Do a 3-digit match on remaining unmatched  */
   %MATCH(Match2,.1);     /* Do a 2-digit match on remaining unmatched  */
   %MATCH(Match1,.1);     /* Do a 1-digit match on remaining unmatched  */

/* Merge all the matches into one file */
/* The purpose of the marchto variable is to identify matched pairs for */
/* the matched pair anlayses.                                           */
/* matchto is initially assigned the observation number of the case.    */
/* Since there would be duplicate numbers after the individual files    */
/* were merged, matchto is incremented by file.                         */
/* Note that if the controls file contains more than N=100,000 records  */
/* and/or there are more than 1,000 matches made at each match level,   */
/* then the incrementation factor must be changed.                      */

data &lib..&matches.;
set &lib..match5(in=a) &lib..match4(in=b) &lib..match3(in=c) &lib..match2(in=d) &lib..match1(in=e);
if b then matchto=matchto + 100000;
if c then matchto=matchto + 10000000;
if d then matchto=matchto + 1000000000;
if e then matchto=matchto + 100000000000;
run;

/* Sort file -- Need sort for Univariate analysis in tables*/
proc sort data=&lib..&matches. out =&lib..S&matches.;
by &depend.;
run;

%MEND GREEDMTCH;
