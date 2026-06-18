# Climate and Malaria across Ghana's 16 Regions

An ecological and **spatial-statistics** study of how rainfall, temperature and
humidity relate to malaria across **Ghana's 16 regions**, set in the African
context. Built in **R** from open, up-to-date data (DHS, World Bank, NASA POWER,
geoBoundaries).

> Climate normals explain about **72% of the between-region variation** in malaria
> prevalence (adjusted R²; 79% via a GAM). Malaria is strongly **spatially
> clustered** (Moran's I = 0.49, p < 0.001), concentrated in the warmer, drier
> northern and middle-belt regions.

---

## 🔗 Read the report
**[▶ Full report (HTML)](https://kingsley-amg.github.io/ghana-malaria-climate/)**, maps, models and interpretation, knitted from R Markdown.
A **PDF version** is in [`report/`](report/).

## 🔬 What it does
- **Africa context**, Ghana's malaria incidence vs other African countries (World Bank, to 2024) and the national trend.
- **Climate by region**, monthly rainfall, temperature and humidity (NASA POWER, 2014-2024) at each region's centroid, summarised to long-run normals, plus a seasonality profile (single-peak north vs double-peak south).
- **Malaria by region**, DHS rapid-test prevalence (2022), mapped across all 16 regions.
- **Advanced statistics:**
  - Ecological **multiple regression** (standardised, with 95% CIs and a VIF multicollinearity check)
  - A **generalised additive model (GAM, mgcv)** for the non-linear temperature effect
  - **Spatial autocorrelation**, Moran's I on malaria and on regression residuals (spdep)

## 🔑 Key findings
- Malaria prevalence ranges from ~3% (Greater Accra) to ~34% in the north.
- The strongest climate correlates are **humidity (-)** and **temperature (+)**; the warmer, drier north carries the highest burden.
- **Significant spatial clustering** (Moran's I = 0.49, p < 0.001).
- Supports **climate-informed, regionally targeted** malaria control.

## 🗂️ Structure
```
ghana-malaria-climate/
├── 01_extract.R                 # pull malaria + climate data and region boundaries
├── malaria_climate_analysis.Rmd # the full analysis (source)
├── data/                        # extracted CSVs + ghana_adm1.geojson
├── docs/index.html              # knitted HTML report (GitHub Pages)
└── report/                      # PDF version
```

## 🔁 Reproduce
```r
install.packages(c("tidyverse","sf","mgcv","spdep","car","broom","scales","rmarkdown","jsonlite"))
Rscript 01_extract.R
rmarkdown::render("malaria_climate_analysis.Rmd")
```

## 🧰 Data & tools
R · sf · mgcv (GAM) · spdep (spatial stats) · car, with the **DHS Program API**,
**World Bank Open Data**, **NASA POWER** (climate) and **geoBoundaries**.

## ⚠️ Note
Ecological cross-section of 16 regions (small n): associations are suggestive, not
causal, and may be confounded by socio-economic factors (housing, bed nets, health
access). Malaria is measured at survey years, so seasonal rainfall-lag effects are
not modelled directly.

## 👤 Author
**Kingsley Amegah**, Health Data Scientist · GitHub: [@Kingsley-amg](https://github.com/Kingsley-amg)
