### PUT TOGETHER THE COUNTS FROM MULTIPLE YEARS ###############################

### OPTIONS ###################################################################
years <- c('2010', '2011', '2012', '2013');
popyear <- '2010';
dateSaved <- '2021-08-20'

### PREAMBLE ##################################################################
# paths
dataPath <- "../../data/"
outputPath <- "../../outputs/"
source("../util/seerInfo.R")

seerOutputPath <- file.path(outputPath, 'seer', 'count-data');

selectedreg <- seer18butAK;

### ADD UP COUNTS FROM EACH YEAR ##############################################
# loop over each year (jj is the index of years)

for (jj in 1:4){
	load(file.path(seerOutputPath, paste0(dateSaved, '-SEER-', years[jj], '-pop-', popyear, '.RData')))

	# initialize the data frames where the data is saved
	if (jj == 1){
		allcounts <- all5yrtable;
		allpopfemale <- seerfemalepop;
		allpopmale <- seermalepop; 
		allpopboth <- seerbothpop
	} else {
		# then add to the respective data
		if (all(allcounts$Site == all5yrtable$Site, allcounts$Sex == all5yrtable$Sex, allcounts$Age == all5yrtable$Age)){
			allcounts[ ,4:ncol(allcounts)] = allcounts[ ,4:ncol(allcounts)] + all5yrtable[ ,4:ncol(allcounts)]
		}
		if (all(allpopfemale$Sex == seerfemalepop$Sex, allpopfemale$Age == seerfemalepop$Age)){
			allpopfemale[ ,3:ncol(allpopfemale)] = allpopfemale[ ,3:ncol(allpopfemale)] + seerfemalepop[ ,3:ncol(allpopfemale)]
		}
		if (all(allpopmale$Sex == seermalepop$Sex, allpopmale$Age == seermalepop$Age)){
			allpopmale[ ,3:ncol(allpopmale)] = allpopmale[ ,3:ncol(allpopmale)] + seermalepop[ ,3:ncol(allpopmale)]
		}
		if (all(allpopboth$Sex == seerbothpop$Sex, allpopboth$Age == seerbothpop$Age)){
			allpopboth[ ,3:ncol(allpopboth)] = allpopboth[ ,3:ncol(allpopboth)] + seerbothpop[ ,3:ncol(allpopboth)]
		}
	}
}

### SUM UP THE COUNTS ACROSS REGISTRIES SELECTED ##############################
# omitting Alaska native registy because the error from SEER population and
# Census population is greater than 5%

findSum <- function(alldata){
	idx1 <- which(colnames(alldata) %in% c('Site', 'Sex', 'Age'))
	idx2 <- which(colnames(alldata) %in% selectedreg)
	temp <- rowSums(alldata[,idx2]);
	sumdata <- cbind(alldata[,idx1], temp);
	return(sumdata)
}

sumcounts <- findSum(allcounts)
sumpopfemale <- findSum(allpopfemale) 
sumpopmale <- findSum(allpopmale) 
sumpopboth <- findSum(allpopboth) 

### CLEAN UP ##################################################################

sumcounts <- sumcounts[-which(sumcounts$Age=="85+"), ];
sumcounts$Age <- as.numeric(sumcounts$Age);
sumpopfemale$Age <- as.numeric(sumpopfemale$Age);
sumpopmale$Age <- as.numeric(sumpopmale$Age);
sumpopboth$Age <- as.numeric(sumpopboth$Age);

colnames(sumcounts)[which(colnames(sumcounts)=='temp')] <- "Count"; 
colnames(sumpopfemale)[which(colnames(sumpopfemale)=='temp')]  <- "Population"
colnames(sumpopmale)[which(colnames(sumpopmale)=='temp')]  <- "Population"
colnames(sumpopboth)[which(colnames(sumpopboth)=='temp')]  <- "Population"

### ADD POPULATON COLUMN TO SUM COUNTS ########################################

sumcounts$Population <- NA;

if (identical(sumpopmale$Age, sumpopfemale$Age, sumpopboth$Age)){
	for (jj in 1:nrow(sumpopboth)){
		idx <- which(sumcounts$Sex == "Male" & sumcounts$Age == sumpopmale$Age[jj])
		sumcounts$Population[idx] <- sumpopmale$Population[jj];

		idx <- which(sumcounts$Sex == "Female" & sumcounts$Age == sumpopfemale$Age[jj])
		sumcounts$Population[idx] <- sumpopfemale$Population[jj];

		idx <- which(sumcounts$Sex == "Both" & sumcounts$Age == sumpopboth$Age[jj])
		sumcounts$Population[idx] <- sumpopboth$Population[jj];
	}
}



### INCLUDE AN ALL MAJOR SITES CATEGORY #######################################

badidx <- which(selectedsites=="All Sites");
if (length(badidx)>0){
	selectedmajor <- selectedsites[-badidx];
	selectedmajor <- selectedmajor[which(!(selectedmajor %in% c(femalecancers, malecancers)))]
}

# major cancers non-sex -------------------------------------------------------
majorcancers <- NULL;
for (gg in c("Male", "Female", "Both")){
	for (aa in seq(0, 110, 5)){
		majoridx <- which((sumcounts$Site %in% selectedmajor) &
			 (sumcounts$Sex == gg) &
			 (sumcounts$Age == aa)
			 );
		tempcounts <- sum(sumcounts$Count[majoridx]);
		# population isn't summed, should be the same for every age
		if (length(unique(sumcounts$Population[majoridx])) > 1){
			warning("Population for one age is not equal for all sites.")
		}
		temppop <- sumcounts$Population[majoridx[1]];
		# combine all info in one row and append to end
		temprow <- c("All Major Non Sex", gg, aa, tempcounts, temppop);
		majorcancers <- rbind(majorcancers, temprow);
	} 
}
colnames(majorcancers) <- c("Site", "Sex", "Age", "Count", "Population")
majorcancers <- as.data.frame(majorcancers, stringsAsFactors = FALSE);
idxnum <- which(colnames(majorcancers) %in% c("Age", "Count", "Population"))
for (jj in idxnum){
	class(majorcancers[,jj]) = "numeric"
}

sumcounts <- rbind(sumcounts, majorcancers)

# major cancers including sex cancers -----------------------------------------
majorcancers <- NULL;

for (gg in c("Male", "Female", "Both")){
	for (aa in seq(0, 110, 5)){
		if (gg == "Male"){
			ss <- c(selectedmajor, malecancers);
		} else if (gg == "Female") {
			ss <- c(selectedmajor, femalecancers);
		} else if (gg == "Both") {
			ss <- c(selectedmajor, femalecancers, malecancers);
		}
		majoridx <- which((sumcounts$Site %in% ss) &
			 (sumcounts$Sex == gg) &
			 (sumcounts$Age == aa)
			 );

		tempcounts <- sum(sumcounts$Count[majoridx]);
		# population isn't summed, should be the same for every age
		if (length(unique(sumcounts$Population[majoridx])) > 1){
			warning("Population for one age is not equal for all sites.")
		}
		temppop <- sumcounts$Population[majoridx[1]];
		# combine all info in one row and append to end
		temprow <- c("All Major", gg, aa, tempcounts, temppop);
		majorcancers <- rbind(majorcancers, temprow);
	} 
}
colnames(majorcancers) <- c("Site", "Sex", "Age", "Count", "Population")

majorcancers <- as.data.frame(majorcancers, stringsAsFactors = FALSE);
idxnum <- which(colnames(majorcancers) %in% c("Age", "Count", "Population"))
for (jj in idxnum){
	class(majorcancers[,jj]) = "numeric"
}

sumcounts <- rbind(sumcounts, majorcancers)

selectedsites <- c(selectedsites, "All Major Non Sex");
selectedsites <- c(selectedsites, "All Major");

### COMPUTE CRUDE RATE ########################################################

sumcounts$CrudeRate <- sumcounts$Count/sumcounts$Population*1e5;

sumcounts <- arrange(sumcounts, Site, Sex, Age)

### SAVE TO FILE ##############################################################

save(sumcounts, file = file.path(seerOutputPath,
	paste0(Sys.Date(), '-SEER-', years[1], '-to-', years[length(years)], '-pop-', popyear, '-rates.RData')) )

write.table(sumcounts,
	file.path(seerOutputPath,
		paste0(Sys.Date(), '-SEER-', years[1], '-to-', years[length(years)], '-pop-', popyear, '-rate-table.csv')),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)