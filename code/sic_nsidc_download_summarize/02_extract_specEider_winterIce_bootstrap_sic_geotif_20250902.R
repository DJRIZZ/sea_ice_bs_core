# 02_extract_specEider_winterice_bootstrap_sic_geotif.R 

# Adapted from code posted by A. Fischbach then modified by G. Durner in 2020, and updated by D. Rizzolo in 2025

# This R code extracts sea ice concentration (sic) data from the 16 pixels (each 25 km x 25 km) in the northern Bering Sea identified 
# in Petersen and Douglas 2005 as spectacled eider winter range (based on satellite transmitter locations from the 1990s, but used as an area
# to index sea ice conditions in the broader area of the Bering Sea used by spectacled eiders in Flint et al. 2016 and Christie et al. 2018)

# Output contains daily values of sic (percent cover, 0 to 100) for each of the 16 pixels for each winter (01 Nov to 30 April) day.
# Script requires coordinates of the 16 spec eider pixels in file: specEider_winter_pixel_samples_xy_geo_SAVE.csv
# Input is a directory of daily geotifs
# Output file is ""sic_bootstrapv4_16pixels_01Nov-30Apr_1992-2024.csv"

# Data are SMMR and SSM/I Passive Microwave SIC from the Bootstrap Algorithm, version 4.0 (released May 2024)
# Data URL: https://n5eil01u.ecs.nsidc.org/PM/NSIDC-0079.004/
# See the following publication:
# Comiso, J. C. (2023). Bootstrap Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS. (NSIDC-0079, Version 4). [Data Set]. 
# Boulder, Colorado USA. NASA National Snow and Ice Data Center Distributed Active Archive Center. 
# https://doi.org/10.5067/X5LG68MH013O. [time series of interest: 01 Nov 1992 to 31 Dec 2024]. Date Accessed 2025-09-02.
# Data set id: NSIDC-0079
# DOI: 10.5067/X5LG68MH013O

# processes 1 winter of data (most recently available)
# and appends that new data to the data set with all winters of SIC data

library(sf) # spatial transform
library(terra) # work with rasters
library(dplyr) # wrangle data frames
library(progress) # create a progress bar to monitor the for loop

# spatial data references used here:
#* EPSG:3411: NSIDC Sea Ice Polar Stereographic North
#* EPSG:4326: WGS 84 Geographic

# make Sea Ice Concentration (SIC) grid cell reference coordinates spatial with st_as_sf from package sf and reproject to same CRS as sea ice data
eider16.geo <- read.csv("library/specEider_winter_pixel_samples_xy_geo_SAVE.csv") # Read CSV into a regular data frame
eider16.sf <- st_as_sf(eider16.geo, coords = c("lon", "lat"), crs = 4326) # Convert to an sf object with WGS84 coordinates (EPSG:4326)
eider16.ps <- st_transform(eider16.sf, crs = 3411) # Reproject to NSIDC Sea Ice Polar Stereographic North (EPSG:3411)

# get a list of the geotif files downloaded from NSIDC
tif.list <- as.list(list.files(path = "data/sourced_data/nsidc_sic_v4/sic_geotif/"))
eider_list <- list() # Initialize list to collect daily data frames

# code applied to all version 4 data from period of spectacled eider mark-resight project: 01 Nov 1992 - 31 Dec 2024 (most recent available data as of Sept 2025)
# subsequently, apply to each newly released year of data

# create progress bar
pb <- progress_bar$new(
  format = "  Converting [:bar] :percent | :current/:total | :filename", # pb layout
  total = length(tif.list), # total files
  clear = FALSE, # keep bar visible until loop finishes
  width = 60 # displayed bar width
)

# loop through directory of geotif files
for (f in tif.list) {
  pb$tick(tokens = list(filename = f)) # progress bar by 1 step each file
  month <- as.numeric(substr(f, 31, 32))  # assign month from file name (example: "NSIDC0079_SEAICE_PS_N25km_20211114_v4.0.tif")
  # Process only Nov–Apr
  if (month >= 11 || month <= 5) {
    # load raster using terra
    filename <- paste0("data/sourced_data/nsidc_sic_v4/sic_geotif/", f) # assign file name with path
    rr <- terra::rast(filename)
    # extract sea ice values at point locations for 16 eider pixels of interest
    values <- terra::extract(rr, vect(eider16.ps))[,2]  # second column is the ice value
    # get coordinates from sf object
    coords <- sf::st_coordinates(eider16.ps)
    colnames(coords) <- c("x", "y") # rename columns upper- to lowercase
    # create data frame
    eider16p <- eider16.ps %>%
      st_drop_geometry() %>% # remove the geometry column of the sf object
      # add column for:
      mutate(bs_sic_prop = values, # sea ice concentration 
             sicDate = substr(f, 27, 34), # extract date from file name, positions 3 to 10
             x = coords[, "x"], # EPSG 3411 x values
             y = coords[, "y"]
             ) %>% # EPSG 3411 y values
      # join the original lat/lon columns from eider16.geo by row index
      dplyr::bind_cols(
        eider16.geo %>% dplyr::select(lon, lat)
      )
    # append to list
    eider_list[[length(eider_list) + 1]] <- eider16p # append daily values
  }
}

# call bind rows to combine all daily data frames into data frame eider16p
eider16p <- dplyr::bind_rows(eider_list)

# output is eider16p, take a look
str(eider16p)
summary(eider16p$bs_sic_prop)

# save reprocessed time series
write.csv(eider16p, "output/sic_beringSea_16pixels/nsidc_sic_summary_v4/sic_bootstrapv4_16pixels_01Nov-30Apr_1992-2024.csv", row.names = FALSE)                   

# *OR*

# save year-specific output
year<- as.numeric(substr(tif.list[1], 27, 30))
write.csv(eider16p, paste("output/sic_beringSea_16pixels/", year, "_sic_bootstrapv4_16pixels_01Nov-30Apr.csv", sep=""), row.names = FALSE)                   

# append it to full data set
# load full data set
all_previous <- read.csv("output/sic_beringSea_16pixels/nsidc_sic_summary_v4/sic_bootstrapv4_16pixels_01Nov-30Apr_1992-2024.csv")
# rbind most recent data to full data set
bind <- rbind.data.frame(all_previous, eider16p)

# check and remove duplicate records
#any(duplicated(bind))
#bind[duplicated(bind), ]
#df_unique <- bind[!duplicated(bind), ]
#bind <- df_unique

# save it
write.csv(bind, paste("output/sic_beringSea_16pixels/nsidc_sic_summary_v4/sic_bootstrapv4_16pixels_01Nov-30Apr_1992-", year, ".csv", sep=""), row.names = FALSE)
