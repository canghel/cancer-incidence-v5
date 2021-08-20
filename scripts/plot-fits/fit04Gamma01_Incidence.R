### PREAMBLE ##################################################################

library(dplyr)
library(tidyr)
library(scales)

library(futile.logger)
flog.threshold(DEBUG)

### LOAD DATA #################################################################

load(file.path(outputPath, fileOfResults));

firstyr <- strsplit(fileOfResults, '-')[[1]][4]
lastyr <- strsplit(fileOfResults, '-')[[1]][5]
ageToStartFit <- as.numeric(strsplit(fileOfResults, '-')[[1]][6])

femalecolor <- "red3" # "#D73027"
malecolor <- "dodgerblue4" #"#4575B4" 
bothcolor <- "black"

### FITTING FUNCTIONS #########################################################

gmodel <- function(coefs, tt){
	uu <- coefs[1]/100 # coef = uu*100
	bb <- coefs[2]/1000 # coef  = beta*1000 
	mm <- coefs[3] # mm = k-1
	out <- uu^(mm+1)/gamma(mm+1)*(tt^mm)*(1-bb*tt)*100000;
}

### PLOT OF FITTED CURVES #####################################################

makeplot <- function(alldata, ages, cancertype, fitdata, ageStart){
	male <- filter(alldata, Site  == cancertype & Sex=="Male");
	female <- filter(alldata, Site  == cancertype & Sex=="Female");
  
	male <- arrange(male, Age)
	female <- arrange(female, Age)
	
	subdata <- data.frame(
		age = male$Age,
		male = male[,"CrudeRate"],
		malemin = male[, "minb"],
		malemax = male[, "maxb"],
		female = female[,"CrudeRate"],
		femalemin = female[, "minb"],
		femalemax = female[, "maxb"]
	)

	maleparams <- as.numeric(fitdata[which(fitdata[,2] == cancertype & fitdata[,1] == "male"), 3:12])
	femaleparams <- as.numeric(fitdata[which(fitdata[,2] == cancertype & fitdata[,1] == "female"), 3:12])

	if (!(cancertype %in% c(femalecancers, malecancers))){
		tt = 1:115;
		malefitvals <- gmodel(unlist(maleparams), tt)
		femalefitvals <- gmodel(unlist(femaleparams), tt)
	}
	if (cancertype %in% c(femalecancers, malecancers)){
		tt = 15:115;
		malefitvals <- gmodel(unlist(maleparams), tt-15)
		femalefitvals <- gmodel(unlist(femaleparams), tt-15)
	}

	maxyval <- max(c(subdata$male, subdata$female, malefitvals, femalefitvals));
	if (is.na(maxyval)){
		maxyval <- max(c(subdata$male, subdata$female))
	}

	png(file.path(outputPath, paste0(Sys.Date(), "-Gamma-", cancertype,"-", firstyr, "-", lastyr, "-", ageStart, ".png")),
		height = 4,
		width = 4,
		units = 'in',
		res = 300,
		pointsize = 8
		);
	if (!(cancertype %in% femalecancers)){
		plot(ages, subdata$male, ylim=c(0, ceiling(maxyval)+1), pch = 15, ylab='', xlab='age');
	} else {
		plot(ages, subdata$female, ylim=c(0, ceiling(maxyval)+1), ylab='', xlab='age', pch = 17, col=femalecolor);
	}
	if (!(cancertype %in% femalecancers)){
		lines(tt, malefitvals, lty=1, col=malecolor)
		arrows(ages, subdata$malemin, ages, subdata$malemax, length=0.05, angle=90, code=3, col="gray")
		points(ages, subdata$male, pch = 15, col=malecolor);
	}
	if (!(cancertype %in% malecancers)){
		lines(tt, femalefitvals, lty=2, col=femalecolor)
		arrows(ages, subdata$femalemin, ages, subdata$femalemax, length=0.05, angle=90, code=3, col="gray")
		points(ages, subdata$female, pch = 17, col=femalecolor);
	}
	if (cancertype %in% femalecancers){
		femaletextpos <- 5;
	} else {
		maletextpos <- 5;
		femaletextpos <- 30
	}

	if (!(cancertype %in% femalecancers)){
		text(maletextpos, 0.87*maxyval, paste('u =', round(maleparams[1]/100,4)), col=malecolor, pos=4) 
		text(maletextpos, 0.8*maxyval, substitute(beta == b, list(b = round((maleparams[2]/1000),6))), col=malecolor, pos=4)
		text(maletextpos, 0.73*maxyval, paste('k = ', (round(maleparams[3],4)+1)), col=malecolor, pos=4) 
	}
	if (!(cancertype %in% malecancers)){
		text(femaletextpos, 0.87*maxyval, paste('u =', round(femaleparams[1]/100,4)), col=femalecolor, pos=4);
		text(femaletextpos, 0.8*maxyval, substitute(beta == b, list(b =  round((femaleparams[2]/1000),6))), col=femalecolor, pos=4);
		text(femaletextpos, 0.73*maxyval, paste('k = ', (round(femaleparams[3],4)+1)), col=femalecolor, pos=4) 
	}
	dev.off();
}


### PLOT OF BOTH MALE AND FEMALE ##############################################

makeplotboth <- function(alldata, ages, cancertype, fitdata, ageStart){
	both <- filter(alldata, Site  == cancertype & Sex=="Both");
	
	subdata <- data.frame(
		age = both$Age,
		both = both[,"CrudeRate"],
		bothmin = both[, "minb"],
		bothmax = both[, "maxb"]
	)

	bothparams <- as.numeric(fitdata[which(fitdata[,2] == cancertype & fitdata[,1] == "both"), 3:12])

	tt = 1:115;
	bothfitvals <- gmodel(unlist(bothparams), tt)


	maxyval <- max(c(subdata$both, bothfitvals));
	if (is.na(maxyval)){
		maxyval <- max(c(subdata$both))
	}

	png(file.path(outputPath, paste0(Sys.Date(), "-Gamma-", cancertype,"-", firstyr, "-", lastyr, "-", ageStart, "-both.png")),
		height = 4,
		width = 4,
		units = 'in',
		res = 300,
		pointsize = 8
		);
	plot(ages, subdata$both, ylim=c(0, ceiling(maxyval)+1), pch = 1, ylab='', xlab='age', col=bothcolor);
	lines(tt, bothfitvals, lty=1, col=bothcolor)
	arrows(ages, subdata$bothmin, ages, subdata$bothmax, length=0.05, angle=90, code=3, col="gray")
	points(ages, subdata$both, pch = 1, col=bothcolor);

	text(5, 0.87*maxyval, paste('u =', round(bothparams[1]/100,4)), col=bothcolor, pos=4) 
	text(5, 0.8*maxyval, substitute(beta == b, list(b = round((bothparams[2]/1000),6))), col=bothcolor, pos=4)
	text(5, 0.73*maxyval, paste('k = ', (round(bothparams[3],4)+1)), col=bothcolor, pos=4) 

	dev.off();
}


### MAKE CANCER INCIDENCE PLOTS #############################################################

# for males and females
for (idx in 1:length(selected)){
	whichCancer <- selected[idx];
	makeplot(newdata, ages, whichCancer, allgfits, ageToStartFit)
}

# for all population
for (idx in 1:length(selected)){
	whichCancer <- selected[idx];
	if (!(whichCancer %in% c(malecancers, femalecancers))){
		makeplotboth(newdata, ages, whichCancer, allgfits, ageToStartFit)
	}
}
