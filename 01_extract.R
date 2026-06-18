# =============================================================================
#  01_extract.R  -  Gather malaria + climate data for Ghana (16 regions) and the
#  African context, from open APIs. No keys required.
#  Sources: World Bank, DHS Program, NASA POWER (climate), geoBoundaries.
# =============================================================================
suppressMessages({ library(jsonlite); library(dplyr); library(tidyr); library(readr); library(sf) })
dir.create("data", showWarnings = FALSE)

# ---- World Bank: malaria incidence (Africa context + Ghana trend) -----------
wb <- function(code, countries) {
  url <- sprintf("https://api.worldbank.org/v2/country/%s/indicator/%s?format=json&date=2000:2024&per_page=20000",
                 countries, code)
  d <- fromJSON(url, flatten = TRUE)[[2]]
  tibble(iso3 = d$countryiso3code, country = d$country.value,
         year = as.integer(d$date), value = as.numeric(d$value)) |>
    filter(!is.na(value), nchar(iso3) == 3)
}
meta <- fromJSON("https://api.worldbank.org/v2/country?format=json&per_page=400", flatten = TRUE)[[2]]
north <- c("DZA","EGY","LBY","MAR","TUN","SDN","ESH")
afr <- meta |> transmute(iso3 = id, region = trimws(region.value)) |>
  filter(region == "Sub-Saharan Africa" | iso3 %in% north)
mal <- wb("SH.MLR.INCD.P3", "all") |> semi_join(afr, by = "iso3")
write_csv(mal |> group_by(iso3, country) |> slice_max(year, n = 1, with_ties = FALSE) |> ungroup(),
          "data/africa_malaria_latest.csv")
write_csv(wb("SH.MLR.INCD.P3", "GHA"), "data/ghana_malaria_trend.csv")

# ---- DHS: malaria prevalence (RDT) by region, all survey years --------------
dhs <- fromJSON(paste0("https://api.dhsprogram.com/rest/dhs/data?countryIds=GH",
                       "&indicatorIds=ML_PMAL_C_RDT&breakdown=subnational&f=json&perpage=500"))$Data
write_csv(tibble(survey_year = dhs$SurveyYear, label = dhs$CharacteristicLabel,
                 malaria = as.numeric(dhs$Value)), "data/ghana_malaria_region.csv")

# ---- Ghana region boundaries + centroids -----------------------------------
api <- fromJSON("https://www.geoboundaries.org/api/current/gbOpen/GHA/ADM1/")
download.file(api$gjDownloadURL, "data/ghana_adm1.geojson", quiet = TRUE)
gh <- st_read("data/ghana_adm1.geojson", quiet = TRUE) |> mutate(region = sub(" Region$", "", shapeName))
cen <- gh |> st_centroid() |> mutate(lon = st_coordinates(geometry)[,1],
                                     lat = st_coordinates(geometry)[,2]) |>
  st_drop_geometry() |> select(region, lon, lat)

# ---- NASA POWER: monthly climate at each region centroid (2014-2024) --------
power <- function(lon, lat) {
  url <- sprintf(paste0("https://power.larc.nasa.gov/api/temporal/monthly/point?",
                        "parameters=T2M,RH2M,PRECTOTCORR&community=AG&longitude=%.3f&latitude=%.3f",
                        "&start=2014&end=2024&format=JSON"), lon, lat)
  p <- fromJSON(url)$properties$parameter
  ym <- names(p$T2M)
  tibble(ym = ym, temp = unlist(p$T2M), humidity = unlist(p$RH2M),
         rain_mm_day = unlist(p$PRECTOTCORR)) |>
    filter(substr(ym, 5, 6) != "13")           # drop the annual ('13') summary rows
}
clim <- lapply(seq_len(nrow(cen)), function(i) {
  message("climate: ", cen$region[i])
  power(cen$lon[i], cen$lat[i]) |> mutate(region = cen$region[i])
}) |> bind_rows() |>
  mutate(year = as.integer(substr(ym, 1, 4)), month = as.integer(substr(ym, 5, 6)),
         rain_mm_month = rain_mm_day * 30.4)
write_csv(clim, "data/ghana_climate_monthly.csv")
write_csv(cen, "data/ghana_region_centroids.csv")

cat("\n=== EXTRACT COMPLETE ===\n")
cat("Africa malaria countries:", nrow(read_csv("data/africa_malaria_latest.csv", show_col_types=FALSE)), "\n")
cat("DHS malaria region rows:", nrow(dhs), "| years:", paste(sort(unique(dhs$SurveyYear)), collapse=", "), "\n")
cat("Climate rows:", nrow(clim), "| regions:", clim$region |> unique() |> length(),
    "| months:", min(clim$ym), "-", max(clim$ym), "\n")
