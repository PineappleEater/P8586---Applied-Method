#!/usr/bin/env Rscript

# HW2: DAGitty + E-value analysis for IVH -> mortality

ensure_pkg <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

ensure_pkg("dagitty")
ensure_pkg("EValue")

library(dagitty)

# DAG specification for HW2
g <- dagitty('dag {
bb="-1,-1,9,6"

IVH [exposure,pos="4,3"]
DEAD [outcome,pos="8,3"]
GEST_AGE [pos="2,4"]
BWT [pos="3,5"]
ACS [pos="1,5"]
CHORIO [pos="0,4"]
DELIVERY [pos="2,2"]
APGAR5 [pos="3,2"]
SEX [pos="2,1"]
PNEUMO [pos="6,2"]

IVH -> DEAD
IVH -> PNEUMO
PNEUMO -> DEAD

GEST_AGE -> IVH
GEST_AGE -> DEAD
GEST_AGE -> BWT
GEST_AGE -> APGAR5
GEST_AGE -> PNEUMO

BWT -> IVH
BWT -> DEAD

ACS -> IVH
ACS -> DEAD

CHORIO -> GEST_AGE
CHORIO -> IVH
CHORIO -> DEAD

DELIVERY -> IVH
DELIVERY -> DEAD

APGAR5 -> IVH
APGAR5 -> DEAD

SEX -> IVH
SEX -> DEAD
}')

adj_sets <- adjustmentSets(g, exposure = "IVH", outcome = "DEAD", type = "minimal")

# Save DAG plot
png("HW2/DAG_HW2.png", width = 1800, height = 1200, res = 200)
plot(g)
dev.off()

# Effect estimate from HW1 final Poisson model
rr <- 2.059
rr_lo <- 1.351
rr_hi <- 3.137

# Manual E-value calculation
evalue_rr <- function(x) {
  x + sqrt(x * (x - 1))
}

e_point <- evalue_rr(rr)
e_ci_lower <- evalue_rr(rr_lo)

# Package-based E-value (for confirmation)
e_pkg <- tryCatch({
  EValue::evalues.RR(rr, lo = rr_lo, hi = rr_hi, true = 1)
}, error = function(e) {
  paste("EValue package call failed:", e$message)
})

lines_out <- c(
  "HW2 DAGitty + E-value Results",
  "================================",
  "",
  "DAG: saved as HW2/DAG_HW2.png",
  "",
  "Minimal sufficient adjustment set(s) from DAGitty:",
  capture.output(print(adj_sets)),
  "",
  "E-value inputs (from HW1 adjusted Poisson model):",
  sprintf("RR = %.3f; 95%% CI = %.3f to %.3f", rr, rr_lo, rr_hi),
  "",
  "Manual E-value calculation:",
  sprintf("E-value for point estimate (RR=%.3f): %.3f", rr, e_point),
  sprintf("E-value for lower CI limit (RR=%.3f): %.3f", rr_lo, e_ci_lower),
  "",
  "EValue package output:",
  capture.output(print(e_pkg))
)

writeLines(lines_out, con = "HW2/Evalue_results.txt")
cat(paste(lines_out, collapse = "\n"))
