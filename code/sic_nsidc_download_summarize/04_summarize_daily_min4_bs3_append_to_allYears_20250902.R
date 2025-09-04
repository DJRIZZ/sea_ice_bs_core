# 04_summarize_daily_min_bs3_sic_[version date].R

# code by Dan Rizzolo
# last edit 03 Sept 2025
# RStudio root dir: sea_ice_bs_core/

# This code creates Bering Sea sea ice concentration (sic) summary variables for the spec eider "core" area (Petersen and Douglas 2004)

# Input data set: 1979_202[#]_winterSpecEdier_SICbootstrapV31_16pixels.csv", created with file: "02_extract_specEider_winterice_bootstrap_sic_geotif_[date].R"
# Output data set: sea_ice_vars_1995_2024.csv

# This code (as indexed in RStudio):
# 1. Change sic from proportion to percent 
# 2. Selects the 4 core pixels of the 16 pixels in the original dataset
# 3. Aggregate the minimum pixel sic value across the 4 core pixels for each day
# 4. Some data wrangling 
# Calculate:
# 5. ws_hi: count high (>= 95%) sic days for WINTER+SPRING (01 Nov - 30 Apr) 
# 6. winter_hi: count high sic days for WINTER (01 Nov - 31 March)
# 7. spring_hi: count high sic days for SPRING (01-30 Apr)
# 8. ws_lo: count low (< 15%) sic days for WINTER+SPRING
# 9. winter_lo: count low sic days for WINTER
# 10. spring_lo: count low sic days for SPRING
# 11. ws_index: heavy sic index (Flint et a. 2016, Christie et al. 2018) for WINTER+SPRING
# 12. winter_index: heavy sic index for WINTER
# 13. spring_index: heavy sic index for spring
# 14. Compile variables into data frame and save
# 15. Save compiled sic variables as csv: "output/sic_beringSea_4pixels/sea_ice_vars_1995_2024.csv"

# got packages
library(ggplot2) # plot data

# Load data: each record is a daily value of sic, as a proportion, from a given pixel (pixels 1 through 16) delineated by Petersen and Douglas 2004
all.ice <- read.csv("output/sic_beringSea_16pixels/nsidc_sic_summary_v4/sic_bootstrapv4_16pixels_01Nov-30Apr_1992-2024.csv", header=T)

# 1. Change sic from proportion to percent ####
all.ice$bs_sic <- all.ice$bs_sic_prop*100 # version 4 sic are proportions, previous versions sic was permil
str(all.ice)
all.ice$sicDate <- as.Date(as.character(all.ice$sicDate), format = "%Y%m%d") # format as date
hist(all.ice$bs_sic)

# 2. Select 4 core pixels ####
# subset to the pixels in the core area (pixels 1 to 4, as per "specEider_winter_pixel_sample_map.png", see supplementary data from Christie et al. (2018)
core_data <- subset(all.ice, pixel < 5)
table(core_data$pixel)
hist(core_data$bs_sic)

# 3. Aggregate the minimum pixel sic value across the 4 core pixels for each day #####
daily_min_sic_core <- aggregate(core_data$bs_sic ~ core_data$sicDate, FUN = min) # find the min sic value of the 4 pixel values for each day
colnames(daily_min_sic_core) <- c("date", "sic_min4")
head(daily_min_sic_core)
hist(daily_min_sic_core$sic_min4)

# 4. Data wrangling steps ####
daily_min_sic_core$month <- as.numeric(format(daily_min_sic_core$date, "%m")) # assign column for month of year as numeric
table(daily_min_sic_core$month)
daily_min_sic_core$year_cal <- as.numeric(format(daily_min_sic_core$date, "%Y")) # assign calendar year
daily_min_sic_core$year_winter <- ifelse(daily_min_sic_core$month > 10,daily_min_sic_core$year,daily_min_sic_core$year-1) # assign winter year is the year at the start of the winter
table (daily_min_sic_core$year_winter)
# remove years with incomplete winter data: 1978 (start year, incomplete; data were every-other-day 1978-part way through 1987, and likely most recent year)
daily_min_sic_core <- subset(daily_min_sic_core, year_winter != 1978 & year_winter != 2024) # complete 2024 data not currently available, on data through 31 Dec 2024
table (daily_min_sic_core$year_winter)

# Create indicator variable ("hi_ice") for days with min sic >= 95% and summarize count of days >= 95% by year ####
# analyses by Flint et al. (2016) and Petersen and Douglas (2004) used >=95%
# Christie et al. (2018) used > 95%
# this code uses >= 95%
daily_min_sic_core$hi_ice <- ifelse(daily_min_sic_core$sic_min4 >= 95,1,0)
hist(daily_min_sic_core$hi_ice)

# create indicator variable (lo_ice) for days with min sic < 15% (Christie et al. 2018; Fig. 4)
daily_min_sic_core$lo_ice <- ifelse(daily_min_sic_core$sic_min4 < 15, 1, 0)
hist(daily_min_sic_core$lo_ice)
table(daily_min_sic_core$lo_ice)

# 5. Count high (>= 95%) sic days for WINTER+SPRING (01 Nov - 30 Apr): ws_hi ####
# Seasons as defined previously: Petersen & Douglas winter=Dec-Mar, spring=April; Flint et al. 2016 & Christie et al. 2018: winter = 01 Nov-30 Apr
# Here, I use these time frames of interest:
# Winter-Spring: 01 Nov - 30 Apr (although typically no ice in Nov, except 1983, 1987, 1999)
# Winter: 01 Nov-30 Mar
# Spring: 01-30 April

# count total days with >= 95% ice cover for each year_winter
ws_hi <- aggregate(daily_min_sic_core$hi_ice ~ daily_min_sic_core$year_winter, FUN = sum)
colnames(ws_hi) <- c("year_winter", "ws_count_sic_ge95")
hist(ws_hi$ws_count_sic_ge95)
# plot ws_count_sic_ge95
p.ws_hi <- ggplot(ws_hi, aes(x=year_winter, y=ws_count_sic_ge95))+
  geom_line() +
  labs(y = "Days of High (>=95%) Sea Ice Cover", x = "Year") +
  theme_bw()
p.ws_hi
ggsave("output/figs/plot_count_days_ge95pct_sic_1992-2023.png", width = 6, height = 3, units = "in")

# 6. Count high sic days for WINTER (01 Nov - 31 March): winter_hi ####
summary(daily_min_sic_core)
winter_sic_core <- subset(daily_min_sic_core, month != 4 & month != 5 ) # subset data winter (winter: 01 Nov-31 March)
table(winter_sic_core$month) # winter_sic_core should only include these 5 months: Nov, Dec, Jan, Feb, March

# count total days with >= 95% ice cover for each year_winter
winter_hi <- aggregate(winter_sic_core$hi_ice ~ winter_sic_core$year_winter, FUN = sum)
colnames(winter_hi) <- c("year_winter", "winter_count_sic_ge95")
hist(winter_hi$winter_count_sic_ge95)
# plot winter_count_sic_ge95
p.winter_hi <- ggplot(winter_hi, aes(x=year_winter, y=winter_count_sic_ge95))+
  geom_line()
p.winter_hi

# 7. Count high sic days for SPRING (01-30 Apr): spring_hi ####

# subset data spring
summary(daily_min_sic_core)
spring_sic_core <- subset(daily_min_sic_core, month == 4 ) # remove data other than Apr
table(spring_sic_core$month) # spring_sic should only incoude April

# count total days with >= 95% ice cover for each year_winter
spring_hi <- aggregate(spring_sic_core$hi_ice ~ spring_sic_core$year_winter, FUN = sum)
colnames(spring_hi) <- c("year_winter", "spring_count_sic_ge95")
hist(spring_hi$spring_count_sic_ge95)
summary(spring_hi)
# plot spring_count_sic_ge95
p.spring_hi <- ggplot(spring_hi, aes(x=year_winter, y=spring_count_sic_ge95))+
  geom_line()
p.spring_hi

# 8. Count low ( < 15%) sic days for WINTER+SPRING: ws_lo ####

# count total WINTER-SPRING days with < 15% ice cover for each year_winter
ws_lo <- aggregate(daily_min_sic_core$lo_ice ~ daily_min_sic_core$year_winter, FUN = sum)
colnames(ws_lo) <- c("year_winter", "ws_count_sic_le15")
hist(ws_lo$ws_count_sic_le15)
# plot ws_count_sic_le15
p.ws_lo <- ggplot(ws_lo, aes(x=year_winter, y=ws_count_sic_le15))+
  geom_line()
p.ws_lo

# 9. Count low sic days for WINTER: winter_lo ####

# count total WINTER days with < 15% ice cover for each year_winter
winter_lo <- aggregate(winter_sic_core$lo_ice ~ winter_sic_core$year_winter, FUN = sum)
colnames(winter_lo) <- c("year_winter", "winter_count_sic_le15")
hist(winter_lo$winter_count_sic_le15)
# plot winter_count_sic_le15
p.winter_lo <- ggplot(winter_lo, aes(x=year_winter, y=winter_count_sic_le15))+
  geom_line()
p.winter_lo

# 10. Count low sic days for SPRING: spring_lo ####

# count total SPRING days with < 15% ice cover for each year_winter
spring_lo <- aggregate(spring_sic_core$lo_ice~spring_sic_core$year_winter, FUN = sum)
colnames(spring_lo) <- c("year_winter", "spring_count_sic_le15")
hist(spring_lo$spring_count_sic_le15)
summary(spring_lo)
# plot spring_count_sic_le15
p.spring_lo <- ggplot(spring_lo, aes(x=year_winter, y=spring_count_sic_le15))+
  geom_line()
p.spring_lo

# 11. Calc heavy sic index (Flint et a. 2016, Christie et al. 2018) for WINTER+SPRING: ws_index ####
# heavy sic index: runs of days >= 95% sic, including runs separated by only 1 day of <= 95% sic
# apply sic index calcs by year: 

year <- seq(1992,2023,1) # create data frame with sequence of years to feed into the function, "year" here is winter year (year in Nov)
year.file <- data.frame(year) # convert to data frame

# function to calculate high ice index for each year of data
# NB CHANGE function to include input data set as variable so the function is repeated for each season
heavy.ice <- function(YR){
  
  # subset year during which to summarize heavy ice
  year.one <- subset(daily_min_sic_core, year_winter == YR)
  #print(YR)
  subice <- year.one$sic_min4 # minimum sic value across the 4 pixels for each day
  #table(ice$month) # ice data are from Nov, Dec, Jan, Feb, Mar, and Apr
  
  # indicator for days >= 95% sic
  hiIce <- ifelse(subice >= 95,1,0)
  
  # rle (run length encoding) function to summarize runs in ice indicator variable
  temp.data <- rle(hiIce) # NB rle function output is 2 lists: "values" with value (in this case, 1 or 0) in the run, and "length" with length of the run
  
  # convert zeros in run values with a 1 on each side of them to 1 to include one-day breaks in the run, as per Flint et al. 2016
  temp.data$values[temp.data$values == 0 & temp.data$lengths == 1] <- 1 # if a run of zeros has a length of 1, change it from zero to 1
  
  # convert this modified run length data set back to a data set of runs, but with single zeros within runs of 1 converted to 1's
  y <- inverse.rle(temp.data) 
  
  # re-apply rle function to summarize new runs that were modified to include breaks of 1 zero
  final.runs <- rle(y)
  
  high.ice <- data.frame(unclass(final.runs)) # convert rle output to data frame with 2 columns (values, lengths)
  high.ice <- subset(high.ice, values == 1) # select only runs of 1's (remove runs of 0, where 0 = days < 95% ice cover)
  high.ice <- subset(high.ice, lengths > 1) # select runs of 1's longer than 1 day
  sub.I <- high.ice$lengths*log(high.ice$lengths) # calculate subcomponent of the ice index, where I = sum(D*ln(D)), where D = run of 1's as defined in Flint et al. 2016
  
  I <- sum(sub.I) # sum the subcomponents of I to get I for the year
  #print(I)
  
}

# call function for each year with lapply
ws.out.ice <- lapply(year.file$year,heavy.ice)
# unlist
ws_index <- unlist(ws.out.ice)
# bind with year
ws_index <- cbind(year.file, ws_index)
# plot ws_index
ggplot(ws_index, aes(year, ws_index))+
  geom_line()

# 12. Calc heavy sic index for WINTER: winter_index ####
# function to calcuate high ice index for each year of data
heavy.ice <- function(YR){
  
  # subset year during which to summarize heavy ice
  year.one <- subset(winter_sic_core, year_winter==YR)
  #print(YR)
  subice <- year.one$sic_min4 # sensor data on ice concentration
  #table(ice$month) #ice data are from Nov, Dec, Jan, Feb, Mar
  
  # indicator for days >= 95%
  hiIce <- ifelse(subice >= 95,1,0)
  
  # rle function to summarize runs in ice indicator variable
  temp.data <- rle(hiIce) # NB rle function output is 2 lists: "values" with value (in this case, 1 or 0) in the run, and "length" with length of the run
  
  # convert zeros with a 1 on each side to 1 to include one-day breaks in the run, as per Flint et al. 2016
  temp.data$values[temp.data$values==0 & temp.data$lengths==1] <- 1
  
  # convert this modified run length data set back to a data set of runs, but with single zeros within runs of 1 converted to 1's
  y <- inverse.rle(temp.data)
  
  # re-apply rle function to summarize new runs that were modified to include breaks of 1 zero
  final.runs <- rle(y)
  
  high.ice <- data.frame(unclass(final.runs)) # convert rle output to dataframe with 2 columns (values, lengths)
  high.ice <- subset(high.ice, values==1) # select only runs of 1's (remove runs of 0, where 0=days < 95% ice cover)
  high.ice <- subset(high.ice, lengths > 1) # select runs of 1's longer than 1 day
  sub.I <- high.ice$lengths*log(high.ice$lengths) # calculate subcomponent of the ice index, where I=sum(D*ln(D)), where D=run of 1's as defined in Flint et al. 2016
  
  I <- sum(sub.I) # sum the subcomponents of I to get I for the year
  #print(I)
  
}

# call function for each year with lapply
winter.out.ice <- lapply(year.file$year,heavy.ice)
# unlist
winter_index <- unlist(winter.out.ice)
# bind with year
winter_index <- cbind(year.file, winter_index)
# plot winter_index
ggplot(winter_index, aes(year, winter_index))+
  geom_line()

# 13. Calc heavy sic index for spring: spring_index #####
heavy.ice <- function(YR){
  
  # subset year during which to summarize heavy ice
  year.one <- subset(spring_sic_core, year_winter==YR)
  #print(YR)
  subice <- year.one$sic_min4 # sensor data on ice concentration
  #table(ice$month) #ice data are from Apr
  
  # indicator for days >= 95%
  hiIce <- ifelse(subice >= 95,1,0)
  
  # rle function to summarize runs in ice indicator variable
  temp.data<-rle(hiIce) # NB rle function output is 2 lists: "values" with value (in this case, 1 or 0) in the run, and "length" with length of the run
  
  # convert zeros with a 1 on each side to 1 to include one-day breaks in the run, as per Flint et al. 2016
  temp.data$values[temp.data$values==0 & temp.data$lengths==1] <- 1
  
  # convert this modified run length data set back to a data set of runs, but with single zeros within runs of 1 converted to 1's
  y <- inverse.rle(temp.data)
  
  # re-apply rle function to summarize new runs that were modified to include breaks of 1 zero
  final.runs <- rle(y)
  
  high.ice <- data.frame(unclass(final.runs)) # convert rle output to data frame with 2 columns (values, lengths)
  high.ice <- subset(high.ice, values==1) # select only runs of 1's (remove runs of 0, where 0=days < 95% ice cover)
  high.ice <- subset(high.ice, lengths > 1) # select runs of 1's longer than 1 day
  sub.I <- high.ice$lengths*log(high.ice$lengths) # calculate subcomponent of the ice index, where I=sum(D*ln(D)), where D=run of 1's as defined in Flint et al. 2016
  
  I <- sum(sub.I) # sum the subcomponents of I to get I for the year
  #print(I)
  
}

# call function for each year with lapply
spring.out.ice <- lapply(year.file$year,heavy.ice)
# unlist
spring_index <- unlist(spring.out.ice)
# bind with year
spring_index <- cbind(year.file, spring_index)
# plot spring_index
ggplot(spring_index, aes(year, spring_index))+
  geom_line()

# 14. Compile variables into data frame and save ####
sea_ice_vars_1995_2024<-cbind(ws_hi,
                              winter_hi[2],
                              spring_hi[2],
                              ws_lo[2],
                              winter_lo[2],
                              spring_lo[2],
                              ws_index[2],
                              winter_index[2],
                              spring_index[2])

# 15. Save compiled sic variables as csv ####
write.csv(sea_ice_vars_1995_2024, "output/sic_beringSea_4pixels/sea_ice_vars_1995_2024.csv", row.names = FALSE)
