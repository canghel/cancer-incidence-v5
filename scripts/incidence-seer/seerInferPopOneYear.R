# run IMMEDIATELY after seerCountsOneYear.R/seerComparePopOneYear.R
# without clearing workspace

### OPTIONS ###################################################################
# needs to be specified before calling the script
# popyear and seeryear specified in previous script
# date that seer processed cases were saved
# dateSaved <- '2021-08-20'

### PREAMBLE ##################################################################

library(RColorBrewer);
popPath <- file.path(outputPath, 'population', 
	paste0(dateSaved, '-pop-data-tables-', popyear, '.RData'));
popOlderPath <- file.path(outputPath, 'population', 
	paste0(dateSaved, '-pop-older-fract-', popyear, '.RData'));


### GET POPULATION DATA #######################################################

load(popPath);
load(popOlderPath);


### FUNCTION ##################################################################

estimatePopulation <- function(gender, olderfrac){

	seersubset <- all5yrpoptable[which(all5yrpoptable$Sex==gender), ];

	for (jj in 4:ncol(seersubset)){
		temp <- unique(seersubset[, jj]) 
		flog.debug(paste("Number unique values in registry ", colnames(seersubset[jj]), 
			" is:", length(temp)));
		if (length(temp) > 23){
			flog.fatal("Too many values, check!")
		} 
	}
	# ok, as expected, same as number of age classes
	# almost... might be less than 19, if some numbers repeat

	# get only one site, since values are same for all sites
	seersubset <- seersubset[which(seersubset$Site=="Esophagus"), ]
	seersubset$Site <- NULL;

	seersubset85tot <- seersubset[which(seersubset$Age=="85+"), ];
	seersubsetpop <- seersubset[-which(seersubset$Age=="85+"), ];

	# bad loop, again...
	for (aa in olderfrac$ages){
		for (rr in colnames(olderfrac[3:ncol(olderfrac)])){
			srowidx <- which(seersubsetpop$Age==aa)
			scolidx <- which(colnames(seersubsetpop)==rr)
			prowidx <- which(olderfrac$ages==aa)
			pcolidx <- which(colnames(olderfrac)==rr)
			tidx <- which(colnames(seersubset85tot)==rr); 
			# awful code, sigh
			if ((length(srowidx) > 0) & (length(scolidx) > 0)){
				seersubsetpop[srowidx,scolidx] <- round(olderfrac[prowidx,pcolidx]*seersubset85tot[tidx]);
			}
		}	
	}

	seersubsetpop$Age <- as.numeric(seersubsetpop$Age)
	seersubsetpop <- seersubsetpop[order(seersubsetpop$Age),]

	# sanitycheck
	print(colSums(seersubsetpop[which(seersubsetpop$Age >= 85),3:ncol(seersubsetpop)])-seersubset85tot[3:ncol(seersubset85tot)])

	return(seersubsetpop);
}


### INFER POPULATION FOR EACH GENDER, FOR OLDEST ##############################
# used closest Census population older ages ratios to infer the populations
# for the oldest categories

seermalepop  <- estimatePopulation("Male", male85frac)
seerfemalepop  <- estimatePopulation("Female", female85frac)
seerbothpop  <- estimatePopulation("Both", both85frac)

save(all5yr, all5yrtable,
	seerfemalepop, seermalepop, seerbothpop,
	file = file.path(outputPath, 'seer', "count-data", paste0(Sys.Date(), '-SEER-', seeryear, '-pop-', popyear, '.RData'))
	);