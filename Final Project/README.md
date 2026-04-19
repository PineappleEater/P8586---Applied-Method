# CEOR Final Project

## Project Summary

This repository contains code, derived data, and supporting documentation for a course final project in applied health services and outcomes research.

The study evaluates **open versus laparoscopic colectomy among patients with colorectal cancer** using the **National Inpatient Sample (NIS)** analytic dataset assigned for **Project 1**.

The repository currently supports the core analytic workflow from:

1. data cleaning and cohort description
2. propensity score estimation and matching
3. matched-cohort outcome analysis

It is organized as a working academic analysis repository rather than a publication-ready software package.

## Research Question

Among patients with colorectal cancer undergoing colectomy, how do inpatient outcomes differ between:

- **open colectomy**
- **laparoscopic colectomy**

## Primary Outcomes

- `DIED`: in-hospital mortality
- `med_comp`: perioperative medical complications

## Analytic Objectives

- build a clean analytic dataset from the course-supplied Project 1 NIS file
- produce baseline descriptive statistics and Table 1
- assess pre-match covariate imbalance using standardized differences
- estimate propensity scores for receipt of open colectomy
- perform 1:1 greedy propensity score matching
- reassess post-match balance
- estimate matched associations for mortality and medical complications
- prepare tables and figures for the presentation and term paper

## Data Source

- **Dataset**: National Inpatient Sample (NIS)
- **Course assignment**: Project 1
- **Study topic**: outcomes of open vs. laparoscopic colectomy in colorectal cancer
- **Reference documents**:
  - [docs/course/Final Project Instructions.md](docs/course/Final%20Project%20Instructions.md)
  - [docs/course/Analytic Datasets.md](docs/course/Analytic%20Datasets.md)

The original raw analytic dataset is **not stored in this repository**.

## Repository Structure

```text
Final Project/
├── README.md
├── code/
│   ├── 01_data_cleaning/
│   │   └── Data Cleaning+Table 1.sas
│   ├── 02_ps_matching/
│   │   └── PS_Matching.sas
│   ├── 03_outcome_analysis/
│   │   └── Person6_PS_Adjusted_Outcome_Analysis.sas
│   └── macros/
│       ├── GREEDMTCH.sas
│       └── Standardized_Difference.sas
├── data/
│   ├── raw/
│   └── derived/
│       └── matches.sas7bdat
├── docs/
│   ├── course/
│   │   ├── Analytic Datasets.md
│   │   └── Final Project Instructions.md
│   └── team/
│       └── instruction.md
└── output/
    ├── figures/
    ├── logs/
    └── tables/
```

## Code Inventory

| Component | File | Purpose | Main Inputs | Main Outputs |
| --- | --- | --- | --- | --- |
| Data cleaning and Table 1 | [code/01_data_cleaning/Data Cleaning+Table 1.sas](code/01_data_cleaning/Data%20Cleaning%2BTable%201.sas) | Cleans variables, recodes covariates, summarizes the cohort, and computes pre-match standardized differences | `proj1_2021_new` | `proj1_clean`, `stddiff_prematch`, descriptive statistics |
| Propensity score matching | [code/02_ps_matching/PS_Matching.sas](code/02_ps_matching/PS_Matching.sas) | Estimates propensity scores, performs greedy matching, evaluates post-match balance, and prepares Love Plot data | `proj1_clean`, macros | `propen`, `matches`, `stddiff_postmatch`, `loveplot_data` |
| Matched outcome analysis | [code/03_outcome_analysis/Person6_PS_Adjusted_Outcome_Analysis.sas](code/03_outcome_analysis/Person6_PS_Adjusted_Outcome_Analysis.sas) | Analyzes matched outcomes for `DIED` and `med_comp`, prepares summary tables, and exports forest-plot-ready data | `matches` | matched outcome results, CSV summaries, forest plot data |
| Matching macro | [code/macros/GREEDMTCH.sas](code/macros/GREEDMTCH.sas) | Implements greedy 5-to-1 digit matching | `propen` with `prob` | matched pair dataset |
| Standardized difference macro | [code/macros/Standardized_Difference.sas](code/macros/Standardized_Difference.sas) | Computes standardized differences for continuous and categorical covariates | cleaned or matched cohort | SMD output table |

## Intended Analysis Workflow

### 1. Data cleaning and cohort characterization

Run:

- [code/01_data_cleaning/Data Cleaning+Table 1.sas](code/01_data_cleaning/Data%20Cleaning%2BTable%201.sas)

This script:

- reads the Project 1 analytic dataset
- recodes key variables such as `AGE_CAT`, `PAYER`, and `PATIENT_LOC`
- verifies complication definitions
- generates descriptive statistics by treatment group
- computes pre-match standardized differences

### 2. Propensity score estimation and matching

Run:

- [code/02_ps_matching/PS_Matching.sas](code/02_ps_matching/PS_Matching.sas)

This script:

- estimates the probability of receiving open colectomy
- uses greedy 1:1 matching based on propensity score digits
- checks matched sample size
- computes post-match standardized differences
- prepares post-match propensity score distributions and Love Plot inputs

### 3. Matched outcome analysis

Run:

- [code/03_outcome_analysis/Person6_PS_Adjusted_Outcome_Analysis.sas](code/03_outcome_analysis/Person6_PS_Adjusted_Outcome_Analysis.sas)

This script:

- reads the matched cohort
- verifies matched-pair structure
- summarizes event rates by treatment group
- fits conditional logistic regression models for `DIED` and `med_comp`
- computes a matched-pair odds ratio sensitivity analysis
- exports summary tables and forest plot source data

## Current Repository Status

The repository is now organized by function and contains the major scripts needed for the main study workflow.

### Available now

- core SAS scripts for data cleaning, matching, and matched outcome analysis
- matching and standardized difference macros
- course instructions and team notes
- one derived matched dataset: [data/derived/matches.sas7bdat](data/derived/matches.sas7bdat)

### Matched dataset currently present

The repository includes a derived matched cohort:

- file: [data/derived/matches.sas7bdat](data/derived/matches.sas7bdat)
- total records: `46,322`
- matched pairs: `23,161`
- treatment allocation in matched cohort:
  - `23,161` open
  - `23,161` laparoscopic

These counts were confirmed from the stored matched dataset in the local workspace.

## Known Gaps

The repository is useful for ongoing analysis, but it is **not yet fully reproducible from raw data**.

Missing or not yet stored here:

- the original Project 1 raw analytic dataset
- a committed local copy of `proj1_clean`
- a committed local copy of `propen`
- saved pre-match and post-match SMD outputs
- final exported tables and figures under `output/`
- Person 3 multivariable mortality model code
- Person 4 multivariable medical complication model code
- manuscript draft and slide deck files inside the repository

## Reproducibility Notes

The scripts remain environment-specific.

Current limitations include:

- absolute `libname` paths tied to different user environments
- absolute `%include` paths in SAS scripts
- a Windows-specific project path in the matched outcome script

As a result, the repository structure is cleaner than before, but the code has **not** yet been path-normalized across environments.

Before rerunning the full pipeline in one location, update:

- all `libname` statements
- all `%include` paths
- any hard-coded output directories

## Team Notes and Coordination

Internal planning notes are stored in:

- [docs/team/instruction.md](docs/team/instruction.md)

That file contains:

- role assignments
- working deadlines
- project links used by the group
- discussion notes about scope and coordination

## External Collaboration Links

The team notes reference the following working documents:

- PPT:
  - <https://gamma.app/docs/Open-vs-Laparoscopic-Colectomy-in-Colorectal-Cancer-e9dd1n0c42augij>
- Google Slides:
  - <https://docs.google.com/presentation/d/1TcijiyvVrk7Xm1Begd8E4IoBcq36c4CmoqgnOPxK3Xo/edit?slide=id.p3#slide=id.p3>
- Paper:
  - <https://docs.google.com/document/d/1aYTgKZkI11bgUQxntklT6S4oU2ryggxOfYPBY_GpJ9Q/edit?tab=t.y88mxnzffqbx>
- Table 1:
  - <https://docs.google.com/spreadsheets/d/1hVUxrPsseAm-XomiwXncBf4P4NwvHdSS00r8h9eM9mU/edit?usp=sharing>

## Recommended Next Repository Improvements

Without changing the analytic logic, the next sensible repository upgrades would be:

1. standardize all SAS path configuration in one place
2. save intermediate datasets into `data/derived/`
3. write exported tables into `output/tables/`
4. write exported figures into `output/figures/`
5. add the missing regression scripts for the remaining analytic components
6. add manuscript and slide files or stable links to versioned exports

## Summary

This repository now provides a cleaner, more navigable foundation for the final project. It captures the main code assets for:

- cohort preparation
- propensity score matching
- matched outcome analysis

The main remaining work is to improve portability, fill the missing analytic components, and store final study outputs in a consistent, reproducible way.
