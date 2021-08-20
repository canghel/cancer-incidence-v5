### PREAMBLE ####################################################################

# libraries
library(dplyr)
library(tidyr)
library(futile.logger)
flog.threshold(DEBUG)

firstyr <- strsplit(fileToLoad, '-')[[1]][4]
lastyr <- strsplit(fileToLoad, '-')[[1]][5]


### FUNCTIONS #################################################################


pwmodel <- function(coefs, tt){
	aa <- coefs[1]/1000 # coef[1] = alpha*1000 and aa = alpha
	bb <- coefs[2]/1000 # coef[2] = beta*1000 and bb = beta
	mm <- coefs[3] # mm = k-1
	out <- (aa*tt)^mm*(1-bb*tt)*100000;
} 

ff <- function(coefs, tt, actual){
	pred <- pwmodel(coefs, tt);
	sseval <- (pred - actual)^2;
	# this is a constant, so could have omitted
	varval <- (actual - mean(actual))^2; 
	# if maximize 1 - sum(sseval)/sum(varval)
	# then minimizing sum(sseval)/sum(varval)
	out <- sum(sseval)/sum(varval);
	return(out);
}

gradff <- function(coefs, tt, actual){
	aa <- coefs[1]/1000 # coef = alpha*1000
	bb <- coefs[2]/1000 # coef = beta*1000
	mm <- coefs[3] # mm = k-1
	pred <- (aa*tt)^mm*(1-bb*tt)*100000;
	diff <- pred - actual;
	varval <- (actual - mean(actual))^2;
	# term in fromt of all of the derivatives
	# deriv of the scaled coefficient aa
	daa <- mm*aa^(mm-1)*(tt^mm)*(1-bb*tt)*100;
	daa <- sum(2*diff*daa)/sum(varval);
	# deriv of the scaled coefficient bb
	dbb <- (aa*tt)^mm*(-tt)*100;
	dbb <- sum(2*diff*dbb)/sum(varval);
	# deriv of mm
	dmm <- (aa*tt)^mm*log(aa*tt)*(1-bb*tt)*100000
	dmm <- sum(2*diff*dmm)/sum(varval);
	out <- c(daa, dbb, dmm);
	return(out);
}

fitdata <- function(alldata, ages, cancertype, sex, initialval){
	male <- filter(alldata, Site == cancertype &  Sex =="Male"); 
	female <- filter(alldata, Site == cancertype & Sex =="Female");
	both <- filter(alldata, Site == cancertype & Sex =="Both");

	male <- arrange(male, Age)
	female <- arrange(female, Age)
	both <- arrange(both, Age)
	
	subdata <- data.frame(
		tt = ages,
		male = male[,"CrudeRate"],
		female = female[,"CrudeRate"],
		both = both[,"CrudeRate"]
		) 

	# for testis, need to exclude largest ages to be able to fit peak
	if (cancertype %in% c("Testis", 'TGCT')){
		idx <- which(subdata$tt < 55)
		subdata <- subdata[idx, ];
	}

	if (cancertype %in% c(femalecancers, malecancers)){
		subdata <- subdata[which(subdata$tt > 15),]
		subdata$tt <- subdata$tt - 15;
	}

	if (sex=='male'){
		fitmodel <- optim(initialval, fn=ff, gr = gradff, 
			tt = subdata$tt, actual = subdata$male,
			method = "BFGS", 
			control = list(trace=TRUE, maxit=10000, reltol=1e-10)
		);     
	}
	if (sex=='female'){
		fitmodel <- optim(initialval, fn=ff, gr = gradff, 
			tt = subdata$tt, actual = subdata$female,
			method = "BFGS", 
			control = list(trace=TRUE, maxit=10000, reltol=1e-10)
		);    
	}
	if (sex=='both'){
		fitmodel <- optim(initialval, fn=ff, gr = gradff, 
			tt = subdata$tt, actual = subdata$both,
			method = "BFGS", 
			control = list(trace=TRUE, maxit=10000, reltol=1e-10)
		);    
	}

	return(fitmodel);
}

fitmany <- function(alldata, ages, cancertype, sex, initialSeed, numToFit){
	set.seed(initialSeed);
	initialvals <- abs(cbind(rnorm(numToFit, mean=4, sd=2), rnorm(numToFit, mean=1, sd=2), rnorm(numToFit, mean=4, sd=2)));
	allfits <- list(); 
	for(jj in 1:numToFit){
		allfits[[jj]] <- fitdata(alldata, ages, cancertype, sex, initialvals[jj,])
	}
	return(allfits)
}

getbest <- function(allfits){
	errvals <- unlist(lapply(allfits, '[[', 2));
	bestresult <- allfits[[which.min(errvals)]];
	output <- c(bestresult$par, bestresult$value, as.vector(bestresult$counts), bestresult$convergence);
	return(output);
}

getbestofmany <- function(alldata, ages, cancertype, sex, initialSeed, numToFit){
	allfits <- fitmany(alldata, ages, cancertype, sex, initialSeed, numToFit)
	best <- getbest(allfits);
	return(best);
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

# males
malefits <- NULL;
for (idx in 1:length(selected)){
	whichCancer <- selected[idx];
	if (!(whichCancer %in% femalecancers)){
		result <- getbestofmany(newdata, ages, whichCancer, sex='male', idx, 30)
		peakrate <- getpeakrate(newdata, whichCancer, sex='male', ages)
		temp <- c("male", whichCancer, result, peakrate);
		malefits <- rbind(malefits, temp);
		rownames(malefits) = 1:nrow(malefits);
	}
}

# female fits
femalefits <- NULL;
for (idx in 1:length(selected)){
	whichCancer <- selected[idx];
	if (!(whichCancer %in% malecancers)){
		result <- getbestofmany(newdata, ages, whichCancer, sex='female', idx, 30)
		peakrate <- getpeakrate(newdata, whichCancer, sex='female', ages)
		temp <- c("female", whichCancer, result, peakrate)
		femalefits <- rbind(femalefits , temp);
		rownames(femalefits) = 1:nrow(femalefits);
	}
}

# both fits
bothfits <- NULL;
for (idx in 1:length(selected)){
	whichCancer <- selected[idx];
	if (!(whichCancer %in% c(femalecancers, malecancers))){
		result <- getbestofmany(newdata, ages, whichCancer, sex='both', idx, 30)
		peakrate <- getpeakrate(newdata, whichCancer, sex='both', ages)
		temp <- c("both", whichCancer, result, peakrate)
		bothfits <- rbind(bothfits , temp);
		rownames(bothfits) = 1:nrow(bothfits);
	}
}

allfits <- rbind(femalefits, malefits, bothfits);
colnames(allfits) <- c("sex", "cancertype", "aa", "bb", "mm", "value", 
	"cfun", "cgr", "conv", "peakrateseer", "peakrangeseer", "peakageseer");


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
	Fit <- 1- as.numeric(fittable[c(idx1, idx2),6]);
	peakageSEER <-  as.numeric(fittable[c(idx1, idx2),12]);
	peakrateSEER <- as.numeric(fittable[c(idx1, idx2),10]);

	peakageFit <- mm/((mm+1)*betax100/100);
	peakrateFit <- rep(NA, length(peakageFit))
	for (jj in 1:length(peakageFit)){
    	peakrateFit[jj] <- pwmodel(as.vector(as.numeric(c(fittable[c(idx1, idx2)[jj],3], fittable[c(idx1, idx2)[jj],4], fittable[c(idx1, idx2)[jj],5]))), peakageFit[jj])
	}
	newtable <- data.frame(Site, alphax100, mm, betax100, Fit, peakrateFit, peakrateSEER, peakageFit, peakageSEER);

} 

malefitsnice <- makenicetable(malefits, "male")
femalefitsnice <- makenicetable(femalefits, "female")
bothfitsnice <- makenicetable(bothfits, "both")

### WRITE TO FILE #############################################################

write.table(allfits,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-Pompei-Wilson.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

write.table(malefitsnice,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-Pompei-Wilson-male.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

write.table(femalefitsnice,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-Pompei-Wilson-female.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

write.table(bothfitsnice,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-Pompei-Wilson-both.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

save(allfits, malefitsnice, femalefitsnice, bothfitsnice,
	file=file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-Pompei-Wilson.RData")));

save.image(file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-Pompei-Wilson-all.RData")));