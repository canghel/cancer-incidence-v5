# run all the fits

### 2010-2013 #################################################################

# # Pompei-Wilson fit -----------------------------------------------------------
# rm(list=ls());
# fileToLoad <- '2019-06-17-2010-2013-counts-and-errs.RData'
# load(file.path("../../outputs/seer/count-data/", fileToLoad))
# source("../util/seerInfo.R")
# outputPath <- "../../outputs/seer/fits/fit01-Pompei-Wilson"
# source("fit01PompeiWilson.R");

# # Weighted Pompei-Wilson fit --------------------------------------------------
# rm(list=ls());
# fileToLoadErrs <- '2019-06-17-2010-2013-counts-and-errs.RData'
# fileToLoadInitialFit <- '2019-12-02-2010-2013-Pompei-Wilson.RData'
# load(file.path("../../outputs/seer/count-data/", fileToLoadErrs))
# load(file.path("../../outputs/seer/fits/fit01-Pompei-Wilson", fileToLoadInitialFit))
# source("../util/seerInfo.R")
# outputPath <- "../../outputs/seer/fits/fit02-Weighted"
# source("fit02Weighted.R");

# # Harding fit -----------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2010-2013-counts-and-errs.RData'
load(file.path("../../outputs/seer/count-data/", fileToLoadErrs))
# # put output path right before calling script, as another outputPath variable
# # is in one of the loaded files
source("../util/seerInfo.R")
outputPath <- "../../outputs/seer/fits/fit03-Harding"
source("fit03Harding.R");

# Gamma fit -------------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2010-2013-counts-and-errs.RData'
load(file.path("../../outputs/seer/count-data/", fileToLoadErrs))
source("../util/seerInfo.R")
outputPath <- "../../outputs/seer/fits/fit04-Gamma"
source("fit04Gamma.R");

### 2000-2003 #################################################################

# # Pompei-Wilson fit -----------------------------------------------------------
# rm(list=ls());
# fileToLoad <- '2019-06-17-2000-2003-counts-and-errs.RData'
# load(file.path("../../outputs/seer/count-data/", fileToLoad))
# source("../seerInfo.R")
# outputPath <- "../../outputs/seer/fits/fit01-Pompei-Wilson"
# source("fit01PompeiWilson.R");

# # Weighted Pompei-Wilson fit --------------------------------------------------
# rm(list=ls());
# fileToLoadErrs <- '2019-06-17-2000-2003-counts-and-errs.RData'
# fileToLoadInitialFit <- '2019-12-02-2000-2003-Pompei-Wilson.RData'
# load(file.path("../../outputs/seer/count-data/", fileToLoadErrs))
# load(file.path("../../outputs/seer/fits/fit01-Pompei-Wilson", fileToLoadInitialFit))
# source("../util/seerInfo.R")
# outputPath <- "../../outputs/seer/fits/fit02-Weighted"
# source("fit02Weighted.R");

# # Harding fit -----------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2000-2003-counts-and-errs.RData'
load(file.path("../../outputs/seer/count-data/", fileToLoadErrs))
# # put output path right before calling script, as another outputPath variable
# # is in one of the loaded files
source("../util/seerInfo.R")
outputPath <- "../../outputs/seer/fits/fit03-Harding"
source("fit03Harding.R");

# Gamma fit -------------------------------------------------------------------
rm(list=ls());
fileToLoadErrs <- '2021-08-20-2000-2003-counts-and-errs.RData'
load(file.path("../../outputs/seer/count-data/", fileToLoadErrs))
source("../util/seerInfo.R")
outputPath <- "../../outputs/seer/fits/fit04-Gamma"
source("fit04Gamma.R");