### SAME AS HARDING BUT A GAMMA FUNCTION ########################################

### PREAMBLE ####################################################################

library(dplyr)
library(tidyr)
library(minpack.lm)

library(futile.logger)
flog.threshold(DEBUG)

firstyr <- strsplit(fileToLoadErrs, '-')[[1]][4]
lastyr <- strsplit(fileToLoadErrs, '-')[[1]][5]

### FUNCTION & GRADIENTS ######################################################

gmodel <- function(coefs, tt){
	uu <- coefs[1]/100 # coef = uu*100
	bb <- coefs[2]/1000 # coef  = beta*1000 
	mm <- coefs[3] # mm = k-1
	out <- uu^(mm+1)/gamma(mm+1)*(tt^mm)*(1-bb*tt)*100000;
}


### FUNCTIONS: FITTING ########################################################


weighedFit <- function(alldata, cancertype, sex, ages, ageThresh){

	df <- filter(alldata, Site == cancertype &  Sex ==sex); 
	df <- arrange(df, Age)

	probSEER <- sum(df$CrudeRate[df$Age<=100]*5)/100000

	### Originally used the initial values from previous Harding fit
	#intdf <- data.frame(bothhfits, stringsAsFactors=FALSE);
	#intdf <- bothhfits[which(intdf$cancertype == cancertype & intdf$sex == tolower(sex)),]

	#aainit = as.numeric(intdf["aa"])
	#bbinit = as.numeric(intdf["bb"])
	#mminit = as.numeric(intdf["mm"])
	#uuinit = (exp(aainit)*gamma(mminit+1))^(1/(mminit+1))*100;

	# Use these are initial values for all cases to avoid needing the previous
	# Harding fit, as gives same results
	uuinit <- 2
	bbinit <- 9
	mminit <- 4

	# set up the data and weights ----------------------------------------------
	subsetdata <- data.frame(
		xx = ages,
		yy = df$CrudeRate
		);
	# should be proportional to inverse of variance
	# maxb-minb is about 2 standard deviations
	weights <- 1/((df$maxb - df$minb)/2)^2

	# threshold to fits only past a given age ----------------------------------
	# did not test this?
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
		# since looking for those greater than 50, all indices are
		# automatically greater than 15
		# but doesn't hurt to do it this way
		idx <- which(subsetdata$xx > 15)
		subsetdata <- subsetdata[idx,]
		subsetdata$xx <- subsetdata$xx - 15;
		weights <- weights[idx]
	}

	# try to fit, else return NA's ---------------------------------------------
	out <- tryCatch({
		fit <- nlsLM(yy ~ (uu/100)^(mm+1)/gamma(mm+1)*(xx^mm)*(1-bb/1000*xx)*100000,
			data = subsetdata,
			weights = weights,
			start = list(uu=uuinit, bb=bbinit, mm = mminit),
			control = list(maxiter = 1000, warnOnly=TRUE)
			);
		#browser();
		answer <- c(unlist(coef(fit)), summary(fit)$parameters["uu",2], 
			summary(fit)$parameters["bb",2], summary(fit)$parameters["mm",2],
			summary(fit)$parameters["uu",4], 
			summary(fit)$parameters["bb",4], summary(fit)$parameters["mm",4],
			summary(fit)$sigma, fit$convInfo$isConv, probSEER) # fit$convInfo$isConv or fit$convInfo$finIter
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

getpeakexpfit <- function(cc, dd, fitsnice, betaVal){
	beta <- betaVal;
 	tt <- (fitsnice$kk-1)/(fitsnice$kk*beta)
 	# for genered cancers, tt will be shifted by 15
 	out <- (cc*fitsnice$kk + dd)^fitsnice$kk/gamma(fitsnice$kk)*tt^(fitsnice$kk-1)*(1-beta*tt)*100000;
}

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
	uu <- as.numeric(fittable[c(idx1, idx2),3])/100
	beta <- as.numeric(fittable[c(idx1, idx2),4])/1000;
	mm <- as.numeric(fittable[c(idx1, idx2),5]);
	kk <- mm+1;
	RSSw <- as.numeric(fittable[c(idx1, idx2), which(colnames(fittable)=="sigma")]);
	peakageSEER <-  as.numeric(fittable[c(idx1, idx2), which(colnames(fittable)=="peakageseer")]);
	peakrateSEER <- as.numeric(fittable[c(idx1, idx2), which(colnames(fittable)=="peakrateseer")]);
	uuPval  <- as.numeric(fittable[c(idx1, idx2), which(colnames(fittable)=="uuPval")]);
	kkPval <- as.numeric(fittable[c(idx1, idx2), which(colnames(fittable)=="mmPval")]);
	betaPval  <- as.numeric(fittable[c(idx1, idx2), which(colnames(fittable)=="bbPval")]);

	probSEER <- as.numeric(fittable[c(idx1, idx2), which(colnames(fittable)=="probSEER")]);

	peakageFit <- mm/((mm+1)*beta);
	peakrateFit <- rep(NA, length(peakageFit))
	for (jj in 1:length(peakageFit)){
    	peakrateFit[jj] <- gmodel(as.vector(as.numeric(c(fittable[c(idx1, idx2)[jj],3], fittable[c(idx1, idx2)[jj],4], fittable[c(idx1, idx2)[jj],5]))), peakageFit[jj])
	}

	# IMPORTANT!!: Correct age for sex-cancers, translating up 15 years
	sexIdx <- Site %in% c(femalecancers, malecancers)
	if (length(sexIdx) > 0){
		peakageFit[sexIdx] <- peakageFit[sexIdx] + 15;
	}

	newtable <- data.frame(Site, uu, kk, beta, uuPval, kkPval, betaPval, peakrateSEER, peakrateFit, peakageSEER, peakageFit);

	newtable$probSEER <- probSEER;
	newtable$probFit <- (newtable$uu)^newtable$kk/((newtable$beta)^newtable$kk*gamma(newtable$kk))*(1/newtable$kk - 1/(newtable$kk+1))
	
	return(newtable)
}

### FIT EVERYTHING ###########################################################

newdata <- sumcounts;

cancertypes <- unique(sort(newdata$Site));
selected <- cancertypes;

for (ii in c(50)){

	ageToStartFit = ii

	set.seed(910);

	# males
	malegfits <- NULL;
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
			malegfits <- rbind(malegfits, temp);
			rownames(malegfits) = 1:nrow(malegfits);
		}
	}

	set.seed(910);
	# females
	femalegfits <- NULL;
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
			femalegfits <- rbind(femalegfits, temp);
			rownames(femalegfits) = 1:nrow(femalegfits);
		}
	}

	set.seed(910);
	# both
	bothgfits <- NULL;
	for (idx in 1:length(selected)){
		whichCancer <- selected[idx];
		if (!(whichCancer %in% c(malecancers, femalecancers))){
			result <- as.vector(weighedFit(newdata, whichCancer, sex="Both", ages, ageToStartFit))
			peakrate <- getpeakrate(newdata, whichCancer, sex='both', ages)
			temp <- c("both", whichCancer, result, peakrate)
			bothgfits <- rbind(bothgfits, temp);
			rownames(bothgfits) = 1:nrow(bothgfits);
		}
	}

	allgfits <- rbind(femalegfits, malegfits, bothgfits);
	colnames(allgfits) <-  c("sex", "cancertype", "uux100", "bbx1000", "mm", 
		"uux100StdErr", "bbx1000StdErr", "mmStdErr", 
		"uuPval", "bbPval", "mmPval", 
		"sigma", "isConv",  "probSEER", "peakrateseer", "peakrangeseer", "peakageseer");

	colnames(femalegfits) <- colnames(allgfits);
	colnames(malegfits) <- colnames(allgfits);
	colnames(bothgfits) <- colnames(allgfits);


	### REWRITE NICELY TO MATCH PW ################################################


	malegfitsnice <- makenicetable(malegfits, "male")
	femalegfitsnice <- makenicetable(femalegfits, "female")
	bothgfitsnice <- makenicetable(bothgfits, "both")


	### SAVE TO FILE ##############################################################

	write.table(allgfits,
		file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-Gamma.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)


	write.table(malegfitsnice,
		file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr,  "-", ageToStartFit, "-Gamma-male.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	write.table(femalegfitsnice,
		file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr,  "-", ageToStartFit, "-Gamma-female.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	write.table(bothgfitsnice,
		file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr,  "-", ageToStartFit, "-Gamma-both.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	### CREATE FORMATTED TABLE FOR MANUSCRIPT #################################

	temp1 <- data.frame(sex=rep("male"), malegfitsnice)
	temp2 <- data.frame(sex=rep("female"), femalegfitsnice)
	temp3 <- data.frame(sex=rep("both"), bothgfitsnice)
	allnice <- rbind(temp1, temp2, temp3)
	rm(temp1, temp2, temp3)

	# https://stackoverflow.com/questions/3245862/format-numbers-to-significant-figures-nicely-in-r
	temp_formatted <- allnice;
	temp_formatted$uu <- formatC(signif(temp_formatted$uu, digits=2), digits=2, flag="#")
	temp_formatted$kk <- round(temp_formatted$kk, digits=2)
	temp_formatted$beta <- round(temp_formatted$beta, digits=4)
	temp_formatted$uuPval <- formatC(signif(temp_formatted$uuPval, digits=2), digits=1, format="E")#, flag="#")
	temp_formatted$kkPval <- formatC(signif(temp_formatted$kkPval, digits=2), digits=1, format="E")#, flag="#")
	temp_formatted$betaPval <- formatC(signif(temp_formatted$betaPval, digits=2), digits=1, format="E")#, flag="#")
	temp_formatted$peakrateSEER <- formatC(signif(temp_formatted$peakrateSEER, digits=3), digits=3,format="fg", flag="#")
	temp_formatted$peakrateFit <- formatC(signif(temp_formatted$peakrateFit, digits=3), digits=3,format="fg", flag="#")
	temp_formatted$peakageFit <- formatC(signif(temp_formatted$peakageFit, digits=3), digits=3,format="fg", flag="#")
	temp_formatted$probSEER <- formatC(signif(temp_formatted$probSEER, digits=2), digits=2, flag="#")
	temp_formatted$probFit <- formatC(signif(temp_formatted$probFit, digits=2), digits=2, flag="#")
	allniceFormatted <- temp_formatted;
	rm(temp_formatted)


	write.table(allnice ,
		file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-Gamma-table.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	write.table(allniceFormatted,
		file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-Gamma-table-formatted.csv")),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
		)

	save(allgfits, file=file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit,  "-Gamma.RData")));

}

save.image(file=file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit,  "-Gamma-all.RData")));