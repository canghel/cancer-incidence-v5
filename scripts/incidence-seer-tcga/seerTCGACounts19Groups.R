# obtain the counts for 5-year intervals for the SEER data corresponding to 
# TCGA cancer types

library(futile.logger);
library(dplyr);
library(tidyr);

### OPTIONS ##################################################################

source("../util/seerTCGAInfo.R");

### PATHS #####################################################################

dataPath <- "../../data/"
outputPath <- "../../outputs/"
seerTcgaPath <- file.path(dataPath, 'seer-tcga');

### LOAD THE STARTING YEAR'S DATA #############################################

data19gp <- read.table(file = file.path(seerTcgaPath, cancertype, paste0(startyear, '-SEER-19-age-groups.csv')),
	header = TRUE,
	stringsAsFactors = FALSE,
	sep = ","
	);
colnames(data19gp) <- c('Seer', 'Sex', 'Age', 'Rate', 'Count', 'Population')

# clean up age and remove rate, since not using it
rowidx <- which(!(data19gp$Age=="Unknown")) 
data19gp <- data19gp[rowidx, ];
data19gp$Rate <- NULL;

### HELPER VARIABLES ##########################################################

# registry dictionary
registrydic <- data.frame(
	seer = unique(sort(data19gp$Seer)),
	pop = c('Alaska_13', 'Atlanta_9', 'OtherCA_18', 'CT_9', 'Detroit_9', 
		'OtherGA_18', 'HI_9', 'IA_9', 'KY_18', 'LosAngeles_13', 'LA_18', 'NJ_18',
		'NM_9', 'RuralGA_13', 'SanFrancisco_9', 'SanJose_13', 'Seattle_9', 'UT_9'),
	stringsAsFactors = FALSE
	);

# ages dictionary
agesdic <- data.frame(
	seer = unique(data19gp$Age),
	pop = c(0, 1, seq(5, 80, 5), '85+'),
	stringsAsFactors = FALSE
	)


### INCORPORATE DATA FROM THE NEXT 3 YEARS ####################################

for (yy in seq(startyear+1,startyear+3)){

	temp <- read.table(file = file.path(seerTcgaPath, cancertype, paste0(yy, '-SEER-19-age-groups.csv')),
		header = TRUE,
		stringsAsFactors = FALSE,
		sep = ","
	);
	colnames(temp) <- c('Seer', 'Sex', 'Age', 'Rate', 'Count', 'Population')
	rowidx <- which(!(temp$Age=="Unknown")) 
	temp <- temp[rowidx, ];

	check1 <- identical(data19gp$Seer, temp$Seer);
	check2 <- identical(data19gp$Sex, temp$Sex);
	check3 <- identical(data19gp$Age, temp$Age);

	if (check1 & check2 & check3){
		data19gp$Count <- data19gp$Count + temp$Count;
		data19gp$Population <- data19gp$Population + temp$Population;
	} else {
		warning(paste("The 19 age groups don't match for year", yy))
	}
	rm(temp);
}

### CLEAN UP 19 AGE GROUP DATA ################################################

flog.info(" -- simpler registry names")
for (jj in 1:nrow(registrydic)){
	idx <- which(data19gp$Seer==registrydic$seer[jj])
	if (length(idx > 0)){
		data19gp$Seer[idx] <- as.character(registrydic$pop[jj])
	}
}

flog.info(" -- shorter age: only first endpoint")
for (jj in 1:nrow(agesdic)){
	idx <- which(data19gp$Age==agesdic$seer[jj])
	if (length(idx > 0)){
		data19gp$Age[idx] <- as.character(agesdic$pop[jj])
	}
}

flog.info(" -- put 0's and 1's together")
for (reg in unique(data19gp$Seer)){
	for (ss in c("Male", "Female", "Male and female")){
		idx0 <- which(data19gp$Seer==reg & data19gp$Sex == ss & data19gp$Age == 0);
		idx1 <- which(data19gp$Seer==reg & data19gp$Sex == ss & data19gp$Age == 1);
		# sum up counts and populations for ages 0 and 1
		if (length(idx1)>0){
			data19gp$Count[idx0] <- data19gp$Count[idx0] + data19gp$Count[idx1];
			data19gp$Population[idx0] <- data19gp$Population[idx0] + data19gp$Population[idx1];
			data19gp <- data19gp[-idx1,]
		}
	}
}

data19gpCounts <- data19gp[ , 1:4]
data19gpCounts <- spread(data19gpCounts, Seer, Count)
data19gpCounts$Sex[which(data19gpCounts$Sex=="Male and female")] <- "Both"

data19gpPop  <- data19gp[,c(1,2,3,5)];
data19gpPop <- spread(data19gpPop, Seer, Population)
data19gpPop$Sex[which(data19gpPop$Sex=="Male and female")] <- "Both"