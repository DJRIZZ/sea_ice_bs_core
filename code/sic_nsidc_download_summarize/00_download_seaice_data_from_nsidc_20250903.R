# 00_download_seaice_data_from_nsidc_20250902.R
# script to login to the National Snow and Ice Data Center and download daily sea ice concentration data

# data are Bootstrap Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS V004 (version 4 released May 2024).
# data URL: https://n5eil01u.ecs.nsidc.org/PM/NSIDC-0079.004/
# data are available online and are organized by day, with a folder for each day of data. 
# Each daily folder has data for northern and southern hemispheres as indicated by the file name. 
# An example filename is "NSIDC0079_SEAICE_PS_N25km_19790731_v4.0.nc" which includes data for 31 July 1979 from the northern hemisphere as indicated by the "N25km".

# got packages?
#install.packages(c("httr", "glue", "fs"))
#library(httr) # did not work with NSIDC cookie requirements during the download, curl did work
library(fs) # directory operations
library(glue) # file name and URL creation

# NSIDC login parameters are a _netrc file 
start_date <- as.POSIXct("1992-11-01", format = "%Y-%m-%d") # start of winter 1992-1993, earliest banding data. Winter is defined as 01 Nov year t to 01 May year t+1
end_date <- as.POSIXct("2022-04-30", format = "%Y-%m-%d") # most recently available data  
save_dir <- "data/sourced_data/nsidc_v4/sic_raw_netcdf/raw_nsidc/sic_netcdf_19921130_20241231"  
dir.exists(save_dir)
winter_months <- c(11, 12, 1, 2, 3, 4) # months of interest
all_dates <- seq(from = start_date, to = end_date, by = "1 day") # dates to download

for (date in dates_to_download) {# Loop through target dates (winter months) during range of dates specified

  yyyy <- strftime(date, "%Y") # assign year from date
  mm <- strftime(date, "%m") # assign month from date
  dd <- strftime(date, "%d") # assign day from date
  yyyymmdd <- strftime(date, "%Y%m%d") # format date as it occurs in the file name
  
  filename <- glue("NSIDC0079_SEAICE_PS_N25km_{yyyymmdd}_v4.0.nc") # assign file name for each day of data
  url <- glue("https://n5eil01u.ecs.nsidc.org/PM/NSIDC-0079.004/{yyyy}.{mm}.{dd}/{filename}") # create URL for each day of data
  destfile <- file.path(save_dir, filename) # assign output directory
  #print(url)

  if (!file_exists(destfile)) {
    netrc_path <- "C:/Users/drizzolo/_netrc"  # use forward R's slashes NOT single backslashes
        curl_cmd <- glue(
      "curl --ssl-no-revoke --netrc-file \"{netrc_path}\" -L -c cookies.txt -b cookies.txt -o \"{destfile}\" \"{url}\""
    )
    
    result <- system(curl_cmd)
    
    if (file_exists(destfile) && file_info(destfile)$size > 0) { # if the file doesn't already exist in the directory
      cat(glue("✅ Downloaded: {filename}\n"))
    } else {
      cat(glue("❌ Failed: {filename}\n"))
    }
    
    Sys.sleep(2)  # pause 
  } else {
    cat(glue("⏩ Already exists: {filename}\n"))
  }
}

# check download
# Expected number of files
files_expected <- length(all_dates)

# actual number of files
files_actual <- length(list.files(save_dir))
