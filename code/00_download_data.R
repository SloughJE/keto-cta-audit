# 00_download_clean.R
# ------------------------------------------------------------------------------
# Purpose: obtain keto-CTA plaque data, save a clean CSV in data/
# ------------------------------------------------------------------------------

library(tidyverse)
library(fs)

# ------------------------------ paths & filenames -----------------------------
remote_zip   <- "http://citizensciencefoundation.org/keto-cta-quant-and-semi-quant.csv.zip"

raw_dir      <- path("data", "raw")
local_zip    <- path(raw_dir, "keto-cta.zip")

# canonical filenames inside the repo
fallback_csv  <- path("data", "keto-cta-quant-and-semi-quant.csv")      # bundled copy (read-only)
download_csv  <- path("data", "keto-cta-quant-and-semi-quant_dl.csv")   # created only if download succeeds

dir_create(raw_dir)

# ------------------------------ attempt download ------------------------------
if (!file_exists(download_csv)) {
  message("Attempting remote download …")
  ok <- tryCatch({
    download.file(remote_zip, local_zip, mode = "wb", quiet = TRUE)
    TRUE
  }, error = function(e) {
    message("  Remote download failed: ", e$message)
    FALSE
  })
  
  if (ok && file_exists(local_zip)) {
    unzip(local_zip, exdir = raw_dir, overwrite = TRUE)
    file_move(path(raw_dir, "keto-cta-quant-and-semi-quant.csv"), download_csv)
    message("  Download succeeded → ", download_csv)
  } else {
    message("  Falling back to bundled copy: ", fallback_csv)
  }
} else {
  message("Download already present: ", download_csv)
}

# ------------------------------ choose csv to read ----------------------------
csv_path <- ifelse(file_exists(download_csv), download_csv, fallback_csv)
message("Using data file: ", csv_path)
