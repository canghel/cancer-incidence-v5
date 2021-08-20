### PROCESSING THE CENSUS POPULATION FOR REGIONAL REGISTRIES ##################
# Creates a table of with columns: seer #, region, sex, ages, and counts
# for the registries which are smaller than a whole state, but not including
# Native registries

### OPTIONS ###################################################################
# needs to be specified before calling the script
# year is either 2000 or 2010 (Census year)
# year <- '2000';


### PREAMBLE ##################################################################

# libraries
library(futile.logger)
flog.threshold(DEBUG)

# useful functions/information
source('popRegistryInfo.R')

# paths
dataPath <- "../../data/"
outputPath <- "../../outputs/"
popDataPath <- file.path(dataPath, 'population', year);
popFilePattern <- '*_with_ann.csv'


### FUNCTIONS ##################################################################

# sum up the data for specified counties from saved table
# e.g. for Georgia the Atlanta, Rural, and Greater Georgia registries consist
# of different groups of counties
getCountiesTotal <- function(folder, countyvector, regionname){

	# get the data path to the correct file and load the data for all counties
	popDataRegionPath <- file.path(popDataPath, folder);
	popFile <- dir(popDataRegionPath, popFilePattern);
	

	regionpop <- read.table(file = file.path(popDataRegionPath, popFile), 
		header = TRUE, 
		row.names = 1,
		stringsAsFactors = FALSE,
		sep = ","
		)

	# get the rows for just the specified counties
	idxCounty <- which(regionpop$GEO.display.label %in% countyvector);
	flog.debug(paste0('Check got all the counties: ', length(idxCounty) == length(countyvector)))

	# sum up the populatons in those counties
	# (or if it's just one county leave it the same)
	regiontotals <- apply(regionpop[idxCounty, 3:ncol(regionpop)], 2, as.numeric)
	if (length(countyvector) > 1){
		regiontotals <- colSums(regiontotals)
	}

	# and return the new dataframe, with the same colnames as before
	out <- rbind(regionpop[1,], c(NA, regionname, regiontotals));
	colnames(out) <- colnames(regionpop);

	return(out)
	}


# get one gender info
# very similar to the function for states
getOneGenderInfo <- function(regionpop, gender, regionname, seernum){

	idxGender <- grep(paste0(gender,".*year"), regionpop[1,]);

	flog.debug(paste("Check correct number of age entries:", length(idxGender)==103))

	# take out relevant data from data frame
	ages <- regionpop[1,idxGender]; 
	counts <- regionpop[2, idxGender]
	 
	# rewrite the age categories to give either age of first number in interval
	ages <- gsub("Under 1", "0", ages)
	ages <- gsub("^(\\D*)(\\d+)\\s(\\D*).*", '\\2', ages)

	# reformat
	counts <- as.numeric(as.vector(unlist(counts)))
	ages <- as.vector(unlist(ages))

	# put together
	out <- data.frame(
		seer =  rep(seernum, length(ages)),
		region = rep(regionname, length(ages)),
		sex = rep(gender, length(ages)),
		ages = ages,
		counts = counts
		)

	return(out)
}

# TODO
# do a spot test here


### EXTRACT DATA FROM ALL REGIONS #############################################

regionalpopdata <- NULL
# loop over folders of larger regions (e.g. Georgia, California)
for (reg in names(regionalList)){
	# find name of folder & file for that year and the larger region
	folder <- paste0(year, '-', reg)
	popDataRegionPath <- file.path(popDataPath, folder);
	popFile <- dir(popDataRegionPath, popFilePattern);

	# load data 
	regionpop <- read.table(file = file.path(popDataRegionPath, popFile), 
		header = TRUE, 
		row.names = 1,
		stringsAsFactors = FALSE,
		sep = ","
		)
	flog.info(paste("Working on data from folder:", folder))

	# load each of the different registries in that region
	countiesProcessed <- NULL
	for (jj in 1:length(regionalList[[reg]])){
		regname <-  regionalList[[reg]][[jj]]
		seernum <- regionalRegInfo$seer[which(regionalRegInfo$region==regname)]
		flog.info(paste("Working on the registry:", regname))
		# if the string is not part of the "Other" (remainder) counties, then
		# get the sums of the population in each county in the registry, for each age
		# and keep track of the processed counties 
		if (!(grepl("Other", regname))){
			regrawdata <- getCountiesTotal(folder, countyList[[regname]], regname)
			countiesProcessed <- c(countiesProcessed, countyList[[regname]])
			# print(countiesProcessed)
		} 
		# if the string is part of the "Other" counties, then the registry consists
		# of all other counties in the state
		if (grepl("Other", regname)){
			otherCounties <- regionpop$GEO.display.label[which(!(regionpop$GEO.display.label 
			 	%in% c('Geography', countiesProcessed)))];
			# print(otherCounties)
			regrawdata <- getCountiesTotal(folder, otherCounties, regname)
		}

		# reformat nicely
		regnicedata <- NULL
		for (sex in c('Male', 'Female')){
			regnicedata <- rbind(regnicedata, getOneGenderInfo(regrawdata, sex, regname, seernum))
		}

		# concatenate the data of the current registry to the end of the regional data 
		regionalpopdata <- rbind(regionalpopdata, regnicedata)
	}

}


### SAVE ######################################################################

write.table(regionalpopdata,
	file.path(outputPath,'population', paste0(Sys.Date(), "-regional-pop-", year, ".csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

save(regionalpopdata, file=file.path(outputPath,'population', paste0(Sys.Date(), "-regional-pop-", year, ".RData")))