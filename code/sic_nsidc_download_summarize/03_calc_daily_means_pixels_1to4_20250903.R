# 03_calc_daily_means_pixels_1to4_[version date].R

# Code to calculate mean daily sea ice concentration (sic) values from 4 pixels in the Petersen and Douglas 2004 "core" SPEI wintering area

# Input is "sic_bootstrapv4_16pixels_01Nov-30Apr_1992-[most recent year].csv" with daily sic values from each of 16 pixels overlapping the area of use
# delineated by Petersen and Douglas 2004; file created by R script "02_extract_specEider_winterIce_bootstrap_sic_geotif_[version date].R"

# Output: (1) daily mean sic across the 4 core pixels: sic_4pixels_daily_means_[versiondate].csv, (2) annual means across the 4 core pixels: "sic_4pixels_annual_means_20250903.csv"

# code by Dan Rizzolo
# last edit 03 Sept 2025

# Run as RStudio project

# got packages?
library (ggplot2) # plots
library(lubridate) # dates
library(tidyverse) # kitchen sinks

# input data: daily sea ice concentration in 16 pixels, pixels 1 to 4 are SPEI "core" winter area (Petersen and Douglas 2004)
# file created with "02_extract_specEider_winterice_bootstrap_sic_geotif.R"
all.ice<-read.csv("output/sic_beringSea_16pixels/nsidc_sic_summary_v4/sic_bootstrapv4_16pixels_01Nov-30Apr_1992-2024.csv", header=T)
str(all.ice)

# format date
all.ice$date<-as.Date(as.character(all.ice$sicDate),"%Y%m%d")

# create year variable
all.ice$year<-format(all.ice$date, "%Y")
table(all.ice$year)

# subset data that includes data from 16 pixels to 4 core pixels Petersen and Douglas call the "core" area, number 1 to 4
core.ice<-subset(all.ice, pixel < 5)

# convert ice coverage to percent
core.ice$bs_sic_pct <- core.ice$bs_sic_prop*100
hist(core.ice$bs_sic_pct)

# get daily mean across the 4 pixels
mean.daily.sic <- aggregate(core.ice$bs_sic_pct ~ as.factor(core.ice$sicDate), FUN=mean)
colnames(mean.daily.sic) <- c("sicDate", "mean.ice.pct")
str(mean.daily.sic)
hist(mean.daily.sic$mean.ice.pct)
mean.daily.sic$date <- as.Date(as.character(mean.daily.sic$sicDate), format = "%Y%m%d") # create a formatted date column

# subset to winter months: Nov through April
winter.ice <- subset(mean.daily.sic, 
                     format(date, "%m") >= 11 | 
                     format(date, "%m") <= 4)
table(format(winter.ice$date, "%m"))
      
# calculate the long-term mean of daily sea ice concentration in each pixel over all years for each day
winter.ice$month_day <- format(winter.ice$date, "%m-%d")
daily.mean.ice <- aggregate(winter.ice$mean.ice.pct ~ winter.ice$month_day, FUN=mean, na.rm = TRUE)
colnames(daily.mean.ice)<-c("month_day", "pct.ice")
str(daily.mean.ice)

# calculate mean sea ice in the 4 pixel area by year
core.ice$year <- format(core.ice$date, "%Y")
daily_means <- aggregate(bs_sic_pct ~ date, data = core.ice, FUN = "mean", na.rm = TRUE)
daily_means$year <- format(daily_means$date, "%Y")
annual_means <- aggregate(bs_sic_pct ~ year, data = daily_means, FUN = mean, na.rm = TRUE)

# save output
write.csv(daily_means, "output/sic_beringSea_4pixels/sic_4pixels_daily_means_20250903.csv", row.names = FALSE)
write.csv(annual_means, "output/sic_beringSea_4pixels/sic_4pixels_annual_means_20250903.csv", row.names = FALSE)
