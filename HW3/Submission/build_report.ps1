# Homework Report Build Script
# Automates the MD -> TEX -> PDF conversion workflow

param(
    [string]$ReportName = "HW3_Report",
    [switch]$KeepAux = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Academic Report Builder" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if pandoc is installed
if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Pandoc is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Pandoc from: https://pandoc.org/installing.html" -ForegroundColor Yellow
    exit 1
}

# Check if XeLaTeX is installed
if (-not (Get-Command xelatex -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] XeLaTeX is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install TeX Live or MikTeX" -ForegroundColor Yellow
    exit 1
}

# Check if source markdown file exists
if (-not (Test-Path "$ReportName.md")) {
    Write-Host "[ERROR] Source file $ReportName.md not found" -ForegroundColor Red
    exit 1
}

# Step 1: Convert MD to TEX using Pandoc
Write-Host "[1/4] Converting Markdown to LaTeX..." -ForegroundColor Green
pandoc "$ReportName.md" `
    -o "$ReportName.tex" `
    --from markdown `
    --to latex `
    --include-in-header=latex_header.tex `
    --number-sections `
    --table-of-contents `
    --shift-heading-level-by=-1 `
    --highlight-style=tango

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Pandoc conversion failed" -ForegroundColor Red
    exit 1
}
Write-Host "  -> Generated: $ReportName.tex" -ForegroundColor Gray

# Step 2: First XeLaTeX compilation (resolve references)
Write-Host "[2/4] Compiling LaTeX (first pass)..." -ForegroundColor Green
xelatex -interaction=nonstopmode "$ReportName.tex" > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARNING] First XeLaTeX pass completed with warnings" -ForegroundColor Yellow
    Write-Host "  Check $ReportName.log for details" -ForegroundColor Gray
}

# Step 3: Second XeLaTeX compilation (generate TOC and finalize)
Write-Host "[3/4] Compiling LaTeX (second pass)..." -ForegroundColor Green
xelatex -interaction=nonstopmode "$ReportName.tex" > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Second XeLaTeX pass failed" -ForegroundColor Red
    Write-Host "  Check $ReportName.log for details" -ForegroundColor Gray
    exit 1
}
Write-Host "  -> Generated: $ReportName.pdf" -ForegroundColor Gray

# Step 4: Clean up auxiliary files (unless -KeepAux is specified)
if (-not $KeepAux) {
    Write-Host "[4/4] Cleaning up auxiliary files..." -ForegroundColor Green
    Remove-Item -Path "$ReportName.aux", "$ReportName.log", "$ReportName.toc", "$ReportName.out" -ErrorAction SilentlyContinue
    Write-Host "  -> Removed: .aux, .log, .toc, .out files" -ForegroundColor Gray
} else {
    Write-Host "[4/4] Skipping cleanup (auxiliary files preserved)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Build completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Output files:" -ForegroundColor White
Write-Host "  - $ReportName.tex" -ForegroundColor Gray
Write-Host "  - $ReportName.pdf" -ForegroundColor Gray
Write-Host ""
