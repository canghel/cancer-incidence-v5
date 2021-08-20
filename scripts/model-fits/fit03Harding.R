### FIT HARDING EQUATION & IS WEIGHTED ##########################################

### PREAMBLE ####################################################################

library(dplyr)
library(tidyr)
library(minpack.lm)

library(futile.logger)
flog.threshold(DEBUG)

### LOAD DATA #################################################################

firstyr <- strsplit(fileToLoadErrs, '-')[[1]][4]
lastyr <- strsplit(fileToLoadErrs, '-')[[1]][5]

set.seed(123)


### FUNCTION & GRADIENTS ######################################################

hmodel <- function(coefs, tt){
	aa <- exp(coefs[1]) # coef = log(alpha)
	bb <- coefs[2]/1000 # coef  = beta*1000 
	mm <- coefs[3] # mm = k-1
	out <- aa*(tt^mm)*(1-bb*tt)*100000;
} 

### FUNCTIONS: FITTING ########################################################

weighedFit <- function(alldata, cancertype, sex, ages, ageThresh, ageMaxThresh=120){

	df <- filter(alldata, Site == cancertype & Sex == sex); 
	df <- arrange(df, Age)

	probSEER <- sum(df$CrudeRate[df$Age<=100]*5)/100000

	aainit <- -20
	bbinit <- 9
	mminit <- 4

	# set up the data and weights ----------------------------------------------
	# needed to arrange df relative to age, to match midpt of interval
	subsetdata <- data.frame(
		xx = ages,
		yy = df$CrudeRate
		);
	# should be proportional to inverse of variance
	# maxb-minb is about 2 standard deviations
	weights <- 1/((df$maxb - df$minb)/2)^2

	# threshold to fit only past a given age ----------------------------------
	idx <- which(subsetdata$xx > ageThresh)
	subsetdata <- subsetdata[idx, ];
	weights <- weights[idx];

	# older ages threshold -----------------------------------------------------
	# did not test this?
	idx <- which(subsetdata$xx < ageMaxThresh)
	subsetdata <- subsetdata[idx, ];
	weights <- weights[idx];

	# for testis, need to exclude largest ages to be able to fit peak ----------
	if (cancertype %in% c("Testis", "TGCT")){
		idx <- which(subsetdata$xx < 55)
		subsetdata <- subsetdata[idx, ];
		# do weights match?
		weights <- weights[idx]
	}

	# different fit for sex-related cancers ------------------------------------ 
	if (cancertype %in% c(femalecancers, malecancers)){
		# oh, wait, since looking for those greater than 50, all indices are
		# automatically greater than 15
		# but doesn't hurt to do it this way
		idx <- which(subsetdata$xx > 15)
		subsetdata <- subsetdata[idx,]
		subsetdata$xx <- subsetdata$xx - 15;
		weights <- weights[idx]
	}

	# try to fit, else return NA's ---------------------------------------------
	out <- tryCatch({
		fit <- nlsLM(yy ~ exp(aa)*(xx^mm)*(1-bb/1000*xx)*100000,
			data = subsetdata,
			weights = weights,
			start = list(aa=aainit, bb=bbinit, mm = mminit),
			control = list(maxiter = 1000, warnOnly=TRUE),
			lower = c(-Inf, 0, 0)
			);
		answer <- c(unlist(coef(fit)), summary(fit)$parameters["aa",2], summary(fit)$parameters["bb",2], summary(fit)$parameters["mm",2],
			summary(fit)$parameters["aa",4], summary(fit)$parameters["bb",4], summary(fit)$parameters["mm",4],
			summary(fit)$sigma, fit$convInfo$isConv, probSEER)
		#browser()
	}, error = function(err){
		answer <- rep(NA, 12)
	})

	return(out)
}

getpeakrate <- function(alldata, cancertype, sex, ages){
	sexString <- paste0(toupper(substr(sex,1,1)), substring(sex, 2))
	datasubset <- filter(alldata, Site == cancertype & Sex == sexString);
	maxidx <- which.max(datasubset$CrudeRate[datasubset$Age<=100]);
	out <- c(datasubset$CrudeRate[maxidx], datasubset$Age[maxidx], ages[maxidx]);
	return(out);
}

### MAKE INTO A NICE TABLE ####################################################

makenicetable <- function(fittable, gender){
	if (gender == "male"){
		idx1 <- which(!(fittable[,2] %in% malecancers))
		idx2 <- which(fittable[,2] %in% malecancers)
	}
	if (gender == "female"){
		idx1 <- which(!(fittable[,2] %in% femalecancers))
		idx2 <- which(fittable[,2] %in% femalecancers)
	}
	if (gender == "both"){
		idx1 <- which(!(fittable[,2] %in% c(femalecancers, malecancers)))
		idx2 <- NULL
	}
	Site <- fittable[c(idx1, idx2),2];
	alpha <- exp(as.numeric(fittable[c(idx1, idx2),3]));
	beta <- as.numeric(fittable[c(idx1, idx2),4])/1000;
	mm <- as.numeric(fittable[c(idx1, idx2),5]);
	kk <- mm+1;
	RSSw <- as.numeric(fittable[c(idx1, idx2),  which(colnames(fittable)=="sigma")]);
	peakageSEER <-  as.numeric(fittable[c(idx1, idx2),which(colnames(fittable)=="peakageseer")]);
	peakrateSEER <- as.numeric(fittable[c(idx1, idx2), which(colnames(fittable)=="peakrateseer")]);

	probSEER <- as.numeric(fittable[c(idx1, idx2), which(colnames(fittable)=="probSEER")]);

	peakageFit <- mm/((mm+1)*beta);
	peakrateFit <- rep(NA, length(peakageFit))
	for (jj in 1:length(peakageFit)){
    	peakrateFit[jj] <- hmodel(as.vector(as.numeric(c(fittable[c(idx1, idx2)[jj],3], fittable[c(idx1, idx2)[jj],4], fittable[c(idx1, idx2)[jj],5]))), peakageFit[jj])
	}
	# IMPORTANT!!: Correct age for sex-cancers, translating up 15 years
	sexIdx <- Site %in% c(femalecancers, malecancers)
	if (length(sexIdx) > 0){
		peakageFit[sexIdx] <- peakageFit[sexIdx] + 15;
	}
	newtable <- data.frame(Site, alpha, kk, beta, RSSw, peakrateFit, peakrateSEER, peakageFit, peakageSEER);

	newtable$probFit <- newtable$alpha/((newtable$beta)^newtable$kk)*(1/newtable$kk - 1/(newtable$kk+1))
	newtable$probSEER <- probSEER;

	return(newtable) 

}

### FIT DATA ##################################################################

newdata <- sumcounts;

cancertypes <- unique(sort(newdata$Site));
selected <- cancertypes;

for (ii in c(50)){

	ageToStartFit = ii

	set.seed(910);

	# males
	malehfits <- NULL;
	for (idx in 1:length(selected)){
		whichCancer <- selected[idx];
		if (!(whichCancer %in% femalecancers)){
			if (whichCancer %in% c("Testis", "TGCT")){
				result <- as.vector(weighedFit(newdata, whichCancer, sex="Male", ages, 20))
			} else {
				result <- as.vector(weighedFit(newdata, whichCancer, sex="Male", ages, ageToStartFit))
			}
			peakrate <- getpeakrate(newdata, whichCancer, sex='male', ages)
			temp <- c("male", whichCancer, result, peakrate)
			malehfits <- rbind(malehfits, temp);
			rownames(malehfits) = 1:nrow(malehfits);
		}
	}

	set.seed(910);
	# females
	femalehfits <- NULL;
	for (idx in 1:length(selected)){
		whichCancer <- selected[idx];
		if (!(whichCancer %in% malecancers)){
			if (whichCancer %in% c("Thyroid", "Cervix Uteri", "THCA", "CESC")){
				result <- as.vector(weighedFit(newdata, whichCancer, sex="Female", ages, 30))
			} else {
				result <- as.vector(weighedFit(newdata, whichCancer, sex="Female", ages, ageToStartFit))
			}	
			peakrate <- getpeakrate(newdata, whichCancer, sex='female', ages)
			temp <- c("female", whichCancer, result, peakrate)
			femalehfits <- rbind(femalehfits, temp);
			rownames(femalehfits) = 1:nrow(femalehfits);
		}
	}

	set.seed(910);
	# both
	bothhfits <- NULL;
	for (idx in 1:length(selected)){
		whichCancer <- selected[idx];
		if (!(whichCancer %in% c(malecancers, femalecancers))){
			result <- as.vector(weighedFit(newdata, whichCancer, sex="Both", ages, ageToStartFit))
			peakrate <- getpeakrate(newdata, whichCancer, sex='both', ages)
			temp <- c("both", whichCancer, result, peakrate)
			bothhfits <- rbind(bothhfits, temp);
			rownames(bothhfits) = 1:nrow(bothhfits);
		}
	}

	allhfits <- rbind(femalehfits, malehfits, bothhfits);
	colnames(allhfits) <-  c("sex", "cancertype", "logaa", "bb", "mm",
		"logaaStdErr", "bbStdErr", "mmStdErr", 
		"logaaPval", "bbPval", "mmPval", 
		"sigma", "numIter", "probSEER", "peakrateseer", "peakrangeseer", "peakageseer");


	colnames(femalehfits) <- colnames(allhfits);
	colnames(malehfits) <- colnames(allhfits);
	colnames(bothhfits) <- colnames(allhfits);

	### REWRITE NICELY TO MATCH PW ################################################


	malehfitsnice <- makenicetable(malehfits, "male") 
	femalehfitsnice <- makenicetable(femalehfits, "female")
	bothhfitsnice <- makenicetable(bothhfits, "both")


	### SAVE TO FILE ##############################################################

	write.table(allhfits,
		file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-Harding.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)


	write.table(malehfitsnice,
		file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr,  "-", ageToStartFit, "-Harding-male.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	write.table(femalehfitsnice,
		file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr,  "-", ageToStartFit, "-Harding-female.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	write.table(bothhfitsnice,
		file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr,  "-", ageToStartFit, "-Harding-both.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	save(allhfits, femalehfitsnice, malehfitsnice, bothhfitsnice,  file=file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit,  "-Harding.RData")));

}

save.image(file=file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit,  "-Harding-all.RData")));