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

### EXAMINE B #################################################################

bResults <- NULL

bbFemale <- filter(allgfits_u, sex=="female")[, c("cancertype","bb")]
bbMale <- filter(allgfits_u, sex=="male")[, c("cancertype","bb")]
bbBoth <- filter(allgfits_u, sex=="both")[, c("cancertype","bb")]
bbFemaleNonrep <- filter(bbFemale, !(cancertype %in% femalecancers));
bbMaleNonrep <- filter(bbMale, !(cancertype %in% malecancers));
bbFemaleRep <- filter(bbFemale, (cancertype %in% femalecancers));
bbMaleRep <- filter(bbMale, (cancertype %in% malecancers));

# Compare b's for males and females ------------------------------------------
# not sure if should do paired test?
# if paired there is a difference for both, small in magnitude but significant
bbMF <- merge(bbFemale, bbMale, by="cancertype", suffix=c(".female", ".male"))
bbMF_ttest_paired <- t.test(bbMF$bb.female, bbMF$bb.male, paired=TRUE)
# print(paste0("n=", nrow(bbMF)))
# print(bbMF_ttest_paired)

bMF_summary <- list(c("bb males/females non-reproductive", bbMF_ttest_paired$method, 
	paste0("n = ", nrow(bbMF)), paste0("P-val = ", bbMF_ttest_paired$p.value),
	paste0(names(bbMF_ttest_paired$estimate), " = ", as.numeric(bbMF_ttest_paired$estimate))))

bResults <- append(bResults, bMF_summary);

# Get mean b's for males, females, and both ---------------------------------

bMeans_summary <- list(
	c(paste0("Mean value of bb, males ", mean(bbMale$bb)), paste0("SD = ", sd(bbMale$bb)), 
		paste0("n = ", nrow(bbMale)), paste0("1/b = ", 1/mean(bbMale$bb))),
	c(paste0("Mean value of bb, females ", mean(bbFemale$bb)), paste0("SD = ", sd(bbFemale$bb)), 
		paste0("n = ", nrow(bbFemale)), paste0("1/b = ", 1/mean(bbFemale$bb))),
	c(paste0("Mean value of bb, both ", mean(bbBoth$bb)), paste0("SD = ", sd(bbBoth$bb)), 
		paste0("n = ", nrow(bbBoth)), paste0("1/b = ", 1/mean(bbBoth$bb))),
	c(paste0("Mean value of bb, males, non-reproductive ", mean(bbMaleNonrep$bb)), paste0("SD = ", sd(bbMaleNonrep$bb)), 
		paste0("n = ", length(bbMaleNonrep$bb)), paste0("1/b = ", 1/mean(bbMaleNonrep$bb))),
	c(paste0("Mean value of bb, females, non-reproductive ", mean(bbFemaleNonrep$bb)), paste0("SD = ", sd(bbFemaleNonrep$bb)), 
		paste0("n = ", length(bbFemaleNonrep$bb)), paste0("1/b = ", 1/mean(bbFemaleNonrep$bb))),
	c(paste0("Mean value of bb, females, reproductive ", mean(bbFemaleRep$bb)), paste0("SD = ", sd(bbFemaleRep$bb)), 
		paste0("n = ", length(bbFemaleRep$bb)))
	)

bResults <- append(bResults, bMeans_summary);

# Get comparison of b's for reproductive vs. non-reproductive cancers ------

bbFemRep_ttest <- t.test(x=bbFemaleRep$bb, y=bbFemaleNonrep$bb);
bbRep_ttest <- t.test(x=c(bbFemaleRep$bb, bbMaleRep$bb), y=bbBoth$bb);

bbFemRep_summary <- list(c("bb Female reproductive vs. non-repoductive",  bbFemRep_ttest$method,  
		paste0("n1 = ", length(bbFemaleRep$bb)),
		paste0("n2 = ", length(bbFemaleNonrep$bb)), 
		paste0("P-val = ", bbFemRep_ttest$p.value)))

bbRep_summary <- list(c("bb reproductive vs. (both) non-repoductive",  bbRep_ttest$method,  
		paste0("n1 = ", length(c(bbFemaleRep$bb, bbMaleRep$bb))),
		paste0("n2 = ", length(bbBoth$bb)), 
		paste0("P-val = ", bbRep_ttest$p.value)))

bResults <- append(append(bResults, bbFemRep_summary), bbRep_summary);



### EXAMINE K ################################################################

kResults <- NULL

kkFemale <- filter(allgfits_u, sex=="female")[, c("cancertype","kk")]
kkMale <- filter(allgfits_u, sex=="male")[, c("cancertype","kk")]
kkBoth <- filter(allgfits_u, sex=="both")[, c("cancertype","kk")]
kkFemaleNonrep <- filter(kkFemale, !(cancertype %in% femalecancers));
kkMaleNonrep <- filter(kkMale, !(cancertype %in% malecancers));
kkFemaleRep <- filter(kkFemale, (cancertype %in% femalecancers));
kkMaleRep <- filter(kkMale, (cancertype %in% malecancers));

kkFemRep_ttest <- t.test(x=kkFemaleRep$kk, y=kkFemaleNonrep$kk);

kkFemRep_summary <- list(c("kk Female reproductive vs. non-repoductive",  kkFemRep_ttest$method,  
		paste0("n1 = ", length(kkFemaleRep$kk)),
		paste0("n2 = ", length(kkFemaleNonrep$kk)), 
		paste0("P-val = ", kkFemRep_ttest$p.value)))

print(kkFemRep_ttest)

kMeans_summary <- list(
	c(paste0("Mean value of kk, females, non-reproductive ", mean(kkFemaleNonrep$kk)), paste0("SD = ", sd(kkFemaleNonrep$kk)), 
		paste0("n = ", length(kkFemaleNonrep$kk))),
	c(paste0("Mean value of kk, females, reproductive ", mean(kkFemaleRep$kk)), paste0("SD = ", sd(kkFemaleRep$kk)), 
		paste0("n = ", length(kkFemaleRep$kk)))
	)

kResults <- append(kMeans_summary, kkFemRep_summary)

# Record the results ----------------------------------------------------------

bkResults <- append(bResults, kResults);


# !!!!!!
# Careful with this, it will keep appending if you re-run script!
lapply(1:length(bkResults), function(x) write.table(t(as.data.frame(bkResults[x])), 
       	file=file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, 
       	"-", ageToStartFit,  "-b-k-comparison-results.csv")), append= T, sep=',', 
		quote = F, col.names = F, row.names = F))
