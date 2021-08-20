### PREAMBLE ##################################################################

library(dplyr)
library(tidyr)
library(scales)

library(futile.logger)
flog.threshold(DEBUG)

### LOAD DATA #################################################################

load(file.path(outputPath, fileOfResults));

firstyr <- strsplit(fileOfResults, '-')[[1]][4]
lastyr <- strsplit(fileOfResults, '-')[[1]][5]
ageToStartFit <- as.numeric(strsplit(fileOfResults, '-')[[1]][6])

femalecolor <- "red3" # "#D73027"
malecolor <- "dodgerblue4" #"#4575B4" 
bothcolor <- "black"

load(file.path(outputPath, fileOfCleanTable));


### GET PROBABILITIES #########################################################


allgfits_u$probFit <- (allgfits_u$uu)^allgfits_u$kk/((allgfits_u$bb)^allgfits_u$kk*gamma(allgfits_u$kk))*(1/allgfits_u$kk - 1/(allgfits_u$kk+1))


femaleProbs <- allgfits_u[which(allgfits_u$sex=="female"), which(colnames(allgfits_u) %in% c("cancertype", "probSEER", "probFit"))]
maleProbs <- allgfits_u[which(allgfits_u$sex=="male"), which(colnames(allgfits_u) %in% c("cancertype", "probSEER", "probFit"))]

1 - prod(1-femaleProbs$probSEER)
1 - prod(1-femaleProbs$probFit)
1 - prod(1-maleProbs$probSEER)
1 - prod(1-maleProbs$probFit)

1 - prod(1-femaleProbs[which(!(femaleProbs$cancertype %in% femalecancers)), ]$probSEER)
1 - prod(1-femaleProbs[which(!(femaleProbs$cancertype %in% femalecancers)), ]$probFit)
1 - prod(1-maleProbs[which(!(maleProbs$cancertype %in% malecancers)), ]$probSEER)
1 - prod(1-maleProbs[which(!(maleProbs$cancertype %in% malecancers)), ]$probFit)


### PRINT RESULTS TO SCREEN ###################################################

print(paste("Female, SEER cumulative prob of being diagnosed with at least one cancer:", round((1 - prod(1-femaleProbs$probSEER)),2)))
print(paste("Female, model-fit cumulative prob of being diagnosed with at least one cancer:", round((1 - prod(1-femaleProbs$probFit)),2)))
print(paste("Male, SEER cumulative prob of being diagnosed with at least one cancer:", round((1 - prod(1-maleProbs$probSEER)),2)))
print(paste("Male, SEER cumulative prob of being diagnosed with at least one cancer:", round((1 - prod(1-maleProbs$probFit)),2)))
print("")