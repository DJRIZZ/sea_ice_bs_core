README_NSIDC_bootstrap_v31_data_download

Dave Douglas (USGS) instructions for downloading binary sea ice concentration files relevant to spec eider winter habitat, as used in Petersen and Douglas 2004 and Christie et al. 2018. The original files provided by Dave in May 2020 are in file demo_4fws_20200519.7z (saved in the project lib folder).

Use wget.exe to download files. Save wget.exe file with an empty mycookies.txt file (create in Notepad). Copy of wget.exe is in lib folder for this project (sea_ice_bs_core).

Save wget to C:\Program Files\wget

Create empty text file named "mycookies.txt" in the same directory as wget.exe.

Change the file extension for the file _wget_all_bootstrap_sic_GENERIC_USER.bat (or whatever the filename is for the *.bat file being used to get the NSIDC data) to *.txt and modify this file in Notepad.

Each line in the *.bat file (now *.txt file) downloads one day of sea ice concentration data from the NSIDC. You will need to change the file path to where the files get saved, the Earthdata username and Earthdata password, and the dates for the data you need to download (again, each day gets a line in the *.bat file and each of these lines is executed by running the *.bat file, more on this below), each line logs into Earthdata with the user account that is specified (for me, that's username: drizzolo, password: P1ncheEarthdata!) accesses the bin file for the specified day and downloads it to the specified folder.

Change the various parts of the *.bat file by deleting, adding lines as needed (a line for each day of data) and using the find-replace function in the text editor (Notepad) to change the username, user password, file directory path, and dates as needed.

The *.bat file originally provided and created by Dave Douglas downloads data 1978-2018 (data for 2019 was not available at that time, May 2020). That file was _wget_all_bootstrap_sic_GENERIC_USER.bat and included a line for each date, but to run needs the user and password parts changed. This file is saved in the lib folder of this project.

I (DJR) a modified *.bat file to download just the current year of data when they are released by NSIDC. For example, the "wget_all_bootstrap_sic_2021.bat" file has 365 lines, one for each day of 2021. I created this by modifying Dave Douglas' original file in Notepad.

Saved the *.bin in the same directory as the wget.exe and mycookies.txt files (for me that's C:\Program Files\wget) to make it easier to run (no need to specify file path).

In Windows Command Prompt (run as administrator by right clicking the start icon in the Windows Start menu), set the prompt to the wget folder using DOS "cd" commands, and then, once in the wget folder, entered the *.bat file name to run that *.bat file. "cd.." backs down a directory level, etc.

The *.bat file downloads the *.bin files to the specified folder.

Those files are then processed using the two Program R scripts Dave passed along:

01_convert_binary_bootstrap_to_geotif.R
02_extract_specEider_winterIce_bootstrap_sic_geotif.R

the versions 01b and 02b of these files have the file paths changed to the current project directory.

[work on writing Python script to replace using wget]