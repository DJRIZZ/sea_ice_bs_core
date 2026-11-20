# Code to examine the correlation between the "ice days" sea ice variable and daily sea ice extent.
# Ice days was calculated as described in Petersen and Douglas (2004): the count of days between 01 November and 30 April
# during which the minumum sea ice concentration value among the 4 25x25 km pixels delineating the spectacled eider
# core wintering area (delineated by Petersen and Douglas 2004) that had >= 95% sea ice cover (based on NSIDC satellite microwave reflectance data).

# Correlation was calculated as Pearson’s product-moment correlation coefficient and associated 95% confidence interval using the cor.test function in Program R. 

# load data
# Sea ice daily extent data citation:
# Fetterer, F., Knowles, K., Meier, W. N., Savoie, M., Windnagel, A. K. & Stafford, T. (2025). 
# Sea Ice Index. (G02135, Version 4). Sea Ice Index Ice Analysis Spreadsheets. 
# Boulder, Colorado USA. National Snow and Ice Data Center. 
# https://doi.org/10.7265/a98x-0f50. Daily sea ice extent, by region: Bering Area km2. Date Accessed 07-28-2026
# link to spreadsheet: https://nsidc.org/sea-ice-today/sea-ice-tools#anchor-sea-ice-analysis-data-spreadsheets

extent <- read.csv("output/summary_ice_extent_daily_bering_sea_1992-2025.csv")

# ice days variable as calculated with code: 
# 03_calc_daily_means_pixels_1to4_20250903.R
# and
# 04_summarize_daily_min_bs3_sic.txt

days <- read.csv("output/sic_beringSea_4pixels/sea_ice_vars_1992_2025.csv")

# wrangle data to rbind
ext_med <- extent[c("year_winter", "median_extent_km2")]
colnames(ext_med) <- c("year_winter", "value")
ext_med$variable <- "ice_extent"
ext_med$value <- ext_med$value/10000 # scale to make values similar range

ice_days_ws <- days[c("year_winter", "ws_count_sic_ge95")]
colnames(ice_days_ws) <- c("year_winter", "value")
ice_days_ws$variable <- "ice_days"

ice_all <- rbind.data.frame(ice_days_ws, ext_med)

# put data in wide format via merge
ice_wide <- merge(extent, days, by = "year_winter")

# look at correlation
correlation <- cor.test(ice_wide$mean_extent_km2, ice_wide$ws_count_sic_ge95)
correlation
