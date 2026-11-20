readme_updated_sea_ice_nsidc_download_info_20260407

The URL for downloading data https://n5eil01u.ecs.nsidc.org/PM/NSIDC-0079.004/  is no longer available as of 2026.

Instead:

Use Earthdata Search in a browser: https://search.earthdata.nasa.gov/
Log in manually with your Earthdata credentials.
Search for: Bootstrap Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS V004
Filter by date range (e.g., 01 Nov 2024 – 30 Apr 2025).
Filter Granule ID to get only northern hemisphere with: *N25km*
Select Download Now and then use the Earthdata Download API to download the selected files

Filename syntax is: NSIDC0079_SEAICE_PS_N25km_[yyyymmdd]_v4.0.nc, e.g., NSIDC0079_SEAICE_PS_N25km_20241116_v4.0.nc
Each file is 68 - 69 kb in size