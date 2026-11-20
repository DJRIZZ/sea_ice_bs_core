# code to install and run the package mdJSONdictio to create JSON data dictionaries for the SPEI Lead project
# JSON files can be imported into metadata JSON files using mdEditor (rather the monotonous process of building a dictionary in mdEditor)
# one data dictionary created for each tabular data set
# dictionary files created using mdJSONdictio R-package Excel template file available at:
# https://github.com/hdvincelette/mdJSONdictio/blob/master/inst/templates/mdJSONdictio_Dictionary_Template_v2.xlsx
# as file: mdJSONdictio_Dictionary_Template_v2.xlsx

# package can be tricky to install, but this seems to work consistently:
install.packages(
  "https://github.com/hdvincelette/mdJSONdictio/archive/refs/tags/v0.2.4.tar.gz",
  repos = NULL,
  type = "source"
)

# load packages
library(mdJSONdictio) # to create data dictionary JSON files from template
library(readxl)        # to read in Excel data dictionary templates
library(rjson)          # to convert list to JSON

# set up project-based file paths
dict_dir <- "metadata/"   # contains the Excel templates
suffix   <- "_mdJSONdictio.xlsx"             # suffix identifying template files
dict_title_fun <- function(data_name) paste("Dictionary for", data_name)

# get list of template files
xlsx_files <- list.files(
  path       = dict_dir,
  pattern    = paste0(suffix, "$"),
  full.names = TRUE
)

if (length(xlsx_files) == 0) {
  stop("No files matching '", suffix, "' were found in ", dict_dir)
}

cat("Found", length(xlsx_files), "template file(s):\n")
# print list of template files to convert
print(basename(xlsx_files))

# Function to loop through all Excel data dictionary templates in a folder to convert them to JSON files compatiable with import into mdEditor

convert_dictionary <- function(xlsx_path, suffix) {
  
  # get the data file name (strip directory, then strip the suffix)
  file_base <- basename(xlsx_path)
  data_name <- sub(paste0(suffix, "$"), "", file_base)
  
  message("Processing: ", file_base, " -> ", data_name, ".json")
  # error catching
  tryCatch({
    # 1. Import tabular data dictionary as data frame
    input.table <- readxl::read_excel(xlsx_path)
    
    # 2. Translate data frame to list used by mdJSONdictio package
    new.list <- mdJSONdictio::build.mdJSON(
      x     = input.table,
      title = dict_title_fun(data_name)
    )
    
    # 3. Convert to JSON
    new.json <- rjson::toJSON(x = new.list)
    
    # 4. Save JSON file externally, named after the data file
    out_path <- file.path(dirname(xlsx_path), paste0(data_name, "_mdJSONdictio.json"))
    write(x = new.json, file = out_path)
    
    message("  Saved: ", out_path)
    return(invisible(TRUE))
    
  }, error = function(e) {
    warning("  FAILED for ", file_base, ": ", conditionMessage(e))
    return(invisible(FALSE))
  })
}

# apply to folder with Excel template files
results <- sapply(xlsx_files, convert_dictionary, suffix = suffix)

# what worked and what did not
cat("\n--- Summary ---\n")
cat(sum(results), "of", length(results), "file(s) converted successfully.\n")
if (any(!results)) {
  cat("Failed files:\n")
  print(basename(xlsx_files[!results]))
}
