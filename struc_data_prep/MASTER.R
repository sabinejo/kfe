#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
# This is the master file that gathers data from the individual variable
# r-scripts and merges them into the GCRI dataset. Each variable to be
# included must have a script placed in the VARIABLES folder, which again
# must have an original dataset in the ORIG_DATA folder. The output of each
# variable script MUST be a dataframe called "data", where the variable
# of interest is in the first column.
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


#§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§#
##               THIS IS THE MASTER WORKING DIRECTORY                     ## 
##   MAKE SURE THIS LEADS TO THE PARENT FOLDER CONTAINING THE PROJECT     ##
setwd("C:/Users/sunanda.garg/OneDrive - Accenture/Fun Projects/kfe/GCRI/data")
#§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§§#

rm(list=ls())

# Store some directories for later use
parent_wd <- getwd()
setwd('R/IDEP_VARIABLES')
idep_wd <- getwd() # store this wd for later use
setwd('../../ORIG_DATA_new')
data_wd <- getwd() # store this wd for later use
setwd(parent_wd)

#### Load required packages ####
# Source this for a script that installs all the packages below:
#source("R/package_installer.R")
library(readr)       # fast csv reader
library(readxl)      # fast xls(x) reader
library(xlsx)        # to write xls(x)
library(foreign)     # for .dta
library(readstata13) # for new .dta
library(tidyr)       # Data reshaping 
library(dplyr)       # Data reshaping
library(plyr)        # Data reshaping
library(reshape)     # Data reshaping
library(matrixStats) # rowMaxs function
library(countrycode) # for ID codes
library(cshapes)     # country neighbours
library(mefa)        #

#### Source scripts that prep data and acquires custom functions ####

# Source a script that preps UN population data (for some reason this didn't work in the loop)
# This takes a while due to the huge dataset involved. Skip if this is not the first time you run.
# 22 warnings about NA introduced will appear. They are a good sign.
#source("R/yb_pop_prep.R")
# Creates "temp_ybb.csv" in the ORIG_DATA folder that will be used by the YBB and POP variable scripts.

# Source scripts that create matrices containing the countries and country years that are to be kept.
source("R/id_mat.R")
source("R/id_mat_long.R")
#source("R/nb_mat.R") # Takes hours. Output is included, so run this only if you want to redefine what constitues a neighbour.
# Load necessary custom functions
source("R/gcridata_functions.R")

load("R/id_mat.Rdata")

### WD change and file list ####
#Set WD to the folder containing independent variable scripts to retrieve list of vars to be processed.
setwd(idep_wd)
variable_list <- list.files()

#### Variable loop ####
# Loop through variables, sourcing and merging each one to one dataset. Takes a few seconds.
for (variable in variable_list) {
  setwd(idep_wd)

  source(variable)  # Source the individual script, retrieving a set named "data"

  if (!exists("ideps")) {
    # Create a dataset in which to combine the variables
    ideps <- as.data.frame(data)
    cat(paste(colnames(ideps)[1],""))
    flush.console()
  }else if (exists("ideps")) {
    # Add the rest of the variables to the set
    ideps <- merge(ideps, data, by = c("ISO3C","YEAR"), all.x = T)
    cat(paste(colnames(ideps)[ncol(ideps)]," "))
    flush.console()
  }
  rm(data)
}

# Independent variables are now assembled. Clean, reset wd.
rm(variable,variable_list)
setwd(parent_wd)

#### Conflict variables ####
setwd('R/CONFLICT_VARIABLES')
# Intensities based on PRIO/UCDP
source("CONFLICT_INTENSITY.R")
# YRS_HVC
source("YEARS_SINCE_CONFLICT.R")
# Y4 intensities
source("CON_LAG.R")
# Neighbouring conflicts
source("CONFLICT_NB.R")

#### Cleaning ####
# Rename two vars to fit with older code scheme
colnames(conflict)[which(colnames(conflict)=="NP_INTENSITY")] <- "Intensity_Y_NP"
colnames(conflict)[which(colnames(conflict)=="SN_INTENSITY")] <- "Intensity_Y_SN"

# Add countrynames
setwd(parent_wd)
id_mat <- subset(id_mat, select = c(GWNO, COUNTRY, YEAR))
conflict <- merge(id_mat, conflict, by=c("GWNO", "YEAR"))

# Drop support variables and variables not used
conflict <- subset(conflict, select = c(ISO3C, YEAR, COUNTRY, YRS_HVC, CON_INT,CON_NB,
                                        Intensity_Y_NP, Intensity_Y_SN, Intensity_Y4_NP,Intensity_Y4_SN))

#### Merge the independents with the conflicts and conflict history ####
gcri.data <- merge(conflict,ideps, by=c("ISO3C", "YEAR"), all.x=T)

# Rename ISO3C for use with older scripts
colnames(gcri.data)[which(colnames(gcri.data)=="ISO3C")] <- "ISO"

rm(list=setdiff(ls(), "gcri.data"))
save.image("gcri.data.Rdata")

