# obtain the counts for 5-year intervals for the SEER data corresponding to 
# TCGA cancer types

library(futile.logger);
library(dplyr);
library(tidyr);
library(foreach);


### OPTIONS ##################################################################

# some important variables
source("../util/seerTCGAInfo.R")
startyear <- 2010; 
dateSaved <- '2021-08-20'

### GET THE 19 GROUPS #########################################################

#cancertype <- 'PRAD'
sumcounts <- NULL;

for (cancertype in tcgaTypes){
	source("seerTCGACounts19Groups.R");
	source("seerTCGACountsOlder.R");
	source("seerTCGACountsPopCombine.R")
	sumcounts <- rbind(sumcounts, sumcountsOneSite);
	rm(sumcountsOneSite);
}

### COLLECT COAD AND READ COUNTS ##############################################
# Get the total counts for colorectal cancers

coadread <- NULL
for (gg in c('Female', 'Male', 'Both')){
	for (aa in seq(0, 110, 5)){
		idx <- which((sumcounts$Site %in% c("COAD", "READ")) &
			 (sumcounts$Sex == gg) &
			 (sumcounts$Age == aa)
			 );
		tempcounts <- sum(sumcounts$Count[idx]);
		# population isn't summed, should be the same for every age
		if (length(unique(sumcounts$Population[idx])) > 1){
			warning("Population for one age is not equal for all sites.")
		}
		temppop <- sumcounts$Population[idx[1]];
		# combine all info in one row and append to end
		temprow <- c("COADREAD", gg, aa, tempcounts, temppop);
		coadread <- rbind(coadread, temprow);
	} 
}
colnames(coadread) <- c("Site", "Sex", "Age", "Counts", "Population")
coadread <- as.data.frame(coadread, stringsAsFactors = FALSE);
idxnum <- which(colnames(coadread) %in% c("Age", "Counts", "Population"))
for (jj in idxnum){
	class(coadread[,jj]) = "numeric"
}
coadread$CrudeRate <- coadread$Count/coadread$Population*1e5;

sumcounts <- rbind(sumcounts, coadread)
sumcounts <- arrange(sumcounts, Site, Sex, Age)

source("seerTCGAErrorCalculation.R")