### Have to run the 19 groups and the older counts before this
### i.e. data19gpCounts, data19gpPop and dataOlderCounts should be in the 
### workspace

library(dplyr);

## LOAD POPULATION INFORMATION FOR OLDER AGES ################################

popOlderFracBoth <- file.path(outputPath, 'population', 
	paste0(dateSaved, '-pop-85-fract-both-', startyear, '.csv'));
popOlderFracMale <- file.path(outputPath, 'population', 
	paste0(dateSaved, '-pop-85-fract-male-', startyear, '.csv'));
popOlderFracFemale <- file.path(outputPath, 'population', 
	paste0(dateSaved, '-pop-85-fract-female-', startyear, '.csv'));

popOlderBoth <- read.delim(popOlderFracBoth, sep=',', stringsAsFactors=FALSE)
popOlderMale <- read.delim(popOlderFracMale, sep=',', stringsAsFactors=FALSE)
popOlderFemale <- read.delim(popOlderFracFemale, sep=',', stringsAsFactors=FALSE)
dataOlderPop <- rbind(popOlderMale, popOlderFemale, popOlderBoth)

# match the registries to the ones under consideration
dataOlderPop <- dataOlderPop[,c('sex','ages', registrydic$pop)]

for (ss in c('Male', 'Female', 'Both')){
	idx <- which(data19gpPop$Age=="85+" & data19gpPop$Sex == ss)
	pop85 <- data19gpPop[idx,]
	data19gpPop <- data19gpPop[-idx, ]
	for (rr in registrydic$pop){
		idx <- which(dataOlderPop$sex==ss);
		dataOlderPop[idx, rr] <- round(dataOlderPop[idx, rr]*as.numeric(pop85[rr]))
	} 
}

# omit Alaska from all data
dataOlderPop <- dplyr::select(dataOlderPop, -Alaska_13)
dataOlderCounts <- dplyr::select(dataOlderCounts, -Alaska_13)
data19gpPop <- dplyr::select(data19gpPop, -Alaska_13)
data19gpCounts <- dplyr::select(data19gpCounts, -Alaska_13)

# sum counts for all selected registries

tempOlderCounts <- data.frame(Sex = dataOlderCounts$Sex, 
	Age = dataOlderCounts$Age,
	Counts = rowSums(dplyr::select(dataOlderCounts, seer18butAK)),
	stringsAsFactors = FALSE);
tempOlderPop <- data.frame(Sex = dataOlderPop$sex, 
	Age = dataOlderPop$ages,
	Population = rowSums(dplyr::select(dataOlderPop, seer18butAK)),
	stringsAsFactors = FALSE);
sumcountsOlder <- merge(tempOlderCounts, tempOlderPop, 
	by.x=c('Sex', 'Age'), by.y=c('Sex','Age'),
	stringsAsFactors=FALSE);

temp19gpCounts <- data.frame(Sex = data19gpCounts$Sex, 
	Age = data19gpCounts$Age,
	Counts = rowSums(dplyr::select(data19gpCounts, seer18butAK)),
	stringsAsFactors = FALSE);
temp19gpPop <- data.frame(Sex = data19gpPop$Sex, 
	Age = data19gpPop$Age,
	Population = rowSums(dplyr::select(data19gpPop, seer18butAK)),
	stringsAsFactors = FALSE);
sumcounts19gp <- merge(temp19gpCounts, temp19gpPop, 
	by.x=c('Sex', 'Age'), by.y=c('Sex','Age'),
	stringsAsFactors=FALSE);

sumcountsOneSite <- rbind(sumcounts19gp, sumcountsOlder);
sumcountsOneSite$Age <- as.numeric(sumcountsOneSite$Age);
sumcountsOneSite$CrudeRate <- sumcountsOneSite$Count/sumcountsOneSite$Population*1e5;
sumcountsOneSite$Site <- rep(cancertype, nrow(sumcountsOneSite));

rm(list=c('data19gp', 'data19gpCounts', 'data19gpPop',
	'dataOlderCounts', 'dataOlderPop',
	'sumcounts19gp', 'sumcountsOlder',
	'temp19gpCounts','temp19gpPop', 
	'tempOlderCounts', 'tempOlderPop',
	'pop85', 'popOlderBoth', 'popOlderMale', 'popOlderFemale',
	'popOlderFracFemale', 'popOlderFracMale', 'popOlderFracBoth'))