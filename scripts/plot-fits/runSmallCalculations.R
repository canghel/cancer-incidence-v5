
### 2000-2003 #################################################################

# print("=== Computing 2000-2003 Small Calculations ===========================")

rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2000-2003-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
fileOfCleanTable <- "2021-08-20-2000-2003-50-Gamma-with-u.RData"
source("smallCalculationsBK.R")
source("smallCalculationsProb.R")
source("smallCalculationsPairedComparison.R")

# ### 2010-2013 #################################################################

print("=== Computing 2010-2013 Small Calculations ===========================")

rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2010-2013-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
fileOfCleanTable <- "2021-08-20-2010-2013-50-Gamma-with-u.RData"
source("smallCalculationsBK.R")
source("smallCalculationsProb.R")
source("smallCalculationsPairedComparison.R")
