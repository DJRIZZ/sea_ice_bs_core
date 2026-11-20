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

# other workflowr commands
# code to run workflowr project as per: https://workflowr.github.io/workflowr/articles/wflow-09-workshop.html

# call package
library(workflowr)

# if needed, setup connect to GitHub/GitLab account, only needs to be run one time
wflow_git_config(user.name = "Daniel Rizzolo", user.email = "djrizzolo@alaska.edu")

# start workflowr project, which creates the default directory structure required by the package
#wflow_start("[Root Directory path]ADD PROJECT NAME = will be name of GitHub repository, too")

# open RMarkdown files ####
wflow_open("analysis/04_summarize_daily_min_bs3_sic.Rmd")

# run/knit RMarkdown file ####
# update ancillary docs
wflow_build("analysis/about.Rmd")
wflow_build("analysis/index.Rmd")
wflow_build("analysis/license.Rmd")

# update summary docs
wflow_build("analysis/04_summarize_daily_min_bs3_sic.Rmd")

# or view previous run of the code with ####
#wflow_view("docs/04_summarize_daily_min_bs3_sic.Rmd")
#wflow_view("docs/about.Rmd")
#wflow_view("docs/index.Rm")
#wflow_view("docs/license.Rmd")

# check status of files to see if they have been committed to Git and pushed to the online repository (status of both will check Rmd and data files) ####
wflow_status()

# commit this version of the code in the RMarkdown file to Git. Workflowr uses the term "publish" for commit ####
# publish/commit files individually to have file-specific commit comments
# pubishing/committing re-runs the Rmd files

wflow_publish("analysis/about.Rmd", "New file access protocol")
wflow_publish("analysis/index.Rmd", "added GitHub repository URL")
wflow_publish("analysis/license.Rmd", "New file access protocol")

wflow_publish("analysis/00_download_seaice_data_from_nsidc.Rmd", "New file access protocol")
wflow_publish("analysis/01_convert_daily_netcdf_bootstrap_to_geotif.Rmd", "commit prior to RDR submission")
wflow_publish("analysis/02_extract_specEider_winterIce_bootstrap_sic_geotif.Rmd", "commit prior to RDR submission")
wflow_publish("analysis/03_summarize_daily_min_bs3_sic.Rmd", "commit prior to RDR submission")


wflow_publish("analysis/04_summarize_daily_min_bs3_sic.Rmd", "Updated with sea ice data from Jan-Apr 2026")

# push files to GitHub, including html project file that can be viewed online, Note: follow prompts in R Console window ####

# check connection to GitHub repository to be sure it is correct ####

wflow_use_github("DJRIZZ")

# test run of push ####
wflow_git_push(dry_run = TRUE)
# results in console message"
# Pushing to the branch "main" of the remote repository "origin"
# Using the HTTPS protocol
# The following Git command would be run:
# $ git push origin main

# if it looks good, run it for real ####
wflow_git_push()

# Results in Error Message:
# Error: Push failed for unknown reason.

# The error message from git2r::push() was:

# Error in 'git2r_push': too many redirects or authentication replays

# These sorts of errors are difficult to troubleshoot. You can search for similar errors on the git2r GitHub repository for
# advice on how to fix it.

# Alternatively, if you have Git installed on your machine, the easiest solution is to instead run `git push` in the
# terminal. This is equivalent to wflow_git_push(). Specifically, copy-paste the following in the terminal:

#  git push -u origin main

# ME: if it fails:
#-use Git CMD window
#-set prompt to project root directory using:
#- 'D:'
#- 'cd Dropbox\drizzolo_work\USFWS\drizzolo\Documents\projects\spei_sat_telem\workflowr_projects\spei_ptt_rt_summaries\[folder you want to push]'
#-run: "git push -u origin"

# Resulting Git message is:
# Enumerating objects: 163, done.
# Counting objects: 100% (163/163), done.
# Delta compression using up to 20 threads
# Compressing objects: 100% (99/99), done.
# Writing objects: 100% (100/100), 435.20 KiB | 20.72 MiB/s, done.
# Total 100 (delta 37), reused 0 (delta 0), pack-reused 0
# remote: Resolving deltas: 100% (37/37), completed with 10 local objects.
# To https://github.com/DJRIZZ/spei_ptt_rt_summaries.git
# 2d21755..ed93a6e  main -> main
# branch 'main' set up to track 'origin/main'.

# # NB if you push from the main directory (spei_ptt_rt_summaries), then all files in subdirectories will be pushed, included sourced code to login to Movebank (don't do this!)
#
