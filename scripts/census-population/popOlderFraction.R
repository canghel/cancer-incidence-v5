# From the generated tables, find fraction for each population:
# Of 85+ population by gender, in each registry, in each of the groups 85-89, 
# 90-94, 100-104, 105-109, and 100+

### OPTIONS ###################################################################
# need to be specified before calling the script
# year is either 2000 or 2010 (Census year)
# dateSaved is date when the regional and state registry tables were processed
# year <- '2000';
# dateSaved <- '2021-08-20'


### PREAMBLE ##################################################################

# libraries
library(futile.logger)
flog.threshold(DEBUG)

# paths
dataPath <- "../../data/"
outputPath <- "../../outputs/"
docsPath <- "../../docs/"


### LOAD POPDATA TABLES ######################################################

# load the data tables
load(file.path(outputPath,'population', paste0(dateSaved, "-pop-data-tables-", year, ".RData")))


### SET UP OLDER DATA FRACTION TABLES ########################################

# male ------------------------------------------------------------------------
male85frac <- popdata5yr[which(popdata5yr$sex=="Male" & popdata5yr$age >= 85),]
male85tot <- colSums(male85frac[, 3:ncol(male85frac)])
# should vectorize...
for (jj in 3:ncol(male85frac)){
	male85frac[,jj] <- male85frac[,jj]/male85tot[jj-2]
}

check <- colSums(male85frac[, 3:ncol(male85frac)]);
flog.debug(paste("Fractions add up to 1:", all(check==1)));

# female ----------------------------------------------------------------------
female85frac <- popdata5yr[which(popdata5yr$sex=="Female" & popdata5yr$age >= 85),]
female85tot <- colSums(female85frac[, 3:ncol(female85frac)])
# should vectorize...
for (jj in 3:ncol(female85frac)){
	female85frac[,jj] <- female85frac[,jj]/female85tot[jj-2]
}

check <- colSums(female85frac[, 3:ncol(female85frac)]);
flog.debug(paste("Fractions add up to 1:", all(check > 1-1e-12 & check < 1+1e-12)));

# both ----------------------------------------------------------------------
both85frac <- popdata5yr[which(popdata5yr$sex=="Both" & popdata5yr$age >= 85),]
both85tot <- colSums(both85frac[, 3:ncol(both85frac)])
# should vectorize...
for (jj in 3:ncol(both85frac)){
	both85frac[,jj] <- both85frac[,jj]/both85tot[jj-2]
}

check <- colSums(both85frac[, 3:ncol(both85frac)]);
flog.debug(paste("Fractions add up to 1:", all(check > 1-1e-12 & check < 1+1e-12)));


### SAVE ######################################################################

write.table(male85frac,
	file.path(outputPath, 'population', paste0(Sys.Date(), "-pop-85-fract-male-", year, ".csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

write.table(female85frac,
	file.path(outputPath, 'population', paste0(Sys.Date(), "-pop-85-fract-female-", year, ".csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

write.table(both85frac,
	file.path(outputPath, 'population', paste0(Sys.Date(), "-pop-85-fract-both-", year, ".csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

save(male85frac, male85tot,
	female85frac, female85tot,
	both85frac, both85tot, 
	file=file.path(outputPath, 'population', paste0(Sys.Date(), "-pop-older-fract-", year, ".RData")));


### ADD ONE TABLE TO THE DOCUMENTATION ########################################

if (year == 2000){
	write.table(male85frac,
		file.path(docsPath, paste0(Sys.Date(), "-pop-85-fract-male-", year, ".csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	write.table(female85frac,
		file.path(docsPath, paste0(Sys.Date(), "-pop-85-fract-female-", year, ".csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	write.table(both85frac,
		file.path(docsPath, paste0(Sys.Date(), "-pop-85-fract-both-", year, ".csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)
}