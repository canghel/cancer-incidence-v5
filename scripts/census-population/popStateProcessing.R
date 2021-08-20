### PROCESSING THE CENSUS POPULATION FOR STATE REGIONS ########################
# Creates a table of with columns: seer #, region, sex, ages, and counts
# for the state registries

### OPTIONS ###################################################################
# needs to be specified before calling the script
# year is either 2000 or 2010 (Census year)
#year <- '2000';


### PREAMBLE ##################################################################

# libraries
library(futile.logger)
flog.threshold(DEBUG)

# useful functions/information
source('popRegistryInfo.R')
source('../util/util.R')

# paths
dataPath <- "../../data/"
outputPath <- "../../outputs/"
popDataPath <- file.path(dataPath, 'population', year, paste0(year, '-states'));
popFilePattern <- '*_with_ann.csv'


### FUNCTIONS #################################################################

# get one gender info
getOneGenderInfo <- function(state, statepop, gender){
	# get the indices of the state 
	idxState <- which(statepop$GEO.display.label==state)
	# and only those columns which correspond to a gender & Census year
	idxGender <- grep(paste0(gender,".*year"), statepop[1,]);

	flog.debug(paste("Check correct number of age entries:", length(idxGender)==103))

	# take out relevant data from data frame
	ages <- statepop[1,idxGender]; 
	counts <- statepop[idxState, idxGender]
	 
	# rewrite the age categories to give either age of first number in interval
	ages <- gsub("Under 1", "0", ages)
	ages <- gsub("^(\\D*)(\\d+)\\s(\\D*).*", '\\2', ages)

	# reformat
	counts <- as.numeric(as.vector(unlist(counts)))
	ages <- as.vector(unlist(ages))

	# put together
	out <- data.frame(
		seer =  rep(stateRegInfo$seer[which(stateRegInfo$state==state)] , length(ages)),
		region = rep(stateRegInfo$abbrev[which(stateRegInfo$state==state)], length(ages)),
		sex = rep(gender, length(ages)),
		ages = ages,
		counts = counts
		)

	return(out)
}


### LOAD DATA #################################################################

# all of the state-wide seer registries are downloaded into one table
# from the American FactFinder website
popFile <- dir(popDataPath, pattern=popFilePattern)

statepop <- read.table(file = file.path(popDataPath, popFile), 
	header = TRUE, 
	row.names = 1,
	stringsAsFactors = FALSE,
	sep = ","
	)

states <- statepop$GEO.display.label[2:length(statepop$GEO.display.label)]
genders <- c("Male", "Female")

popdata <- NULL;
for (state in states){
	for (gender in genders){
		temp <- getOneGenderInfo(state, statepop, gender)
		popdata <- rbind(popdata, temp)
	}
}

flog.debug(paste("Check correct number of rows entries:", 
	nrow(popdata)/103==2*length(states)))


### SAVE TO FILE ##############################################################

write.table(popdata,
	file.path(outputPath,'population', paste0(Sys.Date(), "-state-pop-", year, ".csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

statepopdata <- popdata;
save(statepopdata, file=file.path(outputPath, 'population', paste0(Sys.Date(), "-state-pop-", year, ".RData")))