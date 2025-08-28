# -----------------------------------------------------------------------------
# Script : 03_percent_change_demo.R
# Purpose: Contrast the manuscript’s “percent change” (ratio of medians)
#          with standard participant-level % change for NCPV and PAV.
# Links  : Supports Other issue O1 (non-standard percent-change metric) in
#          the letter/appendix.
# -----------------------------------------------------------------------------

library(tidyverse)
library(fs)

csv_path <- if (file_exists("data/keto-cta-quant-and-semi-quant_dl.csv"))
  "data/keto-cta-quant-and-semi-quant_dl.csv" else
  "data/keto-cta-quant-and-semi-quant.csv"

df <- read_csv(csv_path, show_col_types = FALSE)

# pct change function
pct_change <- function(baseline, followup, verbose = FALSE) {
  pc  <- 100 * (followup - baseline) / baseline
  bad <- is.nan(pc) | is.infinite(pc)       # only Inf/NaN (e.g., baseline == 0)
  if (verbose) message(sum(bad, na.rm = TRUE), " value(s) replaced with NA")
  pc[bad] <- NA_real_
  pc
}


# NCPV
pct_ncpv <- pct_change(df$V1_Non_Calcified_Plaque_Volume,
                       df$V2_Non_Calcified_Plaque_Volume, verbose = TRUE)

tbl_ncpv <- tibble(
  outcome         = "NCPV",
  median_pct      = median(pct_ncpv, na.rm = TRUE),
  mean_pct        = mean(pct_ncpv, na.rm = TRUE),
  ratio_of_median = 100 *
    median(df$V2_Non_Calcified_Plaque_Volume - df$V1_Non_Calcified_Plaque_Volume) /
    median(df$V1_Non_Calcified_Plaque_Volume)
)

# PAV
pct_pav <- pct_change(df$V1_Percent_Atheroma_Volume,
                      df$V2_Percent_Atheroma_Volume, verbose = TRUE)

tbl_pav <- tibble(
  outcome         = "PAV",
  median_pct      = median(pct_pav, na.rm = TRUE),
  mean_pct        = mean(pct_pav, na.rm = TRUE),
  ratio_of_median = 100 *
    median(df$V2_Percent_Atheroma_Volume - df$V1_Percent_Atheroma_Volume) /
    median(df$V1_Percent_Atheroma_Volume)
)

result <- bind_rows(tbl_ncpv, tbl_pav)

print(result)
