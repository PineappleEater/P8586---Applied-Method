# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Academic course repository for **P8586: Applied Methods in Health Services and Outcomes Research**. The repository contains epidemiological/biostatistical analyses using SAS, with emphasis on multivariable regression, causal inference (DAGs), and confounding assessment. Each homework involves analyzing health datasets and producing academic reports in PDF format.

## Build System - Document Generation Workflow

All homework reports follow a **three-stage automated pipeline**:

```
[HW{N}_Report.md] ──Pandoc──> [HW{N}_Report.tex] ──XeLaTeX──> [HW{N}_Report.pdf]
```

### Quick Build Commands

```powershell
# Build a homework report (from HW{N}/Submission/ directory)
.\build_report.ps1

# Keep auxiliary files for debugging
.\build_report.ps1 -KeepAux

# Custom report name
.\build_report.ps1 -ReportName "Custom_Report"
```

### Manual Build Process

```powershell
# Step 1: Markdown → LaTeX
pandoc HW{N}_Report.md -o HW{N}_Report.tex `
  --from markdown --to latex `
  --include-in-header=latex_header.tex `
  --number-sections --table-of-contents `
  --shift-heading-level-by=-1 `
  --highlight-style=tango

# Step 2: LaTeX → PDF (run twice for TOC generation)
xelatex -interaction=nonstopmode HW{N}_Report.tex
xelatex -interaction=nonstopmode HW{N}_Report.tex

# Step 3: Clean up
Remove-Item *.aux, *.log, *.toc, *.out
```

**Prerequisites**: Pandoc, TeX Live/MikTeX with XeLaTeX engine

## Repository Architecture

### Folder Structure

```
HW{N}/
├── HW{N}.md                    # Assignment requirements (read-only)
├── HW{N}_Analysis.sas          # Main SAS analysis script
├── HW{N}_Report.md             # Working draft report
├── HW{N}_DAG_Evalue.R          # R script for causal inference (HW2+)
├── *.sas7bdat                  # SAS datasets
├── LAB_*.sas                   # Instructor reference code
└── Submission/                 # Final submission package
    ├── HW{N}_Report.md         # Final Markdown source
    ├── HW{N}_Report.tex        # Generated LaTeX (intermediate)
    ├── HW{N}_Report.pdf        # Final PDF output (DO NOT delete before rebuilding)
    ├── latex_header.tex        # Shared LaTeX styling template
    ├── build_report.ps1        # Automated build script
    └── DAG_HW{N}.png           # Supporting figures (optional)
```

### Key Files

- **`latex_header.tex`**: Shared LaTeX template controlling PDF layout, fonts (SimSun/Times/Arial), colors (TitleBlue/SoftGray), hyperlinks, and page breaks. **Critical**: Title + TOC on page 1, content starts page 2 via `\clearpage` after `\tableofcontents`.

- **`build_report.ps1`**: PowerShell automation script. Converts MD→TEX→PDF, compiles twice for TOC cross-references, cleans auxiliary files by default.

- **`HW{N}_Analysis.sas`**: Structured SAS workflow following strict section organization (see below).

## SAS Analysis Workflow

### Standardized Section Structure

All `HW{N}_Analysis.sas` files follow this pattern:

```sas
/* STEP 0: Setup */
libname hw "path/to/data";
ODS RTF FILE="results.rtf" STYLE=Journal STARTPAGE=NO;
PROC FORMAT;  /* Define all categorical variable formats */
RUN;

/* STEP 1: Descriptive Statistics */
/* Table 1: Baseline characteristics by exposure (column %) */
/* Table 2: Outcome distribution by covariates (row %) */

/* STEP 2: Unadjusted Association */
/* Crude OR (logistic) and RR (Poisson) */

/* STEP 3: Variable Selection */
/* Purposeful selection with p<0.25 screening */

/* STEP 4: Multivariable Models */
/* Logistic (OR) and Poisson (RR) with confounders */

/* STEP 5: Final Model */
/* Confounding assessment (>20% beta change criterion) */

ODS RTF CLOSE;
```

### Key Patterns

**PROC FORMAT is mandatory** - Define formats before any analysis:
```sas
PROC FORMAT;
    VALUE deadf 0='Alive' 1='Dead';
    VALUE ivhf 0='No IVH' 1='IVH';
    VALUE bwt_catf 1='<1000g' 2='1000-1299g' 3='1300-1599g';
RUN;
```

**Dual estimation approach** - Always report both OR and RR:
```sas
/* Logistic for Odds Ratio */
proc logistic data=dataset;
    class exposure (ref='0') / param=ref;
    model outcome (event='1') = exposure covariates;
run;

/* Poisson for Risk Ratio (preferred when outcome >10%) */
proc genmod data=dataset;
    class exposure (ref='0') / param=ref;
    model outcome = exposure covariates / dist=poisson link=log;
    estimate "Exposure Effect" exposure 1 / exp;
run;
```

**Table generation rules**:
- **Table 1** (baseline by exposure): `PROC FREQ` with `nopercent norow` → column %
- **Table 2** (outcome by covariates): `PROC FREQ` with `nopercent nocol` → row %
- **Continuous variables**: `PROC TTEST` with `ODS SELECT Statistics`

## Naming Conventions

### Files and Folders
- Homework folders: `HW1/`, `HW2/`, ... (capital HW)
- Analysis scripts: `HW{N}_Analysis.sas` (not "Answer" or "Solution")
- Reports: `HW{N}_Report.{md,tex,pdf}` (consistent naming)
- Submission folder: Always `Submission/` (capital S)

### Variables in SAS
- **Original variables**: Lowercase (e.g., `bwt`, `gest`, `pneumo`, `ivh`)
- **Recoded variables**: `_new` suffix (e.g., `Delivery_new`, `Inout_new`)
- **Categorized continuous**: `_cat` suffix (e.g., `bwt_cat`, `gest_cat`)
- **Format names**: Variable + `f` suffix (e.g., `deadf`, `ivhf`, `bwt_catf`)

## Markdown Formatting Standards

### YAML Front Matter (Required)

```yaml
---
title: "Homework N: Your Title"
author: "Xuange Liang"
date: "YYYY-MM-DD"
---
```

### Heading Hierarchy

- Use `##` for main sections (Pandoc converts to `\section{}` with `--shift-heading-level-by=-1`)
- Use `###` for subsections (converts to `\subsection{}`)
- **Never use manual numbering** (e.g., `## 1. Introduction` ✗ → `## Introduction` ✓)
- Pandoc auto-numbers with `--number-sections` flag

### Tables

```markdown
| Variable      | Category | n (%) |
| :------------ | :------- | ----: |
| Age           | <30      | 45    |
```

### Special Formatting

**Two-column bordered code** (for DAGitty syntax):

```latex
\begin{tcolorbox}[colback=SoftGray, colframe=TitleBlue, boxrule=0.5pt]
\begingroup\footnotesize
\noindent\begin{minipage}[t]{0.49\linewidth}
\begin{verbatim}
Left column code
\end{verbatim}
\end{minipage}\hfill
\begin{minipage}[t]{0.49\linewidth}
\begin{verbatim}
Right column code
\end{verbatim}
\end{minipage}
\endgroup
\end{tcolorbox}
```

## Statistical Analysis Guidelines

### Variable Selection (Purposeful Selection Method)

1. **Univariate screening**: Include covariates with p < 0.25
2. **Initial multivariable model**: Fit all candidate variables
3. **Sequential removal**: Drop non-significant (p > 0.10) one at a time
4. **Confounding assessment**: Re-add removed variables; retain if β change >20%
5. **Final model**: Report adjusted estimates with 95% CI

### Confounding Criteria

A variable is a confounder if:
- Associated with exposure (p < 0.05)
- Associated with outcome (p < 0.05)
- NOT on causal pathway (use DAG to verify)
- Changes effect estimate by >20% when removed

### Report Structure

Follow epidemiological format:
1. **Research Question**: Exposure, outcome, population
2. **Methods**: Variable definitions, statistical tests, model selection
3. **Results**: Descriptive tables → Unadjusted → Adjusted models
4. **Discussion**: Interpretation, confounding, limitations
5. **Conclusions**: Clinical/public health implications

## Causal Inference Assignments (HW2+)

### DAG Construction

Use **DAGitty** (R package) to:
- Specify causal relationships in `dag {...}` syntax
- Identify minimal sufficient adjustment sets
- Validate confounder selection

Example R workflow (`HW{N}_DAG_Evalue.R`):
```r
library(dagitty)
g <- dagitty('dag {
  IVH [exposure]
  DEAD [outcome]
  GEST_AGE -> IVH
  GEST_AGE -> DEAD
  IVH -> DEAD
}')
adjustmentSets(g, exposure="IVH", outcome="DEAD")
```

### E-value Calculation

Report E-values for:
1. Point estimate
2. Lower 95% CI limit (more conservative)

**Interpretation**: Minimum strength of unmeasured confounding (on RR scale) needed to nullify observed association.

## PDF Layout Requirements

Current specification (enforced in `latex_header.tex`):

✅ **Page 1**: Title, author, date, table of contents (with clickable links)
✅ **Page 2+**: All sections and content
✅ **Hyperlinks**: Blue, clickable TOC entries and cross-references
✅ **Fonts**: SimSun (Chinese), Times/Arial (English)
✅ **Colors**: TitleBlue (#0066CC), SoftGray (#F5F5F5), AccentOrange (#FF6600)

**Critical Implementation**: The `latex_header.tex` file uses:
```latex
\AtBeginDocument{
  \let\oldtableofcontents\tableofcontents
  \renewcommand{\tableofcontents}{%
    \oldtableofcontents
    \clearpage
  }
}
```
This ensures TOC stays on page 1 with title, while content starts on page 2.

## Common Tasks

### Adding New Homework

1. Create `HW{N}/` folder
2. Copy structure from HW1 (use as template)
3. Update libname paths in `.sas` files
4. Create `HW{N}/Submission/` with `build_report.ps1` and `latex_header.tex`
5. Maintain consistent naming: `HW{N}_Report.*`, `HW{N}_Analysis.sas`

### Preparing Submission

1. Finalize `HW{N}_Report.md` in `Submission/` folder
2. Ensure YAML front matter is complete
3. Run `.\build_report.ps1` to generate PDF
4. Verify PDF layout (title+TOC page 1, content page 2+)
5. Check hyperlinks in TOC work correctly

### Modifying SAS Analysis

- Preserve standardized section structure and comment blocks
- Update ODS RTF output paths consistently
- Verify all categorical variables have formats defined in PROC FORMAT
- Check reference categories in CLASS statements (use `ref='0'` or `ref='first'`)
- Always generate both logistic (OR) and Poisson (RR) models

### Updating LaTeX Styling

When modifying `latex_header.tex`:
- Keep `\AtBeginDocument` wrapper for `\hypersetup` (prevents premature execution)
- Maintain `\clearpage` after `\tableofcontents` redefinition
- Synchronize changes across all `HW{N}/Submission/` folders
- Test build on both HW1 and HW2 to verify consistency

## Troubleshooting

| Issue | Cause | Solution |
|:------|:------|:---------|
| TOC missing | Single LaTeX pass | Run `xelatex` **twice** (TOC needs cross-references) |
| TOC on wrong page | Modified `latex_header.tex` | Verify `\tableofcontents` redefinition with `\clearpage` |
| Raw LaTeX in PDF | `\hypersetup` too early | Wrap in `\AtBeginDocument{}` |
| Wrong heading levels | Manual `###` sections | Use `##` + `--shift-heading-level-by=-1` |
| Build script fails | Missing prerequisites | Install Pandoc and TeX Live/MikTeX |

## Important Notes

- **DO NOT delete existing PDFs before rebuilding** - Build script overwrites them
- **Each homework folder has 1 README.md maximum** - Avoid creating extra md files
- **All code/comments/filenames in English** - Per user preference
- **Test after writing code** - Run build script to verify PDF generation
- **Keep codebase clean** - Remove test files after verification
