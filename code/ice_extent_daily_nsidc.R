# Program R code to load and reformat NSIDC Bering Sea daily sea ice extent data from wide to long format
# data are from: https://nsidc.org/sea-ice-today/sea-ice-tools#anchor-sea-ice-analysis-data-spreadsheets

# NB, by NSIDC definition: ice extent uses threshold of 15% for each 25x25 km grid cell. If sea ice concentration is < 15%, the entire grid cell is counted as ice covered. 
# if a grid cell falls below sic 15%, it is not counted as ice covered
# sea ice extent > sea ice area

# got packages
library(readxl)
library(ggplot2)

# load data
data <- read_excel("data/sourced_data/bering_sea_summary_nsidc/daily_si_extent_nsidc/N_Sea_Ice_Index_Regional_Daily_Data_G02135_v4.0.xlsx", sheet = 8)
# sheet 8 is "Bering-Extent-km^2"

# convert from list to data frame
ice <- as.data.frame(data)

# fill in merged cells in the month column [1]
for(i in 2:nrow(ice)){ # start at 2nd cell as first cell has name of first month, January
  if(is.na(ice$month[i]) | ice$month[i] == "") { # if a cell is na or blank
    ice$month[i] <- ice$month[i-1] # fill it with the value above it
  }
}

# create numeric months using R constant month.name
ice$month_num <- match(ice$month, month.name)

# specify year columns using pattern matching function grep
year_cols <- grep("^[0-9]{4}$", names(ice)) # start at beginning of string, with any digit 0-9, with 4 occurrences of digits (YYYY), to the end of the string

# convert from wide to long format
ice_long <- data.frame(
  month = rep(ice$month, length(year_cols)), # character month column
  month_num = rep(ice$month_num, length(year_cols)), # numeric month column
  day = rep(ice$day, length(year_cols)), # day of month column
  year = as.integer(as.character(stack(ice[year_cols])$ind)), # year column, where ind is the label column created by the stack function (the other is "values")
  extent_km2 = stack(ice[year_cols])$values # sea ice extent column
)

# subset ice_long to the winter season used in previous spei ice analyses: 01 Nov year t to 30 April year t+1
ice_winter <- subset(ice_long, month_num %in% c(11,12,1,2,3,4))

# create a winter year variable with the value of year at the start of a given winter season, not calendar year
ice_winter$year_winter <- ifelse(
  ice_winter$month_num >= 11,
  ice_winter$year,
  ice_winter$year -1
)

# summarize sea ice extent by year_winter
ice_summary <- aggregate(
  extent_km2 ~ year_winter,
  data = ice_winter,
  FUN = function(x){
    c(
      mean = mean(x, na.rm = TRUE),
      median = median(x, na.rm = TRUE),
      min = min(x, na.rm = TRUE),
      max = max(x, na.rm = TRUE)
    )
  }
)

ice_summary <- cbind(
  year_winter = ice_summary$year_winter,
  as.data.frame(ice_summary$extent_km2)
)

colnames(ice_summary) <- c("year_winter", "mean_extent_km2", "median_extent_km2", "min_extent_km2", "max_extent_km2")

# subset to years of SPEI mark-resight data
ice_spei <- subset(ice_summary, year_winter >= 1992 & year_winter < 2025) # first survival interval is 1992-1993, relevant year_winter is 1992 & most recent year as of June 2026 is winter 2024-2025 (year_winter 2024)

# save it
write.csv(ice_spei, "output/summary_ice_extent_daily_bering_sea_1992-2025.csv", row.names = FALSE)

# plot
p.extent <- ggplot(ice_spei, aes(x = year_winter, y = median_extent_km2)) +
  geom_line() +
  labs(x = "Winter Year",y = expression("Median Sea Ice Extent (km"^2*")")) +
  theme_bw()
p.extent

p.all <- ggplot(ice_spei) +
  geom_line(aes(x = year_winter, y = median_extent_km2)) +
  geom_line(aes(x = year_winter, y = mean_extent_km2)) # +
#geom_line(aes(x = year_winter, y = min_extent_km2)) +
#geom_line(aes(x = year_winter, y = max_extent_km2)) 
p.all

