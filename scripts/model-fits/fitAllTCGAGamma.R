# run only Gamma fit

### 2010-2013 #################################################################

print("=== Model-fitting for 2000-2003 =======================================")

# Gamma fit -------------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2010-2013-counts-and-errs.RData'
load(file.path("../../outputs/seer-tcga/count-data", fileToLoadErrs))
source("../util/seerTCGAInfo.R")
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
source("fit04Gamma.R");


### 2000-2003 #################################################################

print("=== Model-fitting for 2000-2003 =======================================")

# # Gamma fit -------------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2000-2003-counts-and-errs.RData'
load(file.path("../../outputs/seer-tcga/count-data", fileToLoadErrs))
source("../util/seerTCGAInfo.R")
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
source("fit04Gamma.R");
