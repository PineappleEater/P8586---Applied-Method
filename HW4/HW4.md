Applied Methods in Health Services and Outcomes Research

Homework assignment 4: (Propensity score analysis: IPTW)

Data from a cohort of 514 infants with very low birthweight (<1,600 grams) from 1981-87 were collected at Duke University Medical Center. The project was undertaken to evaluate theassociation between the exposure of interest of intraventricular hemorrhage (IVH) and the outcome of death (DEAD). Measured potential confounders included birthweight, gestational age, presence of pneumothorax, mode of delivery, single vs. multiple gestation, and whether the birth occurred at Duke or at another hospital with later transfer to Duke.

In this analysis, the primary outcome of interest is death (DEAD). The primary exposure of interest variable is IVH (“1” denoting the presence of the condition). The SAS data set “hw_vlbw” is available in CourseWorks. Variable names and definitions are provided in a table below. SAS code examples are provided in the file “LAB_PS_SAS_CODES.sas”

Objectives:Develop propensity score analyses to examine the association between IVH and mortality.

Practice the analytical skills:

Develop step 1 and step 2 propensity score models

Apply propensity score (PS) methods usinginverse probability of treatment weighting (IPTW) for ATE or ATT.

Apply balance diagnostics for thePS-IPTW cohort.

Requirements (CHOOSE ATE OR ATT):

Fit your PS step 1 logistic regression modelsusing exposure of interest (IVH) as the response variable and baseline factors (measured confounders) as the predictors. You can fit both simple and complex (with any two-way interactions) models. Pick the final step 1 model based on balance diagnostics (standardized mean differences). (20 points, see examples)

Present twoversions of table 1 (reporting column percentage by exposure arms, and standardized mean differences for comparison) in the three analytical cohorts:(1)the original cohort (from homework 3),and (2) the PS-IPTW cohort. (20 points, see examples)

Present the distribution of propensity score and weight for exposure groups in a scatter plot (10 points)

Fit PS step 2 modelsfor PS-IPTW cohort. Present one table 2 including: (1) the unadjusted odds ratio or risk ratio(95%CI) from homework1, (2) the adjusted odds ratio or risk ratio(95%CI)  from the multivariable model from homework1, (3) the adjusted odds ratio or risk ratio(95%CI) from the PS-matched method, and (4) the adjusted odds ratio or risk ratio (95%CI) from the PS-IPTW.(20 points for PS-IPTW estimates; see examples)

Interpret your finding in plain, lay terms for table 1 and table 2. (30 points)

Provide the SAS programing, log files and clear notes as the appendix.

Variables of interest

| Variable     | Definition                                     |
| ------------ | ---------------------------------------------- |
| dead         | Dead1= Dead  0=Alive                           |
| Ivh2         | Intraventricular hemorrhage1=Yes 0=No          |
| bwt          | Continuous variable Birth weight (g)           |
| gest         | Continuous variable Gestational age (weeks)    |
| pneumo       | Pneumothorax occurred1=Yes 0=No                |
| Delivery_new | Mode ofdelivery1=C-Section 2=Vaginal 9=Unknown |
| twin         | Multiple gestation                             |
| Inout_new    | 1=”Born at Duke” 2= “Transport”            |

Requirement 1 Example: Choice of final PS step 1 model

| ![](blob:vscode-webview://1grb89tshrgec79t0kg1bp11qn972a1pq44eo8097v4uj7vpdddi/29656a56-53a6-4a1c-b2e1-d3e49d1aea91)Model without interaction termsN ofIPTWcohort =C statistics =0.7252Hosmer andLemeshowGoodness-of-Fit Test P = 0.8742| Obs | VarName               | Stddiff |
| ----- | ----------------------- | --------- |
| 1   | age_cat2              |         |
| 2   | race2                 |         |
| 3   | insurance2            |         |
| 4   | income                |         |
| 5   | BMI_cat               |         |
| 6   | cdcc2                 |         |
| 7   | stage2                |         |
| 8   | grade2                |         |
| 9   | facility_location     |         |
| 10  | facility_type         |         |
| 11  | year_of_diagnosis_cat |         |

 | ![](blob:vscode-webview://1grb89tshrgec79t0kg1bp11qn972a1pq44eo8097v4uj7vpdddi/470b3e8b-0746-4ae9-bb94-1d8074c46cd5)Model with any two-way interaction terms and significant level of stayat0.2N ofIPTWcohort =C statistics =0.7788Hosmer andLemeshowGoodness-of-Fit Test P = 0.8311| Obs | VarName               | Stddiff |
| ----- | ----------------------- | --------- |
| 1   | age_cat2              |         |
| 2   | race2                 |         |
| 3   | insurance2            |         |
| 4   | income                |         |
| 5   | BMI_cat               |         |
| 6   | cdcc2                 |         |
| 7   | stage2                |         |
| 8   | grade2                |         |
| 9   | facility_location     |         |
| 10  | facility_type         |         |
| 11  | year_of_diagnosis_cat |         |

|  |  |
| - | - |

Interpretation for which model to choose:

Requirement 2 Example: Table 1 from for PS IPTW cohort (ATE or ATT)

|                           | PS IPTW Cohort (N=2555) | P-Values | Standardized difference |
| ------------------------- | ----------------------- | -------- | ----------------------- |
| Surgery No                | surgery Yes             |          |                         |
| N                         | %                       | N        | %                       |
| Total                     | XXX                     |          | XXX                     |
| age_cat2                  | 251                     | 20.2     | 248                     |
| 41-59                     |                         |          |                         |
| 60-69                     | 623                     | 50.2     | 686                     |
| 70-79                     | 322                     | 26       | 332                     |
| 80-89                     | 44                      | 3.6      | 48                      |
| race2                     | .775                    | .62.4    | .820                    |
| White                     |                         |          |                         |
| Black                     | 277                     | 22.3     | 291                     |
| Other                     | 105                     | 8.4      | 96                      |
| Unknown                   | 85                      | 6.8      | 108                     |
| insurance2                | .519                    | .41.8    | .577                    |
| Private Insurance         |                         |          |                         |
| Medicaid/No insured       | 95                      | 7.6      | 97                      |
| Medicare                  | 597                     | 48.1     | 620                     |
| Other/Unknown             | 30                      | 2.5      | 20                      |
| income                    | .192                    | .15.5    | .203                    |
| < $30,000                 |                         |          |                         |
| $30,000 - $35,999         | 191                     | 15.4     | 203                     |
| $36,000 - $45,999         | 310                     | 25       | 326                     |
| $46,000 +                 | 518                     | 41.7     | 553                     |
| Unknown                   | 30                      | 2.4      | 30                      |
| BMI_cat                   | .935                    | .75.4    | .982                    |
| Normal(<25.0)             |                         |          |                         |
| Overweight(25.0-29.9)     | 306                     | 24.6     | 333                     |
| cdcc2                     | .916                    | .73.8    | .948                    |
| 0                         |                         |          |                         |
| >=1                       | 238                     | 19.1     | 252                     |
| Unknown                   | 87                      | 7        | 114                     |
| stage2                    | .903                    | .72.7    | .940                    |
| I                         |                         |          |                         |
| II                        | 338                     | 27.3     | 374                     |
| grade2                    | .96                     | .7.7     | .93                     |
| Well/Moderate             |                         |          |                         |
| Poorly                    | 879                     | 70.9     | 946                     |
| Unknown                   | 266                     | 21.4     | 275                     |
| facility_location         | .458                    | .36.9    | .505                    |
| Eastern                   |                         |          |                         |
| South                     | 256                     | 20.7     | 283                     |
| Midwest                   | 390                     | 31.4     | 400                     |
| West                      | 137                     | 11       | 126                     |
| facility_type             | .572                    | .46.1    | .594                    |
| Non-Academic program      |                         |          |                         |
| Academic/Research Program | 669                     | 53.9     | 720                     |
| year_of_diagnosis_cat     | .213                    | .17.2    | .242                    |
| 1998-2004                 |                         |          |                         |
| 2005-2007                 | 312                     | 25.2     | 316                     |
| 2008-2009                 | 270                     | 21.7     | 282                     |
| 2010-2011                 | 446                     | 35.9     | 475                     |

Requirement 3. Example (ATE or ATT):

![](blob:vscode-webview://1grb89tshrgec79t0kg1bp11qn972a1pq44eo8097v4uj7vpdddi/0f4f989a-72ef-4422-826c-3cb3e5b8d849)

Requirement 4 Example: Table 2 – unadjusted estimate, adjusted estimate from regression modes, adjusted estimate from PS Matched, adjusted estimate from PS IPTW

|                                                                                                                        |           | ORs (95%CI) |
| ---------------------------------------------------------------------------------------------------------------------- | --------- | ----------- |
|                                                                                                                        | Dead = 0  | Dead = 1    |
| Surgery                                                                                                                |           |             |
| No                                                                                                                     | 394(76.2) | 123(23.8)   |
| Yes                                                                                                                    | 695(90.1) | 76(9.9)     |
| Unadjusted ORs                                                                                                         |           |             |
| Adjusted ORs                                                                                                           |           |             |
| Multivariable model based on Science(including all covariates in the literature review and DAG, not required for HW 3) |           |             |
| Multivariable model Purposeful Selection                                                                               |           |             |
| PS Matched                                                                                                             |           |             |
| PS IPTWATE                                                                                                             |           |             |

* 
* 
* Go to[ ] Page
