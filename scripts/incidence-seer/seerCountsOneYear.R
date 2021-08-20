# find the count data for one year of SEER data

### OPTIONS ###################################################################
# needs to be specified before calling the script
# population year is either 2000 or 2010 (Census year)
# popyear <- '2010';
# seer year is the year for which the data is processed
# seeryear <- '2010';

### PREAMBLE ##################################################################

# libraries
library(dplyr)
library(tidyr)
library(futile.logger)
flog.threshold(DEBUG)

# useful functions/information
source('../util/seerInfo.R')

# paths
dataPath <- "../../data/"
outputPath <- "../../outputs/"

seerPath <- file.path(dataPath, 'seer');

### LOAD 19-GROUP DATA ########################################################

data19gp <- read.table(file = file.path(seerPath , paste0(seeryear, '-SEER-19-age-groups.csv')),
	header = TRUE,
	stringsAsFactors = FALSE,
	sep = ","
	);
colnames(data19gp) <- c('Seer', 'Site', 'Sex', 'Age', 'Rate', 'Count', 'Population')

# ages dictionary
agesdic <- data.frame(
	seer = unique(data19gp$Age),
	pop = c(0, 1, seq(5, 80, 5), '85+', 'Unknown')
	)

### HELPER VARIABLES ##########################################################

# registry dictionary
registrydic <- data.frame(
	seer = unique(sort(data19gp$Seer)),
	pop = c('Alaska_13', 'Atlanta_9', 'OtherCA_18', 'CT_9', 'Detroit_9', 
		'OtherGA_18', 'HI_9', 'IA_9', 'KY_18', 'LosAngeles_13', 'LA_18', 'NJ_18',
		'NM_9', 'RuralGA_13', 'SanFrancisco_9', 'SanJose_13', 'Seattle_9', 'UT_9')
	);

# ages dictionary
agesdic <- data.frame(
	seer = unique(data19gp$Age),
	pop = c(0, 1, seq(5, 80, 5), '85+', 'Unknown')
	)

# subset data to cancers of interest, etc -------------------------------------
rowidx <- which(data19gp$Site %in% selectedsites & !(data19gp$Age=="Unknown")) 
data19gp <- data19gp[rowidx, ];

### GET 85 to 90 DATA #########################################################

getOlder5yr <- function(aa){
	temp <- 0
	prevsubset <- NULL;
	for (jj in seq(aa, aa+4)){

		flog.debug(paste('Age being processed: ', jj))
		tempsubset <- read.table(file = file.path(seerPath , paste0('2000-2015-SEER-age-', jj ,'.csv')),
			header = TRUE,
			stringsAsFactors = FALSE,
			sep = ","
			);
		colnames(tempsubset) <- c('year', 'Seer', 'Site', 'Sex', 'Rate', 'Count', 'Population');

		rowidx <- which((tempsubset$Site %in% selectedsites) & (tempsubset$year==seeryear))
		tempsubset <- tempsubset[rowidx, ];
		# flog.debug(head(tempsubset))
		
		if (is.null(prevsubset)){
			temp <- as.numeric(tempsubset$Count);

		} else {
			if (identical(prevsubset$year, tempsubset$year) & identical(prevsubset$Site, tempsubset$Site) & identical(prevsubset$Sex, tempsubset$Sex)){
				flog.debug(paste('The columns match.'))
				temp <- temp + as.numeric(tempsubset$Count);
			} else {
			 	flog.fatal("Columns don't match, go back and fix.")
			}
		}

		prevsubset <- tempsubset;
	}

	output <- tempsubset;
	output$Count <- temp;
	output$Age <- aa;
	output$year <- NULL;

	return(output)
}

older85 <- getOlder5yr(85)
older90 <- getOlder5yr(90)
older95 <- getOlder5yr(95)

### GET 100 to 105 DATA, 105-110, and 110-120 #################################

flog.info("Getting older data.")

getOlderst5yr <- function(aa){
	if (aa==110){bb <- 120} else {bb <- aa+4}
	output <- read.table(file = file.path(seerPath , paste0('2000-2015-SEER-age-', aa ,'-', bb,'.csv')),
		header = TRUE,
		stringsAsFactors = FALSE,
		sep = ","
		);
	colnames(output) <- c('year', 'Seer', 'Site', 'Sex', 'Rate', 'Count', 'Population');

	rowidx <- which((output$Site %in% selectedsites) & (output$year==seeryear))
	output <- output[rowidx, ];
	output$Age <- rep(aa, nrow(output));
	output$year <- NULL;

	return(output)
}

older100 <- getOlderst5yr(aa=100);
older105 <- getOlderst5yr(aa=105);
older110 <- getOlderst5yr(aa=110); 

### PUT TOGETHER ##############################################################

flog.info("Putting it all together.")

all5yr <- rbind(data19gp, older85, older90, older95, older100, older105, older110);

rm(data19gp, older85, older90, older95, older100, older105, older110);

flog.info(" -- simpler registry names")
for (jj in 1:nrow(registrydic)){
	idx <- which(all5yr$Seer==registrydic$seer[jj])
	if (length(idx > 0)){
		all5yr$Seer[idx] <- as.character(registrydic$pop[jj])
	}
}

flog.info(" -- shorter age: only first endpoint")
for (jj in 1:nrow(agesdic)){
	idx <- which(all5yr$Age==agesdic$seer[jj])
	if (length(idx > 0)){
		all5yr$Age[idx] <- as.character(agesdic$pop[jj])
	}
}

flog.info(" -- put 0's and 1's together")
for (reg in unique(all5yr$Seer)){
	for (can in unique(all5yr$Site)){
		for (ss in c("Male", "Female", "Male and female")){
			idx0 <- which(all5yr$Seer==reg & all5yr$Site==can & all5yr$Sex == ss & all5yr$Age == 0);
			idx1 <- which(all5yr$Seer==reg & all5yr$Site==can & all5yr$Sex == ss & all5yr$Age == 1);
	    	# sum up counts and populations for ages 0 and 1
	    	if (length(idx1)>0){
				all5yr$Count[idx0] <- all5yr$Count[idx0] + all5yr$Count[idx1];
				all5yr$Population[idx0] <- all5yr$Population[idx0] + all5yr$Population[idx1];
				all5yr <- all5yr[-idx1,]
			}
		}
	}
}

flog.info(" -- create data tables")
all5yrtemp <- all5yr[,c(1,2,3,4,6)];
all5yrtable <- spread(all5yrtemp, Seer, Count)

all5yrtable <- arrange(all5yrtable, Site, Sex, Age)
all5yrtable$Sex[which(all5yrtable$Sex=="Male and female")] <- "Both"

all5yrtemp <- all5yr[,c(1,2,3,4,7)];
all5yrpoptable <- spread(all5yrtemp, Seer, Population)
all5yrpoptable$Sex[which(all5yrpoptable$Sex=="Male and female")] <- "Both"