Applied Methods in Health Services and Outcomes Research

Homework assignment 3: (Propensity score analysis: matched)

Data from a cohort of 514 infants with very low birthweight (<1,600 grams) from 1981-87 were collected at Duke University Medical Center. The project was undertaken to evaluate theassociation between the exposure of interest of intraventricular hemorrhage (IVH) and the outcome of death (DEAD). Measured potential confounders included birthweight, gestational age, presence of pneumothorax, mode of delivery, single vs. multiple gestation, and whether the birth occurred at Duke or at another hospital with later transfer to Duke.

In this analysis, the primary outcome of interest is death (DEAD). The primary exposure of interest variable is IVH (“1” denoting the presence of the condition). The SAS data set “hw_vlbw” is available in CourseWorks. Variable names and definitions are provided in a table below. SAS code examples are provided in the file “LAB_PS_SAS_CODES.sas”

Objectives:Develop propensity score analyses to examine the association between IVH and mortality.

Practice the analytical skills:

Develop step 1 and step 2 propensity score models

Apply propensity score (PS) methods using matched.

Apply balance diagnostics for the original unadjusted cohort and thePS-matched cohort.

Requirements:

Fit your PS step 1 logistic regression modelsusing exposure of interest (IVH) as the response variable and baseline factors (measured confounders) as the predictors. You can fit both simple and complex (with any two-way interactions) models. Pick the final step 1 model based on balance diagnostics (standardized mean differences). (20 points, see examples)

Present twoversions of table 1 (reporting column percentage by exposure arms, and standardized mean differences for comparison) in the three analytical cohorts:(1)the original cohort, and (2) the PS-matched cohort(20 points, 10 points for each table; see examples)

Present distribution of propensity score by exposure groups in original cohort and matched cohort, separately, in histograms or boxplots (10 points, 5 points for each cohort)

Fit PS step 2 modelsfor the PS-matched cohort. Present one table 2 including: (1) the unadjusted odds ratio or risk ratio(95%CI) from homework1, (2) the adjusted odds ratio or risk ratio(95%CI) from the multivariable model from homework1, and (3) the adjusted odds ratio or risk ratio(95%CI) from the PS-matched method(20 points for PS-matched estimates)

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

| ![](blob:vscode-webview://1grb89tshrgec79t0kg1bp11qn972a1pq44eo8097v4uj7vpdddi/da7470ee-4980-46b8-98b0-092afb38e293)Model without interaction termsN of matched cohort =816C statistics =0.7252Hosmer andLemeshowGoodness-of-Fit Test P = 0.8742| Obs | VarName               | Stddiff |
| ----- | ----------------------- | --------- |
| 1   | age_cat2              | 0.0000  |
| 2   | race2                 | 0.1042  |
| 3   | insurance2            | 0.0761  |
| 4   | income                | 0.0873  |
| 5   | BMI_cat               | 0.0000  |
| 6   | cdcc2                 | 0.0925  |
| 7   | stage2                | 0.0108  |
| 8   | grade2                | 0.0496  |
| 9   | facility_location     | 0.0743  |
| 10  | facility_type         | -0.0441 |
| 11  | year_of_diagnosis_cat | 0.0766  |

 | ![](blob:vscode-webview://1grb89tshrgec79t0kg1bp11qn972a1pq44eo8097v4uj7vpdddi/8f61bbff-ed59-4d20-917f-16e984668c44)Model with any two-way interaction terms and significant level of stayat0.2N of matched cohort = 728C statistics =0.7788Hosmer andLemeshowGoodness-of-Fit Test P = 0.8311| Obs | VarName               | Stddiff |
| ----- | ----------------------- | --------- |
| 1   | age_cat2              | 0.0552  |
| 2   | race2                 | 0.0242  |
| 3   | insurance2            | 0.1561  |
| 4   | income                | 0.0320  |
| 5   | BMI_cat               | 0.0387  |
| 6   | cdcc2                 | 0.1050  |
| 7   | stage2                | 0.0732  |
| 8   | grade2                | 0.0250  |
| 9   | facility_location     | 0.1029  |
| 10  | facility_type         | 0.0110  |
| 11  | year_of_diagnosis_cat | 0.0853  |

|  |  |
| - | - |

Example interpretation: For small sample sizes, we consider the distribution of covariates between the two groups to be balanced if the standardized difference is <0.2. For large sample sizes, we would consider the distribution of covariates between the two groups to be balanced with a standardized difference of <0.1. In the two-way interaction term model, the variable of insurance2 has SD = 0.1561 and the variable of facility location has a SD = 0.1029.  I would  prefer the model without interaction termsbecause it has only one variable with a SD >.1 (race= 0.1042).If matched cohorts from both approaches generate small SDs (<0.1), another factor is sample size. I would choose the cohort with the relatively larger sample size to preserve the analysis power for the outcome model and to improve the generalizability of the study results.

Requirement 2 Example: Table 1 from original cohort

|                           | Original Cohort(N = 1288) | P-Values | Standardizeddifference |
| ------------------------- | ------------------------- | -------- | ---------------------- |
| SurgeryNo                 | SurgeryYes                |          |                        |
| N                         | %                         | N        | %                      |
| age_cat2                  | 114                       | 22.05    | 145                    |
| 41-59                     |                           |          |                        |
| 60-69                     | 237                       | 45.84    | 386                    |
| 70-79                     | 149                       | 28.82    | 207                    |
| 80-89                     | 17                        | 3.29     | 33                     |
| race2                     | 303                       | 58.61    | 487                    |
| White                     |                           |          |                        |
| Black                     | 131                       | 25.34    | 152                    |
| Other                     | 57                        | 11.03    | 49                     |
| Unknown                   | 26                        | 5.03     | 83                     |
| insurance2                | 225                       | 43.52    | 328                    |
| Private Insurance         |                           |          |                        |
| Medicaid/No insured       | 37                        | 7.16     | 57                     |
| Medicare                  | 241                       | 46.62    | 373                    |
| Other/Unknown             | 14                        | 2.71     | 13                     |
| income                    | 95                        | 18.38    | 107                    |
| < $30,000                 |                           |          |                        |
| $30,000 - $35,999         | 80                        | 15.47    | 116                    |
| $36,000 - $45,999         | 128                       | 24.76    | 192                    |
| $46,000 +                 | 195                       | 37.72    | 339                    |
| Unknown                   | 19                        | 3.68     | 17                     |
| BMI_cat                   | 410                       | 79.30    | 551                    |
| Normal(<25.0)             |                           |          |                        |
| Overweight(25.0-29.9)     | 107                       | 20.70    | 220                    |
| cdcc2                     | 357                       | 69.05    | 596                    |
| 0                         |                           |          |                        |
| >=1                       | 96                        | 18.57    | 153                    |
| Unknown                   | 64                        | 12.38    | 22                     |
| stage2                    | 331                       | 64.02    | 622                    |
| I                         |                           |          |                        |
| II                        | 186                       | 35.98    | 149                    |
| grade2                    | 39                        | 7.54     | 62                     |
| Well/Moderate             |                           |          |                        |
| Poorly                    | 373                       | 72.15    | 534                    |
| Unknown                   | 105                       | 20.31    | 175                    |
| facility_location         | 184                       | 35.59    | 293                    |
| Eastern                   |                           |          |                        |
| South                     | 124                       | 23.98    | 150                    |
| Midwest                   | 143                       | 27.66    | 257                    |
| West                      | 66                        | 12.77    | 71                     |
| facility_type             | 269                       | 52.03    | 325                    |
| Non-Academic program      |                           |          |                        |
| Academic/Research Program | 248                       | 47.97    | 446                    |
| year_of_diagnosis_cat     | 140                       | 27.08    | 67                     |
| 1998-2004                 |                           |          |                        |
| 2005-2007                 | 146                       | 28.24    | 179                    |
| 2008-2009                 | 95                        | 18.38    | 187                    |
| 2010-2011                 | 136                       | 26.31    | 338                    |

Requirement 2 Example: Table 1 from for PS matched cohort

|                           | PS Matched Cohort (N=816) | P-Values | Standardized difference |
| ------------------------- | ------------------------- | -------- | ----------------------- |
| SurgeryNo                 | surgery Yes               |          |                         |
| N                         | %                         | N        | %                       |
| age_cat2                  | 86                        | 21.08    | 87                      |
| 41-59                     |                           |          |                         |
| 60-69                     | 200                       | 49.02    | 201                     |
| 70-79                     | 107                       | 26.23    | 106                     |
| 80-89                     | 15                        | 3.68     | 14                      |
| race2                     | 238                       | 58.33    | 250                     |
| White                     |                           |          |                         |
| Black                     | 107                       | 26.23    | 98                      |
| Other                     | 38                        | 9.31     | 39                      |
| Unknown                   | 25                        | 6.13     | 21                      |
| insurance2                | 180                       | 44.12    | 176                     |
| Private Insurance         |                           |          |                         |
| Medicaid/No insured       | 30                        | 7.35     | 31                      |
| Medicare                  | 190                       | 46.57    | 189                     |
| Other/Unknown             | 8                         | 1.96     | 12                      |
| income                    | 71                        | 17.40    | 67                      |
| < $30,000                 |                           |          |                         |
| $30,000 - $35,999         | 64                        | 15.69    | 58                      |
| $36,000 - $45,999         | 105                       | 25.74    | 114                     |
| $46,000 +                 | 154                       | 37.75    | 156                     |
| Unknown                   | 14                        | 3.43     | 13                      |
| BMI_cat                   | 312                       | 76.47    | 312                     |
| Normal(<25.0)             |                           |          |                         |
| Overweight(25.0-29.9)     | 96                        | 23.53    | 96                      |
| cdcc2                     | 304                       | 74.51    | 299                     |
| 0                         |                           |          |                         |
| >=1                       | 84                        | 20.59    | 87                      |
| Unknown                   | 20                        | 4.90     | 22                      |
| stage2                    | 287                       | 70.34    | 289                     |
| I                         |                           |          |                         |
| II                        | 121                       | 29.66    | 119                     |
| grade2                    | 28                        | 6.86     | 28                      |
| Well/Moderate             |                           |          |                         |
| Poorly                    | 297                       | 72.79    | 288                     |
| Unknown                   | 83                        | 20.34    | 92                      |
| facility_location         | 149                       | 36.52    | 143                     |
| Eastern                   |                           |          |                         |
| South                     | 98                        | 24.02    | 94                      |
| Midwest                   | 118                       | 28.92    | 122                     |
| West                      | 43                        | 10.54    | 49                      |
| facility_type             | 205                       | 50.25    | 214                     |
| Non-Academic program      |                           |          |                         |
| Academic/Research Program | 203                       | 49.75    | 194                     |
| year_of_diagnosis_cat     | 70                        | 17.16    | 64                      |
| 1998-2004                 |                           |          |                         |
| 2005-2007                 | 119                       | 29.17    | 118                     |
| 2008-2009                 | 87                        | 21.32    | 97                      |
| 2010-2011                 | 132                       | 32.35    | 129                     |

Requirement 3. Example

![](blob:vscode-webview://1grb89tshrgec79t0kg1bp11qn972a1pq44eo8097v4uj7vpdddi/41560f08-c801-4cf4-9eff-fd7ba040993e)

![](blob:vscode-webview://1grb89tshrgec79t0kg1bp11qn972a1pq44eo8097v4uj7vpdddi/345bb6a4-8c61-4914-beda-7b6286bbb7ca)

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

* 
* [•••]()
* 
* Go to[ ] Page
