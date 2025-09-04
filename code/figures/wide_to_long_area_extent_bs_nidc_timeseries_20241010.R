# this script wrangles NSIDC daily sea ice extent and area data for the Bering Sea
# and gets summary statistics by year
# data source: https://nsidc.org/sea-ice-today/sea-ice-tools#anchor-sea-ice-analysis-data-spreadsheets
# spreadsheet file name: N_Sea_Ice_Index_Regional_Daily_data_G02135_v3.0.xlsx

# data are in wide format, transform to long format with year as a variable rather than a column head

# last data download 20241010

# got packages?
library(readxl)
library(tidyverse)
library(reshape2) # to transform data from wide to long format with melt function
library(ggplot2)

# load spreadsheet for sea ice AREA
area_all <- readxl::read_excel("data/daily_si_area_nsidc/daily_si_area_nsidc_wide_20241010.xlsx")
str(area_all)

# create julian date as sequence of 1 to 366 days
area_all$julian <- seq(1,366,1)

# replace NAs with -9
#area_all[, 3:48][is.na(area_all[,3:48])] <- -9

# transpose from wide to long with r base function reshape with reshape2 function melt
area_all_long <-melt(area_all, id.vars = c("month","day", "julian"), variable.name = "year", value.name = "area_ice")
str(area_all_long)
area_all_long$year <- as.numeric(as.character(area_all_long$year))

# subset for winter-spring months (01 Nov - 30 Apr)
area_winter <- subset(area_all_long, month > 10 | month < 5)

# create winter-year variable to identify winter by its starting year
area_winter$year_winter <- ifelse(area_winter$month > 10, area_winter$year, area_winter$year+1)

# summarize ice area mean by year
ice_area_year <- aggregate(area_winter, area_ice ~ year_winter, FUN = "mean")

p.ice_area_year<-ggplot(ice_area_year, aes(x=year_winter, y=area_ice))+
  geom_line()
p.ice_area_year

# load winter ice days data
ice_days <- read.csv("output/count_days_ge95pct_ice_1979-2022.csv")

# merge ice days with ice area
all_ice <- merge(ice_days, ice_area_year, all.x = TRUE, by = "year_winter")

p.all_ice <- ggplot(all_ice, aes(x = area_ice, y = ws_count_sic_ge95))+
  geom_line()
p.all_ice

ice_cor <- cor(all_ice$area_ice, all_ice$ws_count_sic_ge95)
ice_cor

m_ice <- lm(all_ice$area_ice ~ all_ice$ws_count_sic_ge95)
summary(m_ice)
