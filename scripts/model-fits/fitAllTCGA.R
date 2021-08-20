# run all the fits

### 2010-2013 #################################################################

print("=== Model-fitting for 2000-2003 =======================================")

# # Pompei-Wilson fit -----------------------------------------------------------
# rm(list=ls());
# fileToLoad <- '2019-06-22-2010-2013-counts-and-errs.RData'
# load(file.path("../../outputs/seer-tcga/count-data", fileToLoad))
# source("../seerTCGAInfo.R");
# outputPath <- "../../outputs/seer-tcga/fits/fit01-Pompei-Wilson"
# source("fit01PompeiWilson.R");

# # Weighted Pompei-Wilson fit --------------------------------------------------
# rm(list=ls());
# fileToLoadErrs <- '2019-06-22-2010-2013-counts-and-errs.RData'
# fileToLoadInitialFit <- '2019-12-02-2010-2013-Pompei-Wilson.RData'
# load(file.path("../../outputs/seer-tcga/count-data/", fileToLoadErrs))
# load(file.path("../../outputs/seer-tcga/fits/fit01-Pompei-Wilson", fileToLoadInitialFit))
# source("../seerTCGAInfo.R")
# outputPath <- "../../outputs/seer-tcga/fits/fit02-Weighted"
# source("fit02Weighted.R");

# Harding fit -----------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2010-2013-counts-and-errs.RData'
load(file.path("../../outputs/seer-tcga/count-data", fileToLoadErrs))
source("../util/seerTCGAInfo.R")
# put output path right before calling script, as another outputPath variable
# is in one of the loaded files
outputPath <- "../../outputs/seer-tcga/fits/fit03-Harding"
source("fit03Harding.R");

# Gamma fit -------------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2010-2013-counts-and-errs.RData'
load(file.path("../../outputs/seer-tcga/count-data", fileToLoadErrs))
source("../util/seerTCGAInfo.R")
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
source("fit04Gamma.R");


### 2000-2003 #################################################################

print("=== Model-fitting for 2000-2003 =======================================")

# # Pompei-Wilson fit -----------------------------------------------------------
# rm(list=ls());
# fileToLoad <- '2019-06-22-2000-2003-counts-and-errs.RData'
# load(file.path("../../outputs/seer-tcga/count-data", fileToLoad))
# source("../seerTCGAInfo.R");
# outputPath <- "../../outputs/seer-tcga/fits/fit01-Pompei-Wilson"
# source("fit01PompeiWilson.R");

# # Weighted Pompei-Wilson fit --------------------------------------------------
# rm(list=ls());
# fileToLoadErrs <- '2019-06-22-2000-2003-counts-and-errs.RData'
# fileToLoadInitialFit <- '2019-12-02-2000-2003-Pompei-Wilson.RData'
# load(file.path("../../outputs/seer-tcga/count-data/", fileToLoadErrs))
# load(file.path("../../outputs/seer-tcga/fits/fit01-Pompei-Wilson", fileToLoadInitialFit))
# source("../seerTCGAInfo.R")
# outputPath <- "../../outputs/seer-tcga/fits/fit02-Weighted"
# source("fit02Weighted.R");

# Harding fit -----------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2000-2003-counts-and-errs.RData'
load(file.path("../../outputs/seer-tcga/count-data", fileToLoadErrs))
source("../util/seerTCGAInfo.R")
# put output path right before calling script, as another outputPath variable
# is in one of the loaded files
outputPath <- "../../outputs/seer-tcga/fits/fit03-Harding"
source("fit03Harding.R");

# Gamma fit -------------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2000-2003-counts-and-errs.RData'
load(file.path("../../outputs/seer-tcga/count-data", fileToLoadErrs))
source("../util/seerTCGAInfo.R")
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
source("fit04Gamma.R");
