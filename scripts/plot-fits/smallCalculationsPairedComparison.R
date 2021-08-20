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

### COLLECT DATA INTO A DATA FRAME ############################################

dfFemale <- filter(allgfits_u, sex=="female")[, c("cancertype","bb", "uu", "kk")]
dfMale <- filter(allgfits_u, sex=="male")[, c("cancertype", "bb", "uu", "kk")]
dfBoth <- filter(allgfits_u, sex=="both")[, c("cancertype", "bb", "uu", "kk")]

dfMF <- merge(dfFemale, dfMale, by="cancertype", suffix=c(".female", ".male"))
bbMF_ttest_paired <- t.test(dfMF$bb.female, dfMF$bb.male, paired=TRUE)
uuMF_ttest_paired <- t.test(dfMF$uu.female, dfMF$uu.male, paired=TRUE)
kkMF_ttest_paired <- t.test(dfMF$kk.female, dfMF$kk.male, paired=TRUE)
# print(paste0("n=", nrow(bbMF)))
# print(bbMF_ttest_paired)

lapply(dfMF[,2:ncol(dfMF)], mean, 2)
lapply(dfMF[,2:ncol(dfMF)], sd, 2)


### COMPARE AGES/RATE ##############################################################

if (firstyr==2010){
	EXCLUDED <- c("COADREAD", "LGG", "READ", "PCPG");
}
if (firstyr==2000){
	EXCLUDED <- c("COADREAD", "LGG", "ACC", "SARC", "PCPG");
}

peaksFemale <- filter(allnice_2Term, sex=="female")[, c("Site","peakrateSEER", "peakrateFit", "peakageSEER", "peakageFit")]
peaksFemale <- peaksFemale[(!(peaksFemale$Site %in% EXCLUDED)),]
peaksMale <- filter(allnice_2Term, sex=="male")[, c("Site","peakrateSEER", "peakrateFit", "peakageSEER", "peakageFit")]
peaksMale <- peaksMale[(!(peaksMale$Site %in% EXCLUDED)),]

peaksMF <- merge(peaksFemale, peaksMale, by="Site", suffix=c(".female", ".male"))
lapply(peaksMF[,2:ncol(peaksMF)], mean, 2)
lapply(peaksMF[,2:ncol(peaksMF)], sd, 2)

peakrateSEER_ttest_paired <- t.test(peaksMF$peakrateSEER.female, peaksMF$peakrateSEER.male, paired=TRUE)
peakrateFit_ttest_paired <- t.test(peaksMF$peakrateFit.female, peaksMF$peakrateFit.male, paired=TRUE)

peakageSEER_ttest_paired <- t.test(peaksMF$peakageSEER.female, peaksMF$peakageSEER.male, paired=TRUE)
peakageFit_ttest_paired <- t.test(peaksMF$peakageFit.female, peaksMF$peakageFit.male, paired=TRUE)

### COMPARE PROBS/RATIO ##############################################################

probsFemale <- filter(allnice_2Term, sex=="female")[, c("Site","probSEER", "probFit", "probFit2Term", "ratio")]
probsFemale <- probsFemale[(!(probsFemale$Site %in% EXCLUDED)),]
probsMale <- filter(allnice_2Term, sex=="male")[, c("Site","probSEER", "probFit", "probFit2Term", "ratio")]
probsMale <- probsMale[(!(probsMale$Site %in% EXCLUDED)),]

probsMF <- merge(probsFemale, probsMale, by="Site", suffix=c(".female", ".male"))
lapply(probsMF[,2:ncol(probsMF)], mean, 2)
lapply(probsMF[,2:ncol(probsMF)], sd, 2)

probSEER_ttest_paired <- t.test(probsMF$probSEER.female, probsMF$probSEER.male, paired=TRUE)
probFit_ttest_paired <- t.test(probsMF$probFit.female, probsMF$probFit.male, paired=TRUE)
prob2Term_ttest_paired <- t.test(probsMF$probFit2Term.female, probsMF$probFit2Term.male, paired=TRUE)
probRatio_ttest_paired <- t.test(probsMF$ratio.female, probsMF$ratio.male, paired=TRUE)

### HOLM's CORRECTION ##################################################################

pvals <- c(
	uuMF_ttest_paired$p.value,
	kkMF_ttest_paired$p.value,
	bbMF_ttest_paired$p.value,
	peakrateSEER_ttest_paired$p.value,
	peakrateFit_ttest_paired$p.value,
	peakageSEER_ttest_paired$p.value,
	peakageFit_ttest_paired$p.value,
	probSEER_ttest_paired$p.value,
	probFit_ttest_paired$p.value,
	prob2Term_ttest_paired$p.value,
	probRatio_ttest_paired$p.value)

p.adjust(pvals, method="holm")
#print(p.adjust(pvals, method="holm"))