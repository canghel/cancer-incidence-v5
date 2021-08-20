### CREATE TABLES FOR 1 AND 5 YEAR GROUPED AGES, BY REGISTRY ##################

### OPTIONS ###################################################################
# need to be specified before calling the script
# year is either 2000 or 2010 (Census year)
# dateSaved is date when the regional and state registry tables were processed
# year <- '2000';
# dateSaved <- '2021-08-20'


### PREAMBLE ##################################################################

# libraries
library(dplyr)
library(tidyr)
library(futile.logger)
flog.threshold(DEBUG)

# paths
dataPath <- "../../data/"
outputPath <- "../../outputs/"


### LOAD REGIONAL AND STATE DATA ##############################################

# combine regional and state populations
load(file.path(outputPath,'population', paste0(dateSaved, "-regional-pop-", year, ".RData")))
load(file.path(outputPath,'population', paste0(dateSaved, "-state-pop-", year, ".RData")))
tempdata <- rbind(statepopdata, regionalpopdata);


### GET POPULATION DATA BY 1 YR GROUPS ########################################

popdata <- unite(tempdata, val, region, seer) %>% spread(val, counts)
popdata$ages <- as.numeric(as.character(popdata$ages))
popdata <- arrange(popdata, sex, ages);

popdataboth <- aggregate(popdata[, -which(colnames(popdata)=="sex")], 
	by=list(popdata$ages), FUN = "sum")
popdataboth <- popdataboth[, -which(colnames(popdataboth)=="ages")]
colnames(popdataboth)[which(colnames(popdataboth)=="Group.1")] <- "ages"

# add it onto the popdata data data frame, it's easier 
popdataboth$sex = rep("Both", nrow(popdataboth))
popdata <- rbind(popdata, popdataboth);


# Checks of the previous code =================================================t
tempfemale <- popdata[which(popdata$sex=='Female'), -which(colnames(popdata)=="sex")]
tempmale <- popdata[which(popdata$sex=='Male'), -which(colnames(popdata)=="sex")]
popdatabothcheck <- tempmale + tempfemale
popdatabothcheck <- popdatabothcheck[, -which(colnames(popdatabothcheck)=="ages")]
print(paste("Checking if population sum correct:", identical(popdatabothcheck, popdataboth[,-which(colnames(popdataboth) %in% c("ages", "sex"))])))

# rm(tempfemale, tempmale, popdatabothcheck, popdataboth);

# # and one more (spot check)
# set.seed(123)
# nn <- 5
# agenums <- sample(popdata$ages, nn);
# for (jj in 1:nn){
# 	print(c(agenums[jj], colSums(popdata[which(popdata$ages==agenums[jj]),3:ncol(popdata)])))
# }
# rm(nn, agenums)


### SAVE POPULATION DATA BY 5 YR AGE GROUPS ###################################

# group in 5 age intervals
# really ugly code...
popdata5yr <- NULL;
for (ss in c('Male', 'Female', 'Both')){
	# subset the data table fro
	idx <- which(popdata$sex == ss);
	subsetpop <- popdata[idx, ]

	# collect info from each sex subset (male, female, both) into one data 
	# frame/matrix thing
	subset5yr  <- NULL;
	# for ages 0 to 99 by 5 year intervals
	for (aa in seq(0,99,5)){
		idxToSum <- which(subsetpop$ages %in% aa:(aa+4));
		temp <- c(ss, aa, colSums(subsetpop[idxToSum, 3:ncol(subsetpop)]));
		subset5yr <- rbind(subset5yr, temp)
	}

	# for the ages 100, 105, and 110 which are already in intervals 
	colnames(subset5yr) <- colnames(popdata)
	subset5yr <- rbind(subset5yr,
		c(ss, 100, as.numeric(subsetpop[which(subsetpop$ages==100), 3:ncol(subsetpop)])),
		c(ss, 105, as.numeric(subsetpop[which(subsetpop$ages==105), 3:ncol(subsetpop)])),
		c(ss, 110, as.numeric(subsetpop[which(subsetpop$ages==110), 3:ncol(subsetpop)]))
	 	);
	# put together with other geneder
	popdata5yr <- rbind(popdata5yr, subset5yr);
}
# fix ugly rownames
rownames(popdata5yr) <- 1:nrow(popdata5yr)
popdata5yr <- data.frame(popdata5yr, stringsAsFactors=FALSE)
for (jj in 2:ncol(popdata5yr)){
	popdata5yr[,jj] <- as.numeric(popdata5yr[,jj]);
}

# sort by gender, then age value
popdata5yr <- arrange(popdata5yr, sex, ages)

# Checks of the previous code =================================================

# TODO (here)


### SAVE ######################################################################

write.table(popdata,
	file.path(outputPath, 'population', paste0(Sys.Date(), "-pop-data-table-", year, ".csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

write.table(popdata5yr,
	file.path(outputPath, 'population', paste0(Sys.Date(), "-pop-data-table-5-yr-", year, ".csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

save(popdata, popdata5yr, 
	file=file.path(outputPath, 'population', paste0(Sys.Date(), "-pop-data-tables-", year, ".RData")));