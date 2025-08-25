# Keto-CTA audit: reproducibility package
This repository accompanies the "Letter of Concern" submitted to *JACC: Advances* about the paper [Longitudinal Data From the KETO-CTA Study: Plaque Predicts Plaque, ApoB Does Not, **Soto-Mota et al. (2025)**](https://www.jacc.org/doi/10.1016/j.jacadv.2025.101686).  
It reproduces the key figures, statistical checks, and numerical discrepancies cited in the appendix.

## Quick start

```r
# In R / RStudio
source("code/00_download_data.R")
source("code/01_reproduce_figures.R")
source("code/02_linear_model_checks.R")
source("code/03_pct_change_demo.R")
source("code/04_verify_against_paper.R")
```

All outputs are written to **figures/reproduced/** (PNGs) or shown in the console.

## Dependencies
* **R ≥ 4.2**
* CRAN packages: `tidyverse`, `fs`, `performance`, `lmtest`, `see`, `gt`, `patchwork`, `ragg`, `ggtext`

```r
install.packages(c("tidyverse","fs","performance","lmtest",
                   "see","gt","patchwork","ragg","ggtext"))
```

## Directory layout

```text

├─ code/
│  ├─ 00_download_data.R         # grabs public dataset (from: Citizen Science Foundation)
│  ├─ 01_reproduce_figures.R     # reproduces Fig 1 & Fig 2F   ⇢  C1–C3
│  ├─ 02_linear_model_checks.R   # diagnostics & table         ⇢  C5
│  ├─ 03_pct_change_demo.R       # "percent change" demo       ⇢  O1
│  └─ 04_verify_against_paper.R  # sanity-checks vs paper      ⇢  O4
├─ data/                         # raw & processed CSVs
│  └─ raw/
├─ figures/
│  ├─ published                  # screenshots from paper
│  └─ reproduced/                # PNGs saved by scripts
├─ letter_of_concerns.qmd        # Quarto source of the letter + appendix
├─ references.bib                # BibTeX entries cited in the letter
└─ keto-cta-audit.Rproj          # RStudio project file
```

## Script summaries

| Script | Purpose | Links to Letter |
|--------|---------|-----------------|
| **00_download_data.R** | Download · unzip public CSV; fall back to bundled copy. | – |
| **01_reproduce_figures.R** | Recreate Fig 1A/B & Fig 2F with correct axes/IQR shading. | C1–C3 |
| **02_linear_model_checks.R** | (a) Formal assumption tests (Breusch–Pagan, Shapiro, RESET) turned into Table C5, (b) `performance::check_model()` grid for ΔNCPV ∼ CAC<sub>bl</sub>. | C5 |
| **03_pct_change_demo.R** | Compares study’s ratio-of-medians to participant-level % change; prints median / mean / IQR. | O1 |
| **04_verify_against_paper.R** | Verifies baseline means/medians against Table 1 and text | – |

## Letter of Concern

This repository also includes the submitted **letter of concern** in two forms:  
- **letter_of_concerns.qmd** – the Quarto source file (editable, with code and formatting).  
- **letter_of_concerns.pdf** – the final rendered version as submitted to the journal.  

The PDF is provided as a frozen, archival copy of what was sent, while the `.qmd` file shows the underlying source used to generate it.

## Re-use

The code is released under MIT License; data originate from the [Citizen Science Foundation Keto-CTA repository](https://citizensciencefoundation.org/keto-cta/).
