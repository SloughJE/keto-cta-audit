# -----------------------------------------------------------------------------
# Script : 02_linear_model_checks.R
# Purpose: (i) Produce the GT summary table of assumption tests for four
#          Δ-NCPV baseline models; (ii) save a 5-panel diagnostic grid for
#          ΔNCPV ~ CAC_bl using performance::check_model().
# Links  : Supports Critical issue C5 (model-assumption violations) and the
#          GT table/diagnostic figure cited in Appendix C5.
# -----------------------------------------------------------------------------

# Assumption checks

library(tidyverse)
library(performance)   # model_performance()
library(lmtest)        # bptest(), resettest()
library(gt)
library(lmtest)
library(patchwork)
library(see)

csv_path <- if (fs::file_exists("data/keto-cta-quant-and-semi-quant_dl.csv")) {
  "data/keto-cta-quant-and-semi-quant_dl.csv"   # downloaded copy, if it exists
} else {
  "data/keto-cta-quant-and-semi-quant.csv"      # bundled fallback
}

df <- read_csv(csv_path)
# create change scores for each Plaque metric
df <- df %>%
  mutate(
    delta_NCPV = V2_Non_Calcified_Plaque_Volume - V1_Non_Calcified_Plaque_Volume,
    delta_TPS  = V2_Total_Plaque_Score - V1_Total_Plaque_Score,
    delta_PAV  = V2_Percent_Atheroma_Volume - V1_Percent_Atheroma_Volume,
    delta_PAV_pct  = (V2_Percent_Atheroma_Volume - V1_Percent_Atheroma_Volume)*100,
    V1_PAV_pct = V1_Percent_Atheroma_Volume * 100
  )
assumption_report <- function(formula, data, label = NULL) {
  m    <- lm(formula, data = data)
  n    <- nobs(m)
  p    <- length(coef(m))
  perf <- performance::model_performance(m)
  
  # tests
  sh   <- shapiro.test(residuals(m))
  bp   <- bptest(m)
  rst  <- resettest(m, power = 2:3, type = "fitted")
  
  # influence diagnostics
  cd   <- cooks.distance(m)
  h    <- hatvalues(m)
  rs   <- rstudent(m)
  cut_cd <- 4 / n
  
  tibble(
    model        = if (length(label)) label else deparse(formula),
    n            = n,
    slope        = unname(coef(m)[2]),
    slope_p      = coef(summary(m))[2, "Pr(>|t|)"],
    r2           = perf$R2,
    r2_adj       = perf$R2_adjusted,
    rmse         = perf$RMSE,
    # assumption tests
    bp_p         = bp$p.value,        # homoskedasticity
    shapiro_p    = sh$p.value,        # normality
    reset_p      = rst$p.value,       # linearity/specification
    # influence summary
    cooks_cut    = cut_cd,
    cooks_n      = sum(cd > cut_cd, na.rm = TRUE),
    cooks_prop   = mean(cd > cut_cd, na.rm = TRUE),
    cooks_max    = max(cd, na.rm = TRUE),
    cooks_ge1    = any(cd >= 1, na.rm = TRUE),
    leverage_hi2 = sum(h > 2 * p / n, na.rm = TRUE),
    leverage_hi3 = sum(h > 3 * p / n, na.rm = TRUE),
    rstud_gt3    = sum(abs(rs) > 3, na.rm = TRUE)
  )
}

# --- Named models (labels are the names) ---
forms <- list(
  `ΔNCPV ~ CAC_bl`  = delta_NCPV ~ V1_CAC,
  `ΔNCPV ~ NCPV_bl` = delta_NCPV ~ V1_Non_Calcified_Plaque_Volume,
  `ΔNCPV ~ PAV_bl`  = delta_NCPV ~ V1_PAV_pct,
  `ΔNCPV ~ TPS_bl`  = delta_NCPV ~ V1_Total_Plaque_Score
)

# Build results using labels
assumption_tbl <- purrr::imap_dfr(forms, ~assumption_report(.x, data = df, label = .y))

# --- Formatting helpers (vectorized) ---
fmt_p <- function(p, small = 0.001) ifelse(
  is.na(p), "—",
  ifelse(p < small, "<0.001", formatC(p, format = "f", digits = 3))
)

fmt_num <- function(x, digits = 2) ifelse(
  is.na(x), "—", formatC(x, format = "f", digits = digits)
)

flag <- function(p, red = 0.05, amber = 0.10) dplyr::case_when(
  is.na(p)  ~ "—",
  p < red   ~ "Violation",
  p < amber ~ "Borderline",
  TRUE      ~ "OK"
)

# Beta cell: show β and slope p-value
cell_beta <- function(b, p) {
  paste0(
    "&beta; = ", fmt_num(b),
    "<br/><span>p = ", fmt_p(p), "</span>"
  )
}

cell_compact <- function(p) {
  s <- flag(p)
  col <- dplyr::case_when(
    s == "Violation"  ~ "#E53935",
    s == "Borderline" ~ "#F9A825",
    s == "OK"         ~ "#2E7D32",
    TRUE              ~ "inherit"
  )
  paste0(
    "<span style='font-weight:700;color:", col, "'>", s, "</span>",
    "<br/><span>p = ", fmt_p(p), "</span>"
  )
}

# Subscript only the `_bl` suffix in labels
sub_bl <- function(x) gsub("_bl\\b", "<sub>bl</sub>", x, perl = TRUE)

assumption_summary <- assumption_tbl %>%
  transmute(
    Model              = sub_bl(model),
    Beta               = cell_beta(slope, slope_p),          
    Linearity          = cell_compact(reset_p),              # RESET
    `Constant Variance`= cell_compact(bp_p),                 # Breusch–Pagan
    `Residual Normality` = cell_compact(shapiro_p)           # Shapiro–Wilk
  )

assumption_summary <- assumption_summary %>%
  mutate(Model = paste0("<strong>", Model, "</strong>"))

gt_tbl <- assumption_summary %>%
  gt() %>%
  # render subscripts + colored status/p-values + beta
  fmt_markdown(columns = c(Model, Beta, Linearity, `Constant Variance`, `Residual Normality`)) %>%
  # nicer headers (β as header label)
  cols_label(
    Beta = "β",
    `Constant Variance` = "Constant Variance",
    `Residual Normality` = "Residual Normality"
  ) %>%
  # layout & sizing
  cols_align(align = "left",   columns = Model) %>%
  cols_align(align = "center", columns = c(Beta, Linearity, `Constant Variance`, `Residual Normality`)) %>%
  cols_width(
    Model ~ px(420),
    Beta  ~ px(220),
    c(Linearity, `Constant Variance`, `Residual Normality`) ~ px(240)
  ) %>%
  tab_options(
    table.align = "center",
    table.width = pct(90),
    table.font.size = px(22),
    column_labels.font.size = px(20),
    data_row.padding = px(6),
    heading.border.bottom.color = "transparent",
    column_labels.border.top.color = "transparent",
    column_labels.border.bottom.color = "#cfcfcf",
    table.border.top.color = "transparent",
    table.border.bottom.color = "transparent"
  ) %>%
  opt_row_striping() %>%
  tab_style(
    style = cell_text(weight = "bold"),
    locations = cells_column_labels(everything())
  )

gtsave(gt_tbl, "figures/reproduced/LM_assumptions.png", vwidth = 1400, vheight = 900, expand = 0)



#############
# ---------------------------------------------------------------------------
# Purpose  : Save the full performance::check_model diagnostic grid
#            for the model ΔNCPV ~ CAC_bl.  This is the same function
#            the original authors report having used to “corroborate”
#            linear-model assumptions.  The grid visually confirms the
#            violations flagged in Table C5 of the Appendix.
# ---------------------------------------------------------------------------

# fit model
m_cac   <- lm(delta_NCPV ~ V1_CAC, data = df)

# one combined grid (5 panels) returned as a patchwork object

# ---- diagnostics as patchwork ----
cm_list <- performance::check_model(m_cac)   # list
p        <- plot(cm_list) + plot_annotation(
  title = "ΔNCPV ~ CAC_bl",
  theme = theme(plot.title = element_text(hjust = 0.5, face = "bold"))
)

# save
out_path <- "figures/reproduced/checkmodel_deltaNCPV_CAC.png"
ggsave(out_path, p,
       device = ragg::agg_png,
       width = 8, height = 10, units = "in",
       dpi = 800, bg = "white")

message("Diagnostic grid saved to: ", out_path)
