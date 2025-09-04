# script to create a project managed with the package workflowr to automate GIT version control and project archiving and sharing via GitHub
library(workflowr)

dir.exists("C:/Users/drizzolo/OneDrive - DOI/Desktop/Documents/projects/sea_ice_bs_core")

wflow_start(
  "C:/Users/drizzolo/OneDrive - DOI/Desktop/Documents/projects/sea_ice_bs_core",
  name = NULL,
  git = TRUE,
  existing = TRUE,
  overwrite = FALSE,
  change_wd = TRUE,
  disable_remote = FALSE,
  dry_run = FALSE,
  user.name = "DJRIZZ",
  user.email = "djrizzolo@alaska.edu"
)
