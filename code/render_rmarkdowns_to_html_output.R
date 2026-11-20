# code to output html file

build_and_archive <- function(rmd_path, output_dir = "output") {
  wflow_build(rmd_path)
  html_name <- paste0(tools::file_path_sans_ext(basename(rmd_path)), ".html")
  fs::dir_create(output_dir)
  fs::file_copy(file.path("docs", html_name),
                file.path(output_dir, html_name),
                overwrite = TRUE)
}

build_and_archive("analysis/00_download_seaice_data_from_nsidc.Rmd")
build_and_archive("analysis/01_convert_netcdf_to_geotif.Rmd")
build_and_archive("analysis/02_extract_specEider_winterice_bootstrap_sic_geotif.Rmd")
build_and_archive("analysis/03_summarize_bering_sea_sic_vars.Rmd")