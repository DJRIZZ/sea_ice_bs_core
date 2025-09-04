readme_nsidc_sea_ice_concentration_data

National Snow and Ice Data Center
Bootstrap Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS V004
Version 4 (uses *.nc file format) was released in November 2023 and Version 3 (used *.bin file format) was retired in May 2024.

NSIDC GitHub repository with related code: https://github.com/nsidc/polarstereo-reformat
And: https://github.com/nsidc/polarstereo-reformat

Data URL: https://n5eil01u.ecs.nsidc.org/PM/NSIDC-0079.004/

Data are organized in directories by day in format YYYY.mm.dd/

Within each daily directory are files for northern and southern hemispheres denoted by N25km and S25km in the filename.

An example file name is: NSIDC0079_SEAICE_PS_N25km_19790731_v4.0.nc

R code to automatically download daily *.nc data files over a range of dates is in file: "00_download_seaice_data_from_nsidc.R"

