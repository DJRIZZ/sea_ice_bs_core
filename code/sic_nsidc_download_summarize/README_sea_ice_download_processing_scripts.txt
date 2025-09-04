README_sea_ice_download_processing_scripts.txt

# Number prefix in script file names is the order they need to be run (download, convert, summarize).
# All scripts are for Program R,
# and are based on scripts and advice provided by Anthony Fischbach, George Durner, and Dave Douglas of the USGS Alaska Science Center.

00_download_seaice_data_from_nsidc_[version date].R
Script to login to the National Snow and Ice Data Center (NSIDC) and download daily sea ice concentration (SIC) data.
Data are Bootstrap Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS V004 (version 4 released May 2024).
Data URL: https://n5eil01u.ecs.nsidc.org/PM/NSIDC-0079.004/
Data are available online and are organized by day, with a folder for each day of data. Data for year x are *typically* available in Jan. of year x+1.
On the NSIDC site, each daily folder has data for northern and southern hemispheres as indicated by the file name. 
An example filename is "NSIDC0079_SEAICE_PS_N25km_19790731_v4.0.nc" which includes data for 31 July 1979 from the northern hemisphere as indicated by the "N25km".

01_convert_binary_bootstrap_to_geotif_[version date].R 
Script converts *.nc files downloaded from NSIDC to geotif files.
Output geotifs are saved in "/data/sourced_data/nsidc_sic_v4/sic_geotif" directory under root directory of the RStudio project "/sea_ice_bs_core"

02_extract_specEider_winterIce_bootstrap_sic_geotif_[version date].R
This R code extracts sea ice concentration (sic) data from the 16 pixels (each 25 km x 25 km) in the northern Bering Sea identified 
in Petersen and Douglas 2005 as spectacled eider winter range (based on satellite transmitter locations from the 1990s, but used as an area
to index sea ice conditions in the broader area of the Bering Sea used by spectacled eiders in Flint et al. 2016 and Christie et al. 2018).
Output contains daily values of sic (percent cover, 0 to 100) for each of the 16 pixels for each winter (01 Nov to 30 April) day, 
# in file: "sic_bootstrapv4_16pixels_01Nov-30Apr_1992-2024.csv".
Script requires coordinates of the 16 spec eider pixels in file: "specEider_winter_pixel_samples_xy_geo_SAVE.csv"
Input is a directory of daily geotifs

03_daily_means_pixels_1to4_[version date].R
Calculates daily mean sea ice concentration in the 4 pixels (mean.ice) during winter months
output is figure "ice_cover_pct_core_mean_2018_2019.png"

04_summarize_daily_min_bs3_sic_[version date].R
Code to create and complile Bering Sea sea ice concentration (sic) summary variables for the spec eider "core" area (Petersen and Douglas 2004), including: 
days of ice >=95%, 
days of ice < 15%, 
heavy ice index (Flint et al. 2016) days; 
all summarized each winter-year (1979-[most recently available sea ice year]) for 3 seasons (winter-spring [01 Nov-30 Apr], winter [01 nov-31 Mar], spring (1-30 Apr])