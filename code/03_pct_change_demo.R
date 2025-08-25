# -----------------------------------------------------------------------------
# Script : 03_percent_change_demo.R
# Purpose: Contrast the manuscript’s “percent change” (ratio of medians)
#          with standard participant-level % change for NCPV and PAV.
# Links  : Supports Other issue O1 (non-standard percent-change metric) in
#          the letter/appendix.
# -----------------------------------------------------------------------------

library(tidyverse)
library(fs)

# --------------------------- 1. Load data -----------------------------------
csv_path <- if (file_exists("data/keto-cta-quant-and-semi-quant_dl.csv"))
  "data/keto-cta-quant-and-semi-quant_dl.csv" else
  "data/keto-cta-quant-and-semi-quant.csv"

df <- read_csv(csv_path, show_col_types = FALSE)

# --------------------------- 2. Helper --------------------------------------
pct_change <- function(baseline, followup) {
  pc <- 100 * (followup - baseline) / baseline
  pc[!is.finite(pc)] <- NA_real_          # drop Inf/NaN when baseline = 0
  pc
}

# --------------------------- 3. NCPV ----------------------------------------
pct_ncpv <- pct_change(df$V1_Non_Calcified_Plaque_Volume,
                       df$V2_Non_Calcified_Plaque_Volume)

tbl_ncpv <- tibble(
  outcome         = "NCPV",
  median_pct      = median(pct_ncpv, na.rm = TRUE),
  mean_pct        = mean(pct_ncpv, na.rm = TRUE),
  ratio_of_median = 100 *
    median(df$V2_Non_Calcified_Plaque_Volume - df$V1_Non_Calcified_Plaque_Volume) /
    median(df$V1_Non_Calcified_Plaque_Volume)
)

# --------------------------- 4. PAV -----------------------------------------
pct_pav <- pct_change(df$V1_Percent_Atheroma_Volume,
                      df$V2_Percent_Atheroma_Volume)

tbl_pav <- tibble(
  outcome         = "PAV",
  median_pct      = median(pct_pav, na.rm = TRUE),
  mean_pct        = mean(pct_pav, na.rm = TRUE),
  ratio_of_median = 100 *
    median(df$V2_Percent_Atheroma_Volume - df$V1_Percent_Atheroma_Volume) /
    median(df$V1_Percent_Atheroma_Volume)
)

# --------------------------- 5. Combine & print -----------------------------
result <- bind_rows(tbl_ncpv, tbl_pav)

print(result, width = Inf)
