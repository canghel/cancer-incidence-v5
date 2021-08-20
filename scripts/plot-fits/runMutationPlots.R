### 2000-2003 #################################################################

print("=== Generating 2000-2003 Plots =======================================")

rm(list=ls());
inputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2000-2003-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
fileOfCleanTable <- "2021-08-20-2000-2003-50-Gamma-with-u.RData"
source("mutationPlots.R")

### 2010-2013 #################################################################

print("=== Generating 2010-2013 Plots =======================================")

rm(list=ls());
inputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2010-2013-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
fileOfCleanTable <- "2021-08-20-2010-2013-50-Gamma-with-u.RData"
source("mutationPlots.R")