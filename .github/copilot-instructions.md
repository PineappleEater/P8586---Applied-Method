# Copilot Instructions: P8586 Applied Methods Course

## Project Overview
Academic course repository for P8586 (Applied Methods in Health Services and Outcomes Research). Focus on epidemiological/biostatistical analysis using SAS, with emphasis on multivariable regression, causal inference, and proper handling of confounding.

## Repository Structure
- **`HW{N}/`**: Homework assignment folders, each containing:
  - `HW{N}.md`: Assignment requirements and instructions
  - `HW{N}_Analysis.sas`: Main SAS analysis code
  - `HW{N}_Report.md`: Working draft of written report
  - `HW{N}_Report.md`: Final solution with complete answers
  - `*.sas7bdat`: SAS datasets
  - `LAB_*.sas`: Reference code examples from instructor
  - **`Submission/`**: Final submission package with standardized naming:
    - `HW{N}_Report.md`: Final markdown report
    - `HW{N}_Report.tex`: LaTeX source
    - `HW{N}_Report.pdf`: Final PDF output
    - `latex_header.tex`: Custom LaTeX styling
    - Supporting files (figures, tables, e.g., `DAG_HW{N}.png`)

## SAS Code Conventions

### File Structure Pattern
All SAS analysis files follow this standardized structure (see [HW1/HW1_Analysis.sas](../HW1/HW1_Analysis.sas)):

```sas
/* Header block with title, dataset, exposure/outcome, author, date */
/* STEP 0: Setup - libname, ODS RTF output, PROC FORMAT definitions */
/* STEP 1: Descriptive Statistics - Table 1 (by exposure), Table 2 (by outcome) */
/* STEP 2: Unadjusted Association - crude OR and RR */
/* STEP 3: Variable Selection - purposeful selection with p<0.25 screening */
/* STEP 4: Multivariable Models - logistic and Poisson regression */
/* STEP 5: Final Model - with confounding assessment */
```

### Naming Conventions

**Files and Folders:**
- **Homework folders**: `HW{N}/` (capital letters, sequential numbering)
- **Analysis scripts**: `HW{N}_Analysis.sas`
- **Report files**: `HW{N}_Report.{md,tex,pdf}` (use "Report", not "Answer" or "Solution")
- **Supporting scripts**: `HW{N}_{Purpose}.{R,sas}` (e.g., `HW2_DAG_Evalue.R`)
- **Submission folder**: Always `Submission/` (capital S)

**Variables:**
- Original variables: Lowercase (e.g., `bwt`, `gest`, `pneumo`)
- Recoded variables: Add `_new` suffix (e.g., `Delivery_new`, `Inout_new`)
- Categorized continuous: Add `_cat` suffix (e.g., `bwt_cat`, `gest_cat`)
- Format names: Variable name + 'f' suffix (e.g., `deadf`, `ivhf`, `bwt_catf`)

### Key Patterns

**PROC FORMAT definitions are mandatory** - Define formats for all categorical variables before any analysis:
```sas
PROC FORMAT;
    VALUE outcomef 0='No' 1='Yes';
    VALUE exposuref 0='Unexposed' 1='Exposed';
RUN;
```

**ODS RTF output** - All analysis results export to Word documents:
```sas
ODS RTF FILE="/path/to/results.rtf" STYLE=Journal STARTPAGE=NO;
/* analysis code */
ODS RTF CLOSE;
```

**Table generation rules**:
- **Table 1** (baseline by exposure): Use `PROC FREQ` with `nopercent norow` for column percentages
- **Table 2** (outcome by covariates): Use `PROC FREQ` with `nopercent nocol` for row percentages
- **Continuous variables**: Use `PROC TTEST` with `ODS SELECT Statistics TTests Equality`

**Dual estimation approach** - Both logistic (OR) and Poisson (RR) regression:
```sas
/* Logistic for Odds Ratio */
proc logistic data=dataset;
    class exposure (ref='0') / param=ref;
    model outcome (event='1') = exposure covariates;
run;

/* Poisson for Risk Ratio */
proc genmod data=dataset;
    class exposure (ref='0') / param=ref;
    model outcome (event='1') = exposure covariates / dist=poisson link=log;
    estimate "Exposure Effect" exposure 1 / exp;
run;
```

## Analysis Workflow

### Variable Selection (Purposeful Selection Method)
1. **Univariate screening**: Include covariates with p < 0.25 in association with outcome
2. **Initial multivariable model**: Fit model with all candidate variables
3. **Sequential removal**: Remove non-significant variables (p > 0.10) one at a time
4. **Confounding assessment**: Re-add removed variables individually; retain if beta change >20% (change-in-estimate criterion)
5. **Final model**: Report adjusted effect estimates with 95% CIs

### Report Structure
Reports follow epidemiological paper format:
- **Research Question**: Clear exposure, outcome, study design
- **Methods**: Variable definitions, statistical tests, model selection rationale
- **Results**: Descriptive tables → Unadjusted association → Adjusted models
- **Tables**: Standard epidemiological formatting with column/row percentages as appropriate

## Statistical Guidelines

- **Confounding**: Variables associated with both exposure and outcome (p<0.05) but not on causal pathway
- **Model selection**: Prioritize epidemiological justification over automated stepwise selection
- **Effect measures**: Choose OR vs RR based on outcome frequency (RR preferred when outcome >10%)
- **Missing data**: Document and justify handling approach
- **Categorization**: Create clinically meaningful categories for continuous variables (e.g., birth weight tertiles)

## Common Tasks

**When adding new homework analysis:**
1. Create new `HW{N}/` folder
2. Copy structure from previous HW (see HW1 as template)
3. Update libname path, file paths, and variable names
4. Follow standardized section headers and ODS output pattern
5. Generate both OR (logistic) and RR (Poisson) models

**When preparing Submission folder:**
1. Create `HW{N}/Submission/` folder if not exists
2. Copy final report markdown: `HW{N}_Report.md`
3. Include `latex_header.tex` for consistent PDF formatting
4. Add supporting files (figures like `DAG_HW{N}.png`, tables)
5. Generate LaTeX and PDF: `.md` → `.tex` → `.pdf`
6. Final submission files must use `HW{N}_Report.*` naming (not "Answer" or "Solution")

**When revising analysis code:**
- Preserve section structure and comment blocks
- Update ODS RTF output paths consistently
- Verify PROC FORMAT includes all categorical variables
- Check reference category specifications in CLASS statements

**When writing reports:**
- Use markdown tables for results presentation
- Include both point estimates and 95% CIs
- Provide interpretation in plain language (see [HW1/HW1_Report.md](../HW1/HW1_Report.md))
- Compare unadjusted vs adjusted estimates to assess confounding

## File References
- [LAB_MultiReg_SAS_CODES.sas](../HW1/LAB_MultiReg_SAS_CODES.sas): Instructor-provided reference code examples
- [HW1_Analysis.sas](../HW1/HW1_Analysis.sas): Complete exemplar analysis workflow
- [HW2.md](../HW2/HW2.md): Example of causal inference assignments (DAGs, E-values)
