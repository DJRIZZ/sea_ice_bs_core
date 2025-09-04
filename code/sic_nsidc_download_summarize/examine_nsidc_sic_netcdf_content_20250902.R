# examine_nsidc_sic_netcdf_content_[date]
# This script looks at the content of a National Snow and Ice Data Center (NSIDC) sea ice concentration (SIC) netCDF data file.

library(ncdf4) # works with Network Common Data Form (NetCDF, file extension *.nc) files
library(terra) # current functionality of deprecated geos package

# get specs on an example *.nc file
# Open NetCDF file
nc <- nc_open("data/sourced_data/nsidc_sic_v4/sic_raw_netcdf/sic_netcdf_19921130_20241231/NSIDC0079_SEAICE_PS_N25km_19921101_v4.0.nc")

print(nc) # Summary of all contents
names(nc$var)# List variable names
nc$var$F17_ICECON # Look at details of sea ice concentration 
summary(nc$var$F17_ICECON) # Look at details of sea ice concentration

# Dimensions
names(nc$dim)
nc$dim$time  
nc$dim$x
nc$dim$y 

nc_close(nc) # Close file