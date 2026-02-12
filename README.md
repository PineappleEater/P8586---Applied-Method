# P8586 - Applied Methods (Course Repository)

This repository stores homework analyses, reports, and submission artifacts for **P8586: Applied Methods in Health Services and Outcomes Research**.

## Project Structure

```
P8586---Applied-Method/
├── HW1/
│   ├── HW1.md                    # Assignment requirements
│   ├── HW1_Analysis.sas          # SAS analysis code
│   ├── HW1_Report.md             # Draft report
│   └── Submission/               # Final submission package
│       ├── HW1_Report.md         # Final Markdown source
│       ├── HW1_Report.tex        # Generated LaTeX (intermediate)
│       ├── HW1_Report.pdf        # Final PDF output
│       ├── latex_header.tex      # LaTeX styling template
│       └── build_report.ps1      # Automated build script
├── HW2/
│   └── Submission/               # Same structure as HW1
└── README.md                     # This file
```

## Document Generation Workflow

All homework reports follow a **three-stage automated pipeline**:

```
[HW{N}_Report.md] ──Pandoc──> [HW{N}_Report.tex] ──XeLaTeX──> [HW{N}_Report.pdf]
```

### Prerequisites

1. **Pandoc** - Universal document converter
   - Download: https://pandoc.org/installing.html
   - Verify installation: `pandoc --version`

2. **TeX Live / MikTeX** - LaTeX distribution with XeLaTeX engine
   - TeX Live: https://www.tug.org/texlive/
   - MikTeX: https://miktex.org/
   - Verify installation: `xelatex --version`

### Quick Build (Automated)

```powershell
cd HW{N}/Submission
.\build_report.ps1
```

The script will:
1. Convert Markdown to LaTeX using Pandoc
2. Compile LaTeX to PDF using XeLaTeX (two passes for TOC)
3. Clean up auxiliary files (.aux, .log, .toc, .out)

### Manual Build (Step-by-Step)

```powershell
# Step 1: Markdown → LaTeX conversion
pandoc HW{N}_Report.md -o HW{N}_Report.tex `
  --from markdown --to latex `
  --include-in-header=latex_header.tex `
  --number-sections --table-of-contents `
  --shift-heading-level-by=-1 `
  --highlight-style=tango

# Step 2: LaTeX → PDF compilation (run twice for TOC generation)
xelatex -interaction=nonstopmode HW{N}_Report.tex
xelatex -interaction=nonstopmode HW{N}_Report.tex

# Step 3: Clean up auxiliary files (optional)
Remove-Item *.aux, *.log, *.toc, *.out
```

## Markdown Formatting Standards

### YAML Front Matter (Required)

Every report must start with metadata:

```yaml
---
title: "Homework N: Your Title"
author: "Your Name"
date: "YYYY-MM-DD"
---
```

### Heading Hierarchy

- **Use `##` for main sections** (Pandoc will convert to `\section{}`)
- **Use `###` for subsections** (converts to `\subsection{}`)
- **Avoid manual numbering** (e.g., `## 1. Introduction` → `## Introduction`)
- Pandoc automatically numbers sections with `--number-sections` flag

**Why `--shift-heading-level-by=-1`?**
- Markdown `##` → LaTeX `\section{}`
- Markdown `###` → LaTeX `\subsection{}`
- This prevents `##` from becoming `\chapter{}` in book-style documents

### Tables

Use pipe-separated format with alignment markers:

```markdown
| Variable      | Category | n (%) |
| :------------ | :------- | ----: |
| Age           | <30      | 45    |
| Gender        | Male     | 120   |
```

### Mathematical Formulas

- **Inline math**: `$\beta_0 + \beta_1 x$`
- **Display math**: `$$ E = mc^2 $$`
- **Aligned equations**: Use LaTeX `align` environment in math blocks

### Code Blocks

Always specify language for syntax highlighting:

````markdown
```r
# R code
lm(y ~ x, data = df)
```

```sas
/* SAS code */
PROC REG DATA=dataset;
  MODEL y = x;
RUN;
```

```text
Plain text output
```
````

### Images

Use Pandoc's image attributes for sizing:

```markdown
![DAG for Confounding Analysis](DAG_HW2.png){ width=80% }
```

### Special Formatting

For **bordered two-column code display** (e.g., DAGitty syntax):

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

## PDF Layout Requirements

### Current Format Specifications

✅ **Title and Table of Contents on Page 1**
- Document title, author, and date appear at the top of page 1
- Table of contents immediately follows on the same page
- Hyperlinks in TOC are clickable and functional

✅ **Content Starts on Page 2**
- All sections begin on page 2 after a page break
- Implemented via `\clearpage` after `\tableofcontents` in `latex_header.tex`

### LaTeX Styling (`latex_header.tex`)

Key features:
- **Fonts**: Uses system fonts (SimSun for Chinese, Times/Arial for English)
- **Colors**: Custom palette (TitleBlue, SoftGray, AccentOrange)
- **Hyperlinks**: Blue clickable links with `hyperref` package
- **Page Layout**: 1-inch margins, header with section titles
- **Section Numbering**: Automatic with customizable depth

## Submission Format Requirements

Each homework submission must include:

- ✅ Document title from YAML metadata
- ✅ Author name and submission date
- ✅ Table of contents with clickable section links
- ✅ Numbered sections following epidemiologic structure:
  1. Research Question
  2. Methods
  3. Results
  4. Discussion
  5. Conclusions
- ✅ Proper heading hierarchy (`##` for sections, `###` for subsections)
- ✅ No duplicate metadata (avoid redundant student/date blocks if already in YAML)

## Analysis and Reporting Standards

### Epidemiologic Flow

Follow a consistent structure:

1. **Research Question** - Clear objective statement
2. **Methods** - Study design, population, statistical approach
3. **Results** - Descriptive statistics, regression models, tables
4. **Discussion** - Interpretation, limitations, clinical relevance
5. **Conclusions** - Summary and implications

### Statistical Reporting

- **Point Estimates + 95% CI**: Always report both for effect measures
- **Binary Outcomes**:
  - Logistic regression → Odds Ratios (OR)
  - Poisson log-link → Risk Ratios (RR)
  - **Emphasize RR when outcome is common** (>10% prevalence)
- **Tables**: Include plain-language interpretation below each major table
- **Figures**: Use captions and reference in text

### SAS Coding Conventions

#### Workflow Structure

```sas
/* 1. Setup and Data Preparation */
PROC FORMAT;
  VALUE sexfmt 1='Male' 2='Female';
RUN;

/* 2. Descriptive Statistics (Table 1) */
PROC FREQ DATA=dataset;
  TABLES exposure*outcome / CHISQ;
RUN;

/* 3. Unadjusted Association */
PROC LOGISTIC DATA=dataset;
  MODEL outcome(event='1') = exposure;
RUN;

/* 4. Covariate Screening (Purposeful Selection) */
/* Test each potential confounder */

/* 5. Final Multivariable Models */
PROC LOGISTIC DATA=dataset;
  MODEL outcome(event='1') = exposure confounder1 confounder2;
RUN;
```

#### Variable Naming Patterns

- **Original variables**: Lowercase (e.g., `bwt`, `gest`, `ivh`)
- **Recoded variables**: Append `_new` (e.g., `sex_new`, `pnc_new`)
- **Categorized continuous variables**: Append `_cat` (e.g., `bwt_cat`, `gest_cat`)

#### Categorical Variable Formatting

```sas
PROC FORMAT;
  VALUE bwtfmt
    1='<750g'
    2='750-999g'
    3='1000-1499g';
  VALUE gestfmt
    1='<26 weeks'
    2='26-28 weeks'
    3='>28 weeks';
RUN;

DATA analysis;
  SET raw;
  FORMAT bwt_cat bwtfmt. gest_cat gestfmt.;
RUN;
```

## Causal Inference Homework (DAG/E-value)

### DAG-Based Confounder Selection

- Use **DAGitty** (http://dagitty.net/) for causal diagram construction
- Document DAG syntax in report for reproducibility
- Identify **minimal sufficient adjustment sets** from DAG
- Justify variable selection based on causal assumptions, not just statistics

### E-Value Calculation

For sensitivity analysis, report E-values for:
1. **Main effect estimate** (point estimate)
2. **Lower confidence limit** (more conservative)

**Interpretation**: E-value represents the minimum strength of unmeasured confounding (on RR scale) needed to explain away the observed association.

## Troubleshooting

### Common Build Errors

| Error | Cause | Solution |
|:------|:------|:---------|
| `pandoc: command not found` | Pandoc not installed | Install Pandoc and add to PATH |
| `xelatex: command not found` | TeX distribution missing | Install TeX Live or MikTeX |
| PDF shows wrong title | Incorrect YAML metadata | Check front matter in `.md` file |
| TOC missing or incomplete | Single LaTeX compilation | Run `xelatex` **twice** (TOC needs two passes) |
| Image not found | Incorrect relative path | Verify image file is in `Submission/` folder |
| Raw LaTeX visible in PDF | `\hypersetup` executed too early | Ensure `latex_header.tex` uses `\AtBeginDocument{}` |

### Build Script Options

```powershell
# Keep auxiliary files for debugging
.\build_report.ps1 -KeepAux

# Custom report name
.\build_report.ps1 -ReportName "Custom_Report"
```

## Reference Files

- **Project conventions**: `.github/copilot-instructions.md`
- **LaTeX template**: `HW{N}/Submission/latex_header.tex`
- **Build automation**: `HW{N}/Submission/build_report.ps1`

---

**Last Updated**: February 12, 2026
**Build System Status**: ✅ All systems operational
