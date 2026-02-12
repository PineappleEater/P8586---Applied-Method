---
title: "Homework 1: Multivariable Regression Analysis Report"
author: "Xuange Liang"
date: "February 4, 2026"
---

## Research Question

**Objective**: To evaluate the association between intraventricular hemorrhage (IVH) and neonatal mortality among very low birth weight infants, adjusting for potential confounders.

- **Dataset**: `hw_vlbw` (Very Low Birth Weight Infants, N=514)
- **Exposure**: IVH (Intraventricular Hemorrhage)
- **Outcome**: Death during hospitalization
- **Study Design**: Retrospective cohort study

---

## Methods

### 1. Data Source
- **Sample size**: 514 very low birth weight infants
- **No missing data** on key variables
- **Mortality rate**: 19.3% (99/514)
- **IVH prevalence**: 16.3% (84/514)

### 2. Variable Definitions

**Primary Variables:**
- Exposure: IVH (0=No, 1=Yes)
- Outcome: DEAD (0=Alive, 1=Dead)

**Covariates Considered:**
- Pneumothorax (pneumo): 0=No, 1=Yes
- Delivery mode (delivery_new): 1=C-Section, 2=Vaginal
- Multiple gestation (twin): 0=No, 1=Yes
- Birth location (inout_new): 1=Born at Duke, 2=Transport
- Birth weight (bwt): Continuous (grams) and categorical
  - bwt_cat: 1=<1000g, 2=1000-1299g, 3=1300-1599g
- Gestational age (gest): Continuous (weeks) and categorical
  - gest_cat: 1=<28 weeks, 2=28-31 weeks, 3=≥32 weeks

### 3. Statistical Analysis

**Step 1: Descriptive Statistics**
- Baseline characteristics stratified by IVH status
- Chi-square tests for categorical variables
- t-tests and Wilcoxon rank-sum tests for continuous variables

**Step 2: Unadjusted Association**
- Logistic regression for odds ratio
- Poisson regression with log link for risk ratio
- 2×2 contingency tables

**Step 3: Covariate Selection (Purposeful Selection Method)**
- Univariate screening: p < 0.25 threshold for candidate variables (Hosmer, Lemeshow, & Sturdivant)
- Variables selected: IVH, pneumo, inout_new, bwt_cat, gest_cat
- Variables excluded: delivery_new (p=0.40), twin (p=0.66)

**Step 4: Multivariable Model Building**
- Initial model with all candidate variables
- Sequential removal of non-significant variables (p > 0.10, per purposeful selection workflow)
- Retention criteria: removal changes IVH beta by <20% (change-in-estimate criterion for confounding assessment)
- Variables removed: twin (p=0.40), delivery_new (p=0.62), inout_new (p=0.93)

**Step 5: Final Model**
- Adjusted for: pneumothorax, birth weight category, gestational age category
- Both logistic (OR) and Poisson (RR) regression models estimated

---

## Results

### Table 1: Baseline Characteristics by IVH Status

| Characteristic | No IVH (n=430) | IVH (n=84) | p-value |
|----------------|----------------|------------|---------|
| **Demographics** | | | |
| Birth weight (g), mean±SD | 1101.4±246.0 | 964.1±266.7 | <0.001 |
| Gestational age (wks), mean±SD | 29.1±2.3 | 27.4±2.2 | <0.001 |
| **Birth Weight Category, n (%)** | | | 0.004 |
| <1000g | 146 (34.0%) | 43 (51.2%) | |
| 1000-1299g | 170 (39.5%) | 30 (35.7%) | |
| 1300-1599g | 114 (26.5%) | 11 (13.1%) | |
| **Gestational Age Category, n (%)** | | | <0.001 |
| <28 weeks | 114 (26.5%) | 40 (47.6%) | |
| 28-31 weeks | 255 (59.3%) | 42 (50.0%) | |
| ≥32 weeks | 61 (14.2%) | 2 (2.4%) | |
| **Complications, n (%)** | | | |
| Pneumothorax | 73 (17.0%) | 34 (40.5%) | <0.001 |
| Multiple gestation | 100 (23.3%) | 7 (8.3%) | 0.002 |
| **Delivery & Location, n (%)** | | | |
| C-Section delivery | 221 (51.4%) | 27 (32.1%) | 0.001 |
| Born at Duke | 366 (85.1%) | 54 (64.3%) | <0.001 |
| **Outcome** | | | |
| Death | 58 (13.5%) | 41 (48.8%) | <0.001 |

**Key Findings:**
- Infants with IVH had significantly lower birth weight (137g difference, p<0.001)
- IVH was more common in extremely premature infants (<28 weeks: 47.6% vs 26.5%)
- IVH co-occurred frequently with pneumothorax (40.5% vs 17.0%, p<0.001)
- Mortality was 3.6 times higher in IVH group (48.8% vs 13.5%)

---

### Table 2: Mortality by Baseline Characteristics

| Characteristic | Alive (n=415) | Dead (n=99) | Mortality Rate | p-value |
|----------------|---------------|-------------|----------------|---------|
| **Exposure** | | | | |
| No IVH | 372 (89.6%) | 58 (58.6%) | 13.5% | <0.001 |
| IVH | 43 (10.4%) | 41 (41.4%) | 48.8% | |
| **Complications** | | | | |
| No pneumothorax | 359 (86.5%) | 48 (48.5%) | 11.8% | <0.001 |
| Pneumothorax | 56 (13.5%) | 51 (51.5%) | 47.7% | |
| **Birth Weight** | | | | <0.001 |
| <1000g | 122 (29.4%) | 67 (67.7%) | 35.5% | |
| 1000-1299g | 173 (41.7%) | 27 (27.3%) | 13.5% | |
| 1300-1599g | 120 (28.9%) | 5 (5.1%) | 4.0% | |
| **Gestational Age** | | | | <0.001 |
| <28 weeks | 93 (22.4%) | 61 (61.6%) | 39.6% | |
| 28-31 weeks | 261 (62.9%) | 36 (36.4%) | 12.1% | |
| ≥32 weeks | 61 (14.7%) | 2 (2.0%) | 3.2% | |

**Interpretation of Table 2:**
- Mortality was substantially higher among infants with IVH than without IVH (48.8% vs 13.5%), showing a strong crude exposure-outcome gradient.
- Mortality was also much higher among infants with pneumothorax (47.7% vs 11.8%), indicating severe respiratory complications are strongly related to death.
- A clear dose-response pattern was present for birth weight: mortality decreased from 35.5% (<1000g) to 13.5% (1000-1299g) to 4.0% (1300-1599g).
- A similar gradient was observed by gestational age: 39.6% (<28 weeks), 12.1% (28-31 weeks), and 3.2% (>=32 weeks), supporting prematurity as a major mortality driver.
- Because IVH is associated with these strong mortality predictors (Table 1), confounding is plausible and multivariable adjustment is required.

---

### Table 3: Unadjusted and Adjusted Association Between IVH and Mortality

| Model | Measure | Estimate | 95% CI | p-value |
|-------|---------|----------|---------|---------|
| **Unadjusted** | | | | |
| Logistic | Odds Ratio | 6.116 | 3.674 - 10.179 | <0.001 |
| Poisson | Risk Ratio | 3.619 | 2.426 - 5.398 | <0.001 |
| **Adjusted¹** | | | | |
| Logistic | Odds Ratio | 4.149 | 2.291 - 7.516 | <0.001 |
| Poisson | Risk Ratio | 2.059 | 1.351 - 3.137 | 0.001 |

¹ Adjusted for pneumothorax, birth weight category, and gestational age category

**Interpretation:**
- After adjusting for key confounders, IVH **increased the odds of death by 4.1-fold** (95% CI: 2.3-7.5)
- We emphasize RR over OR for effect communication because death is not a rare outcome in this cohort (99/514 = 19.3%); with common outcomes, OR can overstate the magnitude of association relative to RR.
- Using the more appropriate risk ratio for this context, IVH **doubled the risk of death** (RR=2.1, 95% CI: 1.4-3.1)
- Adjustment attenuated the effect by 32% (OR: 6.1→4.1), indicating substantial but incomplete confounding

---

### Table 4: Final Multivariable Model Results

#### A. Logistic Regression (Odds Ratios)

| Variable | Odds Ratio | 95% CI | p-value |
|----------|------------|---------|---------|
| **IVH (Yes vs No)** | **4.149** | 2.291 - 7.516 | <0.001 |
| Pneumothorax (Yes vs No) | 6.185 | 3.486 - 10.975 | <0.001 |
| **Birth Weight** | | | 0.0002 |
| <1000g vs 1300-1599g | 8.902 | 2.858 - 27.729 | 0.0002 |
| 1000-1299g vs 1300-1599g | 3.216 | 1.113 - 9.293 | 0.031 |
| **Gestational Age** | | | 0.151 |
| <28 weeks vs ≥32 weeks | 3.691 | 0.749 - 18.177 | 0.108 |
| 28-31 weeks vs ≥32 weeks | 2.239 | 0.484 - 10.352 | 0.302 |

**Model Performance:**
- C-statistic: 0.853 (excellent discrimination)
- AIC: 373.1
- -2 Log Likelihood: 359.1

#### B. Poisson Regression (Risk Ratios)

| Variable | Risk Ratio | 95% CI | p-value |
|----------|------------|---------|---------|
| **IVH (Yes vs No)** | **2.059** | 1.351 - 3.137 | 0.001 |
| Pneumothorax (Yes vs No) | 2.821 | 1.850 - 4.300 | <0.001 |
| **Birth Weight** | | | 0.004 |
| <1000g vs 1300-1599g | 4.861 | 1.779 - 13.283 | 0.002 |
| 1000-1299g vs 1300-1599g | 2.692 | 1.025 - 7.069 | 0.044 |
| **Gestational Age** | | | 0.244 |
| <28 weeks vs ≥32 weeks | 3.143 | 0.710 - 13.923 | 0.132 |
| 28-31 weeks vs ≥32 weeks | 2.333 | 0.555 - 9.809 | 0.248 |

---

### Sensitivity Analysis

A simpler model including only IVH, pneumothorax, and birth weight (without gestational age) was also tested:

| Parameter | IVH OR (Full Model) | IVH OR (Simple Model) | % Change |
|-----------|---------------------|----------------------|----------|
| Beta coefficient | 1.4230 | 1.4750 | +3.7% |
| Odds Ratio | 4.149 | 4.371 | +5.3% |
| C-statistic | 0.853 | 0.842 | -1.3% |

**Conclusion**: The IVH effect estimate is robust across model specifications (<5% change), supporting the validity of our findings. The full model with gestational age is retained as the primary analysis due to slightly better discrimination and theoretical considerations.

---

## Discussion

### Main Findings

1. **Strong Independent Effect**: After controlling for prematurity markers (birth weight, gestational age) and complications (pneumothorax), IVH remained strongly associated with neonatal mortality (adjusted OR=4.1, 95% CI: 2.3-7.5).

2. **Substantial Confounding**: The crude association (OR=6.1) was attenuated by 32% after adjustment, indicating that the relationship between IVH and mortality is partially explained by shared risk factors related to prematurity and illness severity.

3. **Pneumothorax as Key Predictor**: Pneumothorax showed the strongest association with mortality (OR=6.2), suggesting that respiratory complications are critical determinants of outcomes in this population.

4. **Dose-Response Relationship**: A clear gradient was observed for birth weight, with the lowest weight category (<1000g) having nearly 9-fold increased odds of death compared to the reference group (1300-1599g).

5. **Gestational Age Effect**: While gestational age categories showed non-significant associations in the multivariable model (p=0.15), this likely reflects collinearity with birth weight rather than lack of clinical importance.

### Why RR is Preferred for Primary Interpretation

- The outcome (in-hospital death) occurred in 19.3% of infants, which is above the usual "rare outcome" range where OR approximates RR.
- OR is mathematically valid for logistic models but tends to exaggerate effect size when outcomes are common.
- RR is more directly interpretable for cohort-style risk communication ("times the risk") and better aligns with clinical/public-health interpretation.
- Therefore, OR and RR are both reported for completeness, but RR is used as the primary effect measure in interpretation.

### Clinical Implications

- IVH represents a **major independent risk factor** for mortality in very low birth weight infants
- Early detection and management of IVH should be prioritized
- Co-occurrence of IVH and pneumothorax identifies an extremely high-risk subgroup (likely >50% mortality)
- Prevention strategies targeting the most premature infants (<28 weeks, <1000g) may have the greatest impact on reducing mortality

### Strengths

- Complete data with no missing values
- Appropriate statistical methods (purposeful selection, both OR and RR reported)
- Robust effect estimates across model specifications
- Excellent model discrimination (c-statistic=0.853)

### Limitations

1. **Collinearity**: High correlation between birth weight and gestational age limits ability to disentangle their independent effects
2. **Residual Confounding**: Unmeasured factors (e.g., severity of IVH, ventilator settings) may still confound the association
3. **Sample Size**: Wide confidence intervals for some estimates, particularly gestational age categories
4. **Temporal Ambiguity**: Cannot determine if some complications (e.g., pneumothorax) occurred before or after IVH

---

## Conclusions

Intraventricular hemorrhage is a strong, independent predictor of neonatal mortality among very low birth weight infants. After adjusting for pneumothorax, birth weight, and gestational age, infants with IVH had **4.1 times higher odds** (OR=4.1, 95% CI: 2.3-7.5) and **2.1 times higher risk** (RR=2.1, 95% CI: 1.4-3.1) of death compared to those without IVH. These findings underscore the critical importance of preventing and managing IVH in this vulnerable population.

---

## References

1. Hosmer DW, Lemeshow S, Sturdivant RX. *Applied Logistic Regression*. 3rd ed. New York: Wiley; 2013. (Purposeful selection workflow, including p<0.25 screening and iterative model reduction.)
2. Mickey RM, Greenland S. The impact of confounder selection criteria on effect estimation. *Am J Epidemiol*. 1989;129(1):125-137. (Rationale for change-in-estimate confounder assessment.)
3. Zhang J, Yu KF. What's the relative risk? A method of correcting the odds ratio in cohort studies of common outcomes. *JAMA*. 1998;280(19):1690-1691. (Why OR diverges from RR when outcome is common.)
4. Zou G. A modified Poisson regression approach to prospective studies with binary data. *Am J Epidemiol*. 2004;159(7):702-706. (RR estimation using Poisson model with log link for binary outcomes.)

**Software:**
- SAS 9.4 (SAS Institute, Cary, NC)
- Procedures: PROC LOGISTIC, PROC GENMOD, PROC FREQ, PROC MEANS

---

## Appendix: Variable Coding

```
IVH:          0 = No IVH, 1 = IVH present
DEAD:         0 = Alive at discharge, 1 = Dead
pneumo:       0 = No pneumothorax, 1 = Pneumothorax
bwt_cat:      1 = <1000g, 2 = 1000-1299g, 3 = 1300-1599g (reference)
gest_cat:     1 = <28 weeks, 2 = 28-31 weeks, 3 = ≥32 weeks (reference)
delivery_new: 1 = C-Section (reference), 2 = Vaginal
twin:         0 = Singleton (reference), 1 = Multiple gestation
inout_new:    1 = Born at Duke (reference), 2 = Transport
```

---

**Report Generated**: February 4, 2026  
**Analysis Code**: [HW1_Analysis.sas](HW1_Analysis.sas)
