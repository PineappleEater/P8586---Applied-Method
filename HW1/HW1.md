Applied Methods in Health Services and Outcomes Research

Homework assignment 1 (Multivariable regression model)

Data from a cohort of 514 infants with very low birthweight (<1,600 grams) from 1981-87 were collected at Duke University Medical Center. The project was undertaken to evaluate the association between the exposure of interest of intraventricular hemorrhage (IVH) and the outcome of death (DEAD). Potential confounders include but not limit to birthweight, gestational age, presence of pneumothorax, mode of delivery, single vs. multiple gestation, and whether the birth occurred at Duke or at another hospital with later transfer to Duke. 

In this analysis, the primary outcome of interest is death (DEAD). The primary exposure of interest variable is IVH (“1” denoting the presence of the condition). The SAS data set “hw_vlbw” is available in CourseWorks. Variable names and definitions are provided in a table below. SAS code examples are provided in the file “LAB_MultiReg_SAS_CODES.sas”

Objectives:
•	Develop a multivariable regression model to examine the association between IVH and mortality.

Practice analytical skills:
•	Decide what variables may confound the association between IVH and mortality.
•	Decide how many covariates you can include in a multivariable model.
•	Fit a model based on purposeful selection.

Requirements:
1.	Report the distribution (column percentage) of potential confounders by the presence versus absence of the exposure of interest (IVH) in Table 1. Report the distribution (row percentage) of potential confounders by the outcome of death (Yes versus No) in Table 2. Use Chi-square tests or Fisher’s exact test to evaluate associations between categorical factors and exposure and outcome in Table 1 and 2. Use Student’s t-test or two sample Wilcoxon Rank Sum Test for continuous variables. If continuous variables are included, state required assumptions and test for normality. Alternately, continuous variables may be categorized. Interpret the findings in plain language. (20 points for results: 10 points for each table. Table examples at the end of the file. 5 points for data interpretation) 
2.	Report the risk (row percentage) of the outcome (DEAD) by exposure of interest (IVH) and the unadjusted crude association (Unadjusted Odds Ratio or Unadjusted Risk Ratio) between IVH and DEAD. Please clarify why you prefer reporting one measurement over the other (OR vs. RR).  (20 points for results. Table examples at the end of the file. 5 points for data interpretation)
3.	Explain what covariates you included in the multivariable regression model and why these factors were chosen.  (20 points)
4.	Report the adjusted associations (aOR or aRR with 95% CIs) from the multivariable model with DEAD as the outcome. Include the estimates for the exposure of interest (IVH) as well as the other covariates of interest (aOR or aRR with 95% CIs) in Table 3. (20 points for results, Table examples at the end of the file; 10 points for data interpretation)
Submission format:
1.	Provide your main analysis results and tables in a Word file. (20 points).
2.	Provide the SAS programing, log file, and SAS output as the appendix. 

Variables of interest
Variable	Definition
DEAD	Death 1= Dead  0=Alive
Ivh2	 Intraventricular hemorrhage  1=Yes 0=No
bwt	Continuous variable Birth weight (g)
gest	Continuous variable Gestational age (weeks)
pneumo	Pneumothorax occurred  1=Yes 0=No
Delivery_new	Mode of delivery 1=C-Section 2=Vaginal 9=Unknown
twin	Multiple gestation 1=Yes 0=No
Inout_new	Location of birth 1=”Born at Duke” 2= “Transport”




















Requirement 1 Example: Table 1 distributions of baseline factors by treatment/exposure arms (Column Percentage)
 	Original Cohort (N = 1288)	P-Values
	Surgery No 	Surgery Yes	
	N	Col %	N	Col %	
age_cat2	114	22.05	145	18.81	0.2636
41-59					
60-69	237	45.84	386	50.06	
70-79	149	28.82	207	26.85	
80-89	17	3.29	33	4.28	
race2	303	58.61	487	63.16	<.0001
White 					
Black 	131	25.34	152	19.71	
Other 	57	11.03	49	6.36	
Unknown	26	5.03	83	10.77	
insurance2	225	43.52	328	42.54	0.6071
Private Insurance 					
Medicaid/No insured	37	7.16	57	7.39	
Medicare 	241	46.62	373	48.38	
Other/Unknown 	14	2.71	13	1.69	
income	95	18.38	107	13.88	0.0531
< $30,000 					
$30,000 - $35,999	80	15.47	116	15.05	
$36,000 - $45,999	128	24.76	192	24.90	
$46,000 + 	195	37.72	339	43.97	
Unknown 	19	3.68	17	2.20	
BMI_cat	410	79.30	551	71.47	0.0015
Normal(<25.0) 					
Overweight(25.0-29.9)	107	20.70	220	28.53	
cdcc2	357	69.05	596	77.30	<.0001
0 					
>=1 	96	18.57	153	19.84	
Unknown	64	12.38	22	2.85	
stage2	331	64.02	622	80.67	<.0001
I 					
II	186	35.98	149	19.33	
grade2	39	7.54	62	8.04	0.5283
Well/Moderate					
Poorly 	373	72.15	534	69.26	
Unknown 	105	20.31	175	22.70	
facility_location	184	35.59	293	38.00	0.0157
Eastern					
South 	124	23.98	150	19.46	
Midwest	143	27.66	257	33.33	
West 	66	12.77	71	9.21	
facility_type	269	52.03	325	42.15	0.0005
Non-Academic program 					
Academic/Research Program	248	47.97	446	57.85	
year_of_diagnosis_cat	140	27.08	67	8.69	<.0001
1998-2004					
2005-2007	146	28.24	179	23.22	
2008-2009	95	18.38	187	24.25	
2010-2011	136	26.31	338	43.84	


Requirement 1 Example: Table 2 Mortality Outcomes at Each Covariate Level (Row Percentage) 
 	Mortality	P-values
	Alive	Dead	
	N	Row %	N	Row %	 
age_cat2	234	90.35	25	9.65	 
41-59					<0.0001
60-69	539	86.52	84	13.48	 
70-79	281	78.93	75	21.07	 
80-89	35	70	15	30	 
race2	669	84.68	121	15.32	0.5443
White					 
Black	233	82.33	50	17.67	 
Other	93	87.74	13	12.26	 
Unknown	94	86.24	15	13.76	 
insurance2	491	88.79	62	11.21	0.0003
Private Insurance					 
Medicaid/No insured	84	89.36	10	10.64	 
Medicare	491	79.97	123	20.03	 
Other/Unknown	23	85.19	4	14.81	 
Neighborhood Zipcode average household income	177	87.62	25	12.38	 
< $30,000					0.2793
$30,000 - $35,999	159	81.12	37	18.88	 
$36,000 - $45,999	268	83.75	52	16.25	 
$46,000 +	457	85.58	77	14.42	 
Unknown	28	77.78	8	22.22	 
Body Mass Index Category	804	83.66	157	16.34	0.1311
Normal(<25.0)					 
Overweight(25.0-29.9)	285	87.16	42	12.84	 
cdcc2	831	87.2	122	12.8	<.0001
0					 
>=1	203	81.53	46	18.47	 
Unknown	55	63.95	31	36.05	 
stage2	838	87.93	115	12.07	<.0001
I					 
II	251	74.93	84	25.07	 
grade2	79	78.22	22	21.78	0.1858
Well/Moderate					 
Poorly	772	85.12	135	14.88	 
Unknown	238	85	42	15	 
Facility Location	413	86.58	64	13.42	0.0947
Eastern					 
South	220	80.29	54	19.71	 
Midwest	336	84	64	16	 
West	120	87.59	17	12.41	 
Facility type	490	82.49	104	17.51	0.0587
Non-Academic program					 
Academic/Research Program	599	86.31	95	13.69	 
year_of_diagnosis_cat	136	65.7	71	34.3	<.0001
1998-2004					 
2005-2007	264	81.23	61	18.77	 
2008-2009	246	87.23	36	12.77	 
2010-2011	443	93.46	31	6.54	 


Requirement 2 Example: Table 3 Unadjusted Association between the Treatment/Exposure and Outcome
		Unadjusted ORs (95%CI)	Unadjusted RRs
(95%CI)
	Dead = 0	Dead = 1		
Surgery				
No	394(76.2)	123(23.8)	Referent	
Yes	695(90.1)	76(9.9)	0.35(0.26-0.48)	


Requirement 4 Example: Table 4 Adjusted Association between the Treatment/Exposure and Outcome
	aORs (95%CI)	aRR (95%CI)
		
Surgery		
No	Referent	
Yes	0.50 (0.36-0.71)	
List all other covariates 		


