### FT POMPEI-WILSON, BUT THE FIT TO BE WEIGHTED BY THE ERROR AT EACH POINT #####

### PREAMBLE ####################################################################

library(dplyr)
library(tidyr)
library(minpack.lm)

library(futile.logger)
flog.threshold(DEBUG)

### LOAD DATA #################################################################

firstyr <- strsplit(fileToLoadErrs, '-')[[1]][4]
lastyr <- strsplit(fileToLoadErrs, '-')[[1]][5]

### FUNCTION & GRADIENTS ######################################################


pwmodel <- function(coefs, tt){
	aa <- coefs[1]/1000 # coef[1] = alpha*1000 and aa = alpha
	bb <- coefs[2]/1000 # coef[2] = beta*1000 and bb = beta
	mm <- coefs[3] # mm = k-1
	out <- (aa*tt)^mm*(1-bb*tt)*100000;
} 


### FUNCTIONS: FITTING ########################################################

weighedFit <- function(alldata, prevfits, cancertype, sex, ages, ageThresh){

	df <- filter(alldata, Site == cancertype &  Sex ==sex); 
	df <- arrange(df, Age)

	intdf <- data.frame(allfits, stringsAsFactors=FALSE);
	intdf <- allfits[which(intdf$cancertype == cancertype & intdf$sex == tolower(sex)),]

	aainit = as.numeric(intdf["aa"])
	bbinit = as.numeric(intdf["bb"])
	mminit = as.numeric(intdf["mm"])

	if (any(is.na(c(aainit, bbinit, mminit))) | (bbinit < 0)){
		aainit <- 3
		bbinit <- 9
		mminit <- 4
	}

	# set up the data and weights ----------------------------------------------
	subsetdata <- data.frame(
		xx = ages,
		yy = df$CrudeRate
		);
	# this might be wrong...
	weights <- 1/((df$maxb - df$minb)/2)^2

	# threshold to fits only past a given age ----------------------------------
	idx <- which(subsetdata$xx > ageThresh)
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
		fit <- nlsLM(yy ~ (aa/1000*xx)^mm*(1-bb/1000*xx)*100000,
			data = subsetdata,
			weights = weights,
			start = list(aa=aainit, bb=bbinit, mm = mminit),
			control = list(maxiter = 1000, warnOnly=TRUE)
			);
		answer <- c(unlist(coef(fit)), summary(fit)$parameters["aa",2], summary(fit)$parameters["bb",2], summary(fit)$parameters["mm",2],
			summary(fit)$parameters["aa",4], summary(fit)$parameters["bb",4], summary(fit)$parameters["mm",4],
			summary(fit)$sigma)
	}, error = function(err){
		answer <- rep(NA, 10)
	})

	return(out)
}

getpeakrate <- function(alldata, cancertype, sex, ages){
	sexString <- paste0(toupper(substr(sex,1,1)), substring(sex, 2))
	datasubset <- filter(alldata, Site == cancertype & Sex == sexString);
	maxidx <- which.max(datasubset$CrudeRate);
	out <- c(datasubset$CrudeRate[maxidx], datasubset$Age[maxidx], ages[maxidx]);
	return(out);
}


### FIT DATA ##################################################################

newdata <- sumcounts;

cancertypes <- unique(sort(newdata$Site));
selected <- cancertypes;


for (ii in c(50)){

	ageToStartFit = ii

	set.seed(910);

	# males
	malewfits <- NULL;
	for (idx in 1:length(selected)){
		whichCancer <- selected[idx];
		if (!(whichCancer %in% femalecancers)){
			if (whichCancer %in% c("Testis", "TGCT")){
				result <- as.vector(weighedFit(newdata, allfits, whichCancer, sex="Male", ages, 20))
			} else {
				result <- as.vector(weighedFit(newdata, allfits, whichCancer, sex="Male", ages, ageToStartFit))
			}
			peakrate <- getpeakrate(newdata, whichCancer, sex='male', ages)
			temp <- c("male", whichCancer, result, peakrate)
			malewfits <- rbind(malewfits, temp);
			rownames(malewfits) = 1:nrow(malewfits);
		}
	}

	set.seed(910);
	# females
	femalewfits <- NULL;
	for (idx in 1:length(selected)){
		whichCancer <- selected[idx];
		if (!(whichCancer %in% malecancers)){
			if (whichCancer %in% c("Thyroid", "Cervix Uteri", "THCA", "CESC")){
				result <- as.vector(weighedFit(newdata, allfits, whichCancer, sex="Female", ages, 30))
			} else {
				result <- as.vector(weighedFit(newdata, allfits, whichCancer, sex="Female", ages, ageToStartFit))
			}	
			peakrate <- getpeakrate(newdata, whichCancer, sex='female', ages)
			temp <- c("female", whichCancer, result, peakrate)
			femalewfits <- rbind(femalewfits, temp);
			rownames(femalewfits) = 1:nrow(femalewfits);
		}
	}

	set.seed(910);
	# both
	bothwfits <- NULL;
	for (idx in 1:length(selected)){
		whichCancer <- selected[idx];
		if (!(whichCancer %in% c(malecancers, femalecancers))){
			result <- as.vector(weighedFit(newdata, allfits, whichCancer, sex="Both", ages, ageToStartFit))
			peakrate <- getpeakrate(newdata, whichCancer, sex='both', ages)
			temp <- c("both", whichCancer, result, peakrate)
			bothwfits <- rbind(bothwfits, temp);
			rownames(bothwfits) = 1:nrow(bothwfits);
		}
	}


}

allwfits <- rbind(femalewfits, malewfits, bothwfits);
colnames(allwfits) <- c("sex", "cancertype", "aa", "bb", "mm",
		"aaStdErr", "bbStdErr", "mmStdErr", 
		"aaPval", "bbPval", "mmPval", 
		"sigma", "peakrateseer", "peakrangeseer", "peakageseer");

### REWRITE NICELY TO MATCH PW ################################################

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
	alphax100 <- as.numeric(fittable[c(idx1, idx2),3])/10;
	betax100 <- as.numeric(fittable[c(idx1, idx2),4])/10;
	mm <- as.numeric(fittable[c(idx1, idx2),5]);
	RSSw <- as.numeric(fittable[c(idx1, idx2),12]);
	peakageSEER <-  as.numeric(fittable[c(idx1, idx2),15]);
	peakrateSEER <- as.numeric(fittable[c(idx1, idx2),13]);

	peakageFit <- mm/((mm+1)*betax100/100);
	peakrateFit <- rep(NA, length(peakageFit))
	for (jj in 1:length(peakageFit)){
    	peakrateFit[jj] <- pwmodel(as.vector(as.numeric(c(fittable[c(idx1, idx2)[jj],3], fittable[c(idx1, idx2)[jj],4], fittable[c(idx1, idx2)[jj],5]))), peakageFit[jj])
	}
	newtable <- data.frame(Site, alphax100, mm, betax100, RSSw, peakrateFit, peakrateSEER, peakageFit, peakageSEER);

} 

malewfitsnice <- makenicetable(malewfits, "male")
femalewfitsnice <- makenicetable(femalewfits, "female")
bothwfitsnice <- makenicetable(bothwfits, "both")


### SAVE TO FILE ##############################################################

write.table(allwfits,
	file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-Pompei-Wilson-weighted.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)


write.table(malewfitsnice,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit, "-Pompei-Wilson-weighted-male.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

write.table(femalewfitsnice,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit, "-Pompei-Wilson-weighted-female.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

write.table(bothwfitsnice,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit, "-Pompei-Wilson-weighted-both.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

save(allwfits, file=file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit,  "-Pompei-Wilson-weighted.RData")));

save.image(file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit, "-Pompei-Wilson-weighted-all.RData")));