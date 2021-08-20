# # plot them all

### 2000-2003 #################################################################

# # Harding fit -----------------------------------------------------------------
rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit03-Harding"
fileOfResults <- "2021-08-20-2000-2003-50-Harding-all.RData"
source("../util/seerTCGAInfo.R")
source("fit03HardingPlot.R");

# Gamma fit -------------------------------------------------------------------
rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2000-2003-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
source("fit04Gamma01_Incidence.R");

rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2000-2003-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
source("fit04Gamma02_UvsK.R");

rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2000-2003-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
fileOfCleanTable <- "2021-08-20-2000-2003-50-Gamma-with-u.RData"
source("fit04Gamma03_AgeK.R")

### 2010-2013 #################################################################

# Harding fit -----------------------------------------------------------------
rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit03-Harding"
fileOfResults <- "2021-08-20-2010-2013-50-Harding-all.RData"
source("../util/seerTCGAInfo.R")
source("fit03HardingPlot.R");

# Gamma fit -------------------------------------------------------------------
rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2010-2013-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
source("fit04Gamma01_Incidence.R");

rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2010-2013-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
source("fit04Gamma02_UvsK.R");

rm(list=ls());
outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"
fileOfResults <- "2021-08-20-2010-2013-50-Gamma-all.RData"
source("../util/seerTCGAInfo.R")
fileOfCleanTable <- "2021-08-20-2010-2013-50-Gamma-with-u.RData"
source("fit04Gamma03_AgeK.R")