# this code merges a single winter-year (01 Nov year x to 30 Apr year x+1) of sea ice concentration from 16 pixels identified by Petersen and Douglas 2004 with the full time series
# inputs are:
#     - sic_bootstrapv4_16pixels_01Nov-30Apr_1992-202[#].csv , the time series of data
#     - sic_bootstrapv4_16pixels_01Nov-30Apr_202[x]-202[x+1].csv , the most recent year of data
# output is: sic_bootstrapv4_16pixels_01Nov-30Apr_1992-202[x+1].csv

# load data
ice_ts <- read.csv("output/sic_beringSea_16pixels/nsidc_sic_summary_v4/sic_bootstrapv4_16pixels_01Nov-30Apr_1992-2024.csv")
ice_now <- read.csv("output/sic_beringSea_16pixels/nsidc_sic_summary_v4/sic_bootstrapv4_16pixels_01Nov-30Apr_2024-2025.csv")

# rbind to get output
ice_ts_update <- rbind.data.frame(ice_ts, ice_now)

# save output as csv
write.csv(ice_ts_update, "output/sic_beringSea_16pixels/nsidc_sic_summary_v4/sic_bootstrapv4_16pixels_01Nov-30Apr_1992-2025.csv")
