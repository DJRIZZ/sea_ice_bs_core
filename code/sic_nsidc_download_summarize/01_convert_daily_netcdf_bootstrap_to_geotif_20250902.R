# 01_convert_daily_netcdf_bootstrap_to_geotif.R

# script to convert National Snow and Ice Data Center sea ice NetCDF files (*.nc) to geotifs (perviously NSDIC provided data as binary files)

library(ncdf4) # works with Network Common Data Form (NetCDF, file extension *.nc) files
library(terra) # current functionality of deprecated geos package
library(progress) # progress bar package for monitoring for loop through files

# Define input and output directories (run as RStudio project)
input_dir <- "data/sourced_data/nsidc_sic_v4/sic_raw_netcdf/sic_netcdf_19921130_20241231"
dir.exists("data/sourced_data/nsidc_sic_v4/sic_raw_netcdf/sic_netcdf_19921130_20241231")
output_dir <- "data/sourced_data/nsidc_sic_v4/sic_geotif"
dir.exists("data/sourced_data/nsidc_sic_v4/sic_geotif")

# list NetCDF daily files
nc_files <- list.files(path = input_dir, pattern = "\\.nc$", full.names = TRUE)
length(nc_files)
total_files <- length(nc_files) # to use in progress bar

# create progress bar
pb <- progress_bar$new(
  format = "  Converting [:bar] :percent | :current/:total | :filename", # pb layout
  total = total_files, # total files
  clear = FALSE, # keep bar visible until loop finishes
  width = 60 # displayed bar width
)

error_log <- character() # initialize error log for file conversions

for (file in nc_files) { # loop through each daily NetCDF file
  
  base_name <- tools::file_path_sans_ext(basename(file)) # extract base name without extension
  out_file <- file.path(output_dir, paste0(base_name, ".tif")) # build output file name reusing base name with .tif extension
  
  pb$tick(tokens = list(filename = basename(file))) # progress bar by 1 step each file
  
  tryCatch({ # error catching function for the following steps (base R function)
    r <- rast(file)  # load as raster, NB "varname" option not needed
  if (is.na(crs(r))) crs(r) <- "EPSG:3411"  # assign CRS (if not already defined in file)
  r[r > 1000] <- NA  # assign NA to values flagged with NA values (1100, 1200; as per metadata)
  writeRaster(r, out_file, overwrite = TRUE) # write to GeoTIFF, file format set by file name extension *.tif
  }, error = function(e){ # if error occurs
    message(sprintf(" [ERROR] Skipping %s: %s, basename(file)", e$message)) # print this message
    error_log <<- c(error_log, paste(basename(file), ":", e$message)) # append the initialized error log outside loop with '<<-'
  })
}

# get summary of errors, if any
if(length(error_log) > 0) { # if there are errors
  cat("\nThese didn't work:\n") # list files that failed
  cat(paste(error_log, collapse = "\n"))
}

# check that number of input *.nc files matches number of output *.tif files
length(list.files("data/sourced_data/nsidc_sic_v4/sic_raw_netcdf/sic_netcdf_19921130_20241231"))
length(list.files("data/sourced_data/nsidc_sic_v4/sic_geotif"))
