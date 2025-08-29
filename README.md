# Keto-CTA audit: reproducibility package
This repository accompanies the "Letter of Concern" submitted to *JACC: Advances* about the paper [Longitudinal Data From the KETO-CTA Study: Plaque Predicts Plaque, ApoB Does Not; **Soto-Mota et al. (2025)**](https://www.jacc.org/doi/10.1016/j.jacadv.2025.101686).  
It reproduces the key figures, statistical checks, and numerical discrepancies cited in the appendix.

## Data source and variable scope

CT angiography–derived plaque-burden metrics (PAV, TPS, CAC, NCPV) at baseline and follow-up were obtained from the 
Citizen Science Foundation [keto-CTA repository](https://citizensciencefoundation.org/keto-cta/). These are the same per-participant plaque metrics used in the publication; 
basic levels and change checks match the reported values. No other variables (e.g., ApoB, LDL or other lipids, demographics) are 
available. Analyses are therefore restricted to specifications that rely solely on plaque-burden metrics; 
models requiring non-plaque variables could not be examined.

## Usage

1. Clone the repository and open the `keto-cta-audit.Rproj` in RStudio (or set the working directory to the project root in any R session).  
2. Run the scripts (all scripts are standalone):  
   - `00_download_clean.R` – downloads/unzips the dataset (or falls back to bundled CSV).  
   - `01_reproduce_figures.R` – recreates Figures 1A, 1B, and 2F.  
   - `02_linear_model_checks.R` – assumption checks and diagnostics.  
   - `03_pct_change.R` – percent change calculations.  
   - `04_verify_against_paper.R` – compares metrics from paper to dataset to confirm consistency 
3. All outputs are written to `figures/reproduced/` or printed in the console.

## Dependencies
* **R ≥ 4.2** (tested with R 4.4.1 on macOS)  
* CRAN packages: `tidyverse`, `fs`, `performance`, `lmtest`, `see`, `gt`, `patchwork`, `ragg`, `ggtext`,`psych`

```r
install.packages(c("tidyverse","fs","performance","lmtest",
                   "see","gt","patchwork","ragg","ggtext","psych"))
```

## Directory layout

```text

├─ code/
│  ├─ 00_download_data.R         # grabs public dataset (from: Citizen Science Foundation)
│  ├─ 01_reproduce_figures.R     # reproduces Fig 1 & Fig 2F   ⇢  C1–C3
│  ├─ 02_linear_model_checks.R   # diagnostics & table         ⇢  C5 / M1; (C4)
│  ├─ 03_pct_change_demo.R       # "percent change" demo       ⇢  O1
│  └─ 04_verify_against_paper.R  # sanity-checks vs paper        
├─ data/                         # raw & processed CSVs
│  └─ raw/
├─ figures/
│  ├─ published                  # screenshots from paper
│  └─ reproduced/                # saved reproductions of charts
├─ letter_of_concerns.qmd        # Quarto source of the letter + appendix
├─ references.bib                # BibTeX entries cited in the letter
└─ keto-cta-audit.Rproj          # RStudio project file
```

## Script summaries

| Script | Purpose | Links to Letter |
|--------|---------|-----------------|
| **00_download_data.R** | Download · unzip public CSV; fall back to bundled copy. | – |
| **01_reproduce_figures.R** | Recreate Fig 1A/B & Fig 2F with correct axes/IQR shading. | C1–C3 |
| **02_linear_model_checks.R** | (a) Formal assumption tests (Breusch–Pagan, Shapiro, RESET) turned into Table C5, (b) `performance::check_model()` grid for ΔNCPV ∼ CAC<sub>bl</sub>. Supplementary analysis for M1 | C5, M1 |
| **03_pct_change_demo.R** | Compares study’s ratio-of-medians to participant-level % change; prints median / mean / IQR. | O1 |
| **04_verify_against_paper.R** | Verifies baseline means/medians against Table 1 and text | – |

## Letter of Concern

This repository also includes the submitted **letter of concern** in two forms:  
- **letter_of_concerns.qmd** – the Quarto source file (editable, with code and formatting).  
- **letter_of_concerns.pdf** – the final rendered version as submitted to the journal.  

The PDF is provided as a frozen, archival copy of what was sent, while the `.qmd` file shows the underlying source used to generate it.

Note: This repository is an independent statistical audit accompanying a letter of concern. It is not affiliated with the original study authors or their institutions.

## Re-use

The code is released under MIT License; data originate from the [Citizen Science Foundation Keto-CTA repository](https://citizensciencefoundation.org/keto-cta/).
