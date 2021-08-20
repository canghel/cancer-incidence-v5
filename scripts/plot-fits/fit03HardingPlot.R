# run after the Harding fits to plot
# additional plot of log a vs. k
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

EXCLUDED <- c("Hodgkin Lymphoma", "All Sites", "All Major Non Sex", "All Major", "COADREAD")#, "LGG")

### FITTING FUNCTIONS #######################################

hmodel <- function(coefs, tt){
	aa <- exp(coefs[1]) # coef = log(alpha)
	bb <- coefs[2]/1000 # coef  = beta*1000 
	mm <- coefs[3] # mm = k-1
	out <- aa*(tt^mm)*(1-bb*tt)*100000;
} 

model3terms <- function(coefs, cc, dd, tt){
	bb <- coefs[2]/1000 # coef  = beta*1000 
	mm <- coefs[3]
	kk <- mm + 1
	out <- cc*exp(dd*kk)*(tt^mm)*(1-bb*tt)*100000;
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
		malefitvals <- hmodel(unlist(maleparams), tt)
		femalefitvals <- hmodel(unlist(femaleparams), tt)
	}
	if (cancertype %in% c(femalecancers, malecancers)){
		tt = 15:115;
		malefitvals <- hmodel(unlist(maleparams), tt-15)
		femalefitvals <- hmodel(unlist(femaleparams), tt-15)
	}

	maxyval <- max(c(subdata$male[subdata$age < 108], subdata$female[subdata$age < 108], malefitvals, femalefitvals));
	if (is.na(maxyval)){
		maxyval <- max(c(subdata$male, subdata$female))
	}


	png(file.path(outputPath, paste0(Sys.Date(), "-H-", cancertype,"-", firstyr, "-", lastyr, "-", ageStart, ".png")),
		height = 4,
		width = 4,
		units = 'in',
		res = 300,
		pointsize = 9
		);
	#par(mar=c(1,1,1,1))
	if (!(cancertype %in% femalecancers)){
		# browser()
		plot(ages, subdata$male, ylim=c(0, ceiling(maxyval)+1), pch = 15, ylab='Incidence (Cases per 100,000)', xlab='Age (years)',  col=scales::alpha(malecolor, 0.6));
	} else {
		plot(ages, subdata$female, ylim=c(0, ceiling(maxyval)+1), ylab='Incidence (Cases per 100,000)', xlab='Age (years)', pch = 17, col=scales::alpha(femalecolor, 0.6));
	}
	if (!(cancertype %in% femalecancers)){
		lines(tt, malefitvals, lty=1, col=malecolor)
		arrows(ages, subdata$malemin, ages, subdata$malemax, length=0.05, angle=90, code=3, col="gray")
		points(ages, subdata$male, pch=15, col=scales::alpha(malecolor, 0.6));
	}
	if (!(cancertype %in% malecancers)){
		lines(tt, femalefitvals, lty=1, col=femalecolor)
		arrows(ages, subdata$femalemin, ages, subdata$femalemax, length=0.05, angle=90, code=3, col="gray")
		points(ages, subdata$female, pch = 17, col=scales::alpha(femalecolor, 0.6));
	}
	if (cancertype %in% femalecancers){
		femaletextpos <- 5;
	} else {
		maletextpos <- 5;
		femaletextpos <- 5; #30
	}

	if (!(cancertype %in% femalecancers)){
		text(maletextpos, 0.87*maxyval, substitute(alpha == a, list(a = format(exp(maleparams[1]), scientific = TRUE, digits=4))), col=malecolor, pos=4, cex=0.8) 
		text(maletextpos, 0.8*maxyval, substitute(beta == b, list(b = round((maleparams[2]/1000),5))), col=malecolor, pos=4, cex=0.8)
		text(maletextpos, 0.73*maxyval, paste('k = ', (round(maleparams[3],3)+1)), col=malecolor, pos=4, cex=0.8) 
	}
	if (!(cancertype %in% malecancers)){
		text(femaletextpos, 0.6*maxyval, substitute(alpha == a, list(a = format(exp(femaleparams[1]), scientific = TRUE, digits=4))), col=femalecolor, pos=4, cex=0.8);
		text(femaletextpos, 0.53*maxyval, substitute(beta == b, list(b =  round((femaleparams[2]/1000),5))), col=femalecolor, pos=4, cex=0.8);
		text(femaletextpos, 0.46*maxyval, paste('k = ', (round(femaleparams[3],3)+1)), col=femalecolor, pos=4, cex=0.8) 
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
	bothfitvals <- hmodel(unlist(bothparams), tt)

	maxyval <- max(c(subdata$both[subdata$age < 108], bothfitvals));
	if (is.na(maxyval)){
		maxyval <- max(c(subdata$both))
	}

	maxyvalplot <- ceiling(maxyval)+1;

	png(file.path(outputPath, paste0(Sys.Date(), "-H-", cancertype,"-", firstyr, "-", lastyr, "-", ageStart, "-both.png")),
		height = 4,
		width = 4,
		units = 'in',
		res = 300,
		pointsize = 9
		);
	plot(ages, subdata$both, ylim=c(0, maxyvalplot ), pch = 16,  ylab='Incidence (Cases per 100,000)', xlab='Age (years)', col=scales::alpha(bothcolor, 0.4), cex=1.2);
	lines(tt, bothfitvals, lty=1, col=bothcolor);
	arrows(ages, subdata$bothmin, ages, subdata$bothmax, length=0.05, angle=90, code=3, col="gray")
	points(ages, subdata$both, pch = 16,  col=scales::alpha(bothcolor, 0.4), cex=1.2);

	text(5, 0.87*maxyvalplot, substitute(alpha == a, list(a = format(exp(bothparams[1]), scientific = TRUE, digits=4))), col=bothcolor, pos=4, cex=0.8)  
	text(5, 0.8*maxyvalplot, substitute(beta == b, list(b = round((bothparams[2]/1000),5))), col=bothcolor, pos=4, cex=0.8) 
	text(5, 0.73*maxyvalplot, paste('k = ', (round(bothparams[3],3)+1)), col=bothcolor, pos=4, cex=0.8)  

	dev.off();
}


### LOG A VS K PLOT FUNCTION ##################################################

labelSize <- 2.3
axisSize <- 1.7
pointSize <- 2.4
textSize <- 2

makelogavskplot <- function(fittable, gender, colVal, pchVal, genderNonSex=FALSE){

	fittable <- data.frame(fittable, stringsAsFactors=FALSE)

	linecolour <- colVal;
	if (gender == "malefemale"){
		subtable <- fittable[which(fittable$sex %in% c("male", "female")),];
		subtable$pch <- ifelse(subtable$sex=="male", 15, 17);
		subtable$colour <- ifelse(subtable$sex=="male", malecolor, femalecolor);
		linecolour <- 'black'
	} else {
		subtable <- fittable[which(fittable$sex==gender),];
		subtable$pch <- rep(pchVal, nrow(subtable))
		subtable$colour <- rep(colVal, nrow(subtable))
	}

	if ((gender == "male") && genderNonSex){
		subtable <- subtable[which(!(subtable$cancertype %in% malecancers)),];
	}

	if ((gender == "female") && genderNonSex){
		subtable <- subtable[which(!(subtable$cancertype %in% femalecancers)),];
	}

	subtable[,3:(ncol(subtable)-1)] <- apply(subtable[,3:(ncol(subtable)-1)],2, as.numeric)
	subtable <- subtable[which(subtable$logaa < 0),];
	subtable$kk <- subtable$mm + 1


	print(str(subtable))

	badidx <- which(subtable$cancertype %in% EXCLUDED);
	if (length(badidx) > 0){
		subtable <- subtable[-badidx,]
	}
	lmfit <- lm(logaa ~ kk, data=subtable);

	xx <- seq(0.2, 12, 0.1)
	yy <- coef(lmfit)[2]*xx + coef(lmfit)[1];

	print(nrow(subtable))
	#browser();

	png(file.path(outputPath, paste0(Sys.Date(), "-log-a-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-", gender, "-", genderNonSex, ".png")),
		height = 4,
		width = 5,
		units = 'in',
		res = 400,
		pointsize = 6
		);
	par(mar=c(5.1, 5.1, 4.1, 2.1))
	plot(subtable$kk, 
		subtable$logaa, 
		xlab = "k",
		ylab = "ln a",
		pch = subtable$pch, 
		col = scales::alpha(subtable$colour, 0.6),
		xlim = c(0, 12),
		ylim = c(-55, 0),
		cex.lab = labelSize,
		cex.axis = axisSize,
		cex = pointSize
		)
	arrows(subtable$kk, subtable$logaa - subtable$logaaStdErr, subtable$kk, subtable$logaa + subtable$logaaStdErr, length=0.05, angle=90, code=3, col="gray")
	arrows(subtable$kk - subtable$mmStdErr, subtable$logaa, subtable$kk + subtable$mmStdErr, subtable$logaa, length=0.05, angle=90, code=3,  col="gray")
	lines(xx, yy, col=linecolour, lty=3)
	points(subtable$kk, 
	    subtable$logaa, 
	    pch = subtable$pch, 
	    col = scales::alpha(subtable$colour, 0.6),
	    cex = pointSize
	)
	text(5.8, -7, paste("ln a =", round(coef(lmfit)[2], digits=2), "k +", round(coef(lmfit)[1], digits=2)), pos=4, cex=textSize)
	text(5.8, -11, bquote(R^2 == .(round(summary(lmfit)$r.squared, 3))), pos=4, cex=textSize)
	text(5.8, -15, bquote(italic("P") == .(format(summary(lmfit)$coefficients[8], scientific = TRUE, digits=2))), pos=4, cex=textSize)
	# text(6.2, -11, substitute(AdjR^2 == a, list(a =round(summary(lmfit)$adj.r.squared, 3))), pos=4)
	dev.off()
	
	return(lmfit)
}

### MAKE AGE OF PEAK INCIDENCE VS K PLOT ######################################

# messy, need to redo...
makepeakagevskplot <- function(fittable, smalltable, gender, colVal, pchVal){
	fittable <- data.frame(fittable, stringsAsFactors=FALSE)
	subtable <- fittable[which(fittable$sex==gender),];
	subtable[,3:ncol(subtable)] <- apply(subtable[,3:ncol(subtable)],2, as.numeric)

	subtable$kk <- subtable$mm + 1

	smalltable <- smalltable[, c("Site", "peakrateFit", "peakageFit", "peakageSEER")];
	subtable <- merge(subtable, smalltable, by.x='cancertype', by.y='Site')
	badidx <- which(subtable$cancertype %in% EXCLUDED);
	if (length(badidx) > 0){
		subtable <- subtable[-badidx,]
	}

	lmfit <- lm(peakageFit ~ kk, data=subtable);
	corkkage <- cor.test(subtable$kk, subtable$peakageFit, use="complete.obs", method='spearman')
	print(gender)
	print(corkkage)

	xx <- seq(1, 10, 0.1)
	yy <- coef(lmfit)[2]*xx + coef(lmfit)[1];

	betaMean <- 0.01;

	png(file.path(outputPath, paste0(Sys.Date(), "-peak-age-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-", gender,".png")),
		height = 4,
		width = 5,
		units = 'in',
		res = 400,
		pointsize = 6
		);
	par(mar=c(5.1, 5.1, 4.1, 2.1))
	plot(subtable$kk, 
		subtable$peakageFit, 
		xlab = "k",
		ylab = "Age at peak incidence (Model)",
		pch = pchVal, 
		col = scales::alpha(colVal, 0.6),
		xlim = c(0, 10),
		ylim = c(12, 117),
		cex.lab = labelSize,
		cex.axis = axisSize,
		cex = pointSize
		)
	arrows(subtable$kk - subtable$mmStdErr, subtable$peakageFit, subtable$kk + subtable$mmStdErr, subtable$peakageFit, length=0.05, angle=90, code=3,  col="gray")
	# lines(xx, yy, col=colVal, lty=3)
	lines(xx, (xx-1)/(xx*betaMean), col=colVal, lty=5)
	points(subtable$kk, 
	    subtable$peakageFit, 
	    pch = pchVal, 
	    col = scales::alpha(colVal, 0.6),
	    cex = pointSize
	)
	text(5.8, 45, paste(round(corkkage$estimate,2), round(corkkage$p.value, 5)))
	#text(5.8, 45, paste("Age =", round(coef(lmfit)[2], digits=2), "k +", round(coef(lmfit)[1], digits=2)), pos=4, cex=textSize)
	#text(5.8, 38, bquote(R^2 == .(round(summary(lmfit)$r.squared, 3))), pos=4, cex=textSize)
	#text(5.8, 31, bquote(italic("P") == .(format(summary(lmfit)$coefficients[8], scientific = TRUE, digits=2))), pos=4, cex=textSize)
	#text(1.5, 90, substitute(AdjR^2 == a, list(a =round(summary(lmfit)$adj.r.squared, 3))), pos=4)
	dev.off()

	lmfitseer <- lm(peakageSEER ~ kk, data=subtable);

	corkkages <- cor.test(subtable$kk, subtable$peakageSEER, use="complete.obs", method='spearman')
	print(corkkages)
	#browser();

	xx <- seq(1, 10, 0.1)
	yy <- coef(lmfitseer)[2]*xx + coef(lmfitseer)[1];

	png(file.path(outputPath, paste0(Sys.Date(), "-peak-seer-age-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-", gender, ".png")),
		height = 4,
		width = 5,
		units = 'in',
		res = 400,
		pointsize = 6
		);
	par(mar=c(5.1, 5.1, 4.1, 2.1))
	plot(subtable$kk, 
		subtable$peakageSEER, 
		xlab = "k",
		ylab = "Age at peak incidence (SEER)",
		pch = pchVal, 
		col = scales::alpha(colVal, 0.6),
		xlim = c(0, 10),
		ylim = c(12, 117),
		cex.lab = labelSize,
		cex.axis = axisSize,
		cex = pointSize
		)
	arrows(subtable$kk - subtable$mmStdErr, subtable$peakageSEER, subtable$kk + subtable$mmStdErr, subtable$peakageSEER, length=0.05, angle=90, code=3,  col="gray")
	# lines(xx, yy, lty=3)
	lines(xx, (xx-1)/(xx*betaMean), lty=5)
	points(subtable$kk, 
	    subtable$peakageSEER, 
	    pch = pchVal, 
	    col = scales::alpha(colVal, 0.6),
	    cex = pointSize
	)
	text(5.8, 45, paste(round(corkkages$estimate,2), round(corkkages$p.value, 5)))
	#text(5.8, 45, paste("Age =", round(coef(lmfitseer)[2], digits=2), "k +", round(coef(lmfitseer)[1], digits=2)), pos=4, cex=textSize)
	#text(5.8, 38, bquote(R^2 == .(round(summary(lmfitseer)$r.squared, 3))), pos=4, cex=textSize)
	#text(5.8, 31, bquote(italic("P") == .(format(summary(lmfitseer)$coefficients[8], scientific = TRUE, digits=2))), pos=4, cex=textSize)
	##text(1.5, 90, substitute(AdjR^2 == a, list(a =round(summary(lmfit)$adj.r.squared, 3))), pos=4)
	dev.off()
	

	return(lmfit)
}


makepeakagevskplotboth <- function(fittable, smalltablemale, smalltablefemale){
	fittable <- data.frame(fittable, stringsAsFactors=FALSE)

	# female ------------------------------------------------------------------
	subtablefemale <- fittable[which(fittable$sex=="female"),];
	subtablefemale[,3:ncol(subtablefemale)] <- apply(subtablefemale[,3:ncol(subtablefemale)],2, as.numeric)

	subtablefemale$kk <- subtablefemale$mm + 1

	smalltable <- smalltablefemale[, c("Site", "peakrateFit", "peakageFit", "peakageSEER")];
	subtablefemale <- merge(subtablefemale, smalltable, by.x='cancertype', by.y='Site')


	# male --------------------------------------------------------------------
	subtablemale <- fittable[which(fittable$sex=="male"),];
	subtablemale[,3:ncol(subtablemale)] <- apply(subtablemale[,3:ncol(subtablemale)],2, as.numeric)

	subtablemale$kk <- subtablemale$mm + 1

	smalltable <- smalltablemale[, c("Site", "peakrateFit", "peakageFit", "peakageSEER")];
	subtablemale <- merge(subtablemale, smalltable, by.x='cancertype', by.y='Site')

	subtable <- rbind(subtablefemale, subtablemale);
	subtable$colour <- c(rep(femalecolor, nrow(subtablefemale)), rep(malecolor, nrow(subtablemale)))
	subtable$pch <- c(rep(17, nrow(subtablefemale)), rep(15, nrow(subtablemale)))

	badidx <- which(subtable$cancertype %in% EXCLUDED);
	if (length(badidx) > 0){
		subtable <- subtable[-badidx,]
	}
	pchVal <- subtable$pch 
	colVal <- subtable$colour;

	betaMean <- 0.01 #mean(subtable$bb/1000)

	lmfit <- lm(peakageFit ~ kk, data=subtable);

	xx <- seq(1, 10, 0.1)
	yy <- coef(lmfit)[2]*xx + coef(lmfit)[1];

	# #browser();
	png(file.path(outputPath, paste0(Sys.Date(), "-peak-age-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-both-sexes.png")),
		height = 4,
		width = 5,
		units = 'in',
		res = 400,
		pointsize = 6
		);
	par(mar=c(5.1, 5.1, 4.1, 2.1))
	plot(subtable$kk, 
		subtable$peakageFit, 
		xlab = "k",
		ylab = "Age at peak incidence (Model)",
		pch = pchVal, 
		col = scales::alpha(colVal, 0.6),
		xlim = c(0, 10),
		ylim = c(12, 117),
		cex.lab = labelSize,
		cex.axis = axisSize,
		cex = pointSize
		)
	arrows(subtable$kk - subtable$mmStdErr, subtable$peakageFit, subtable$kk + subtable$mmStdErr, subtable$peakageFit, length=0.05, angle=90, code=3,  col="gray")
	#lines(xx, yy, lty=3)
	lines(xx, (xx-1)/(xx*betaMean), lty=5)
	points(subtable$kk, 
	    subtable$peakageFit, 
	    pch = pchVal, 
	    col = scales::alpha(colVal, 0.6),
	    cex = pointSize
	)
	#text(5.8, 45, paste("Age =", round(coef(lmfit)[2], digits=2), "k +", round(coef(lmfit)[1], digits=2)), pos=4, cex=textSize)
	#text(5.8, 38, bquote(R^2 == .(round(summary(lmfit)$r.squared, 3))), pos=4, cex=textSize)
	#text(5.8, 31, bquote(italic("P") == .(format(summary(lmfit)$coefficients[8], scientific = TRUE, digits=2))), pos=4, cex=textSize)
	#text(2.1, 45, paste("Age = k/(0.01*(k+1))"), pos=4, cex=textSize)
	#text(1.5, 90, substitute(AdjR^2 == a, list(a =round(summary(lmfit)$adj.r.squared, 3))), pos=4)
	dev.off()
	
	lmfitseer <- lm(peakageSEER ~ kk, data=subtable);

	xx <- seq(1, 10, 0.1)
	yy <- coef(lmfitseer)[2]*xx + coef(lmfitseer)[1];

	png(file.path(outputPath, paste0(Sys.Date(), "-peak-seer-age-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-both-sexes.png")),
		height = 4,
		width = 5,
		units = 'in',
		res = 400,
		pointsize = 6
		);
	par(mar=c(5.1, 5.1, 4.1, 2.1))
	plot(subtable$kk, 
		subtable$peakageSEER, 
		xlab = "k",
		ylab = "Age at peak incidence (SEER)",
		pch = pchVal, 
		col = scales::alpha(colVal, 0.6),
		xlim = c(0, 10),
		ylim = c(12, 117),
		cex.lab = labelSize,
		cex.axis = axisSize,
		cex = pointSize
		)
	arrows(subtable$kk - subtable$mmStdErr, subtable$peakageSEER, subtable$kk + subtable$mmStdErr, subtable$peakageSEER, length=0.05, angle=90, code=3,  col="gray")
	#lines(xx, yy, lty=3)
	lines(xx, (xx-1)/(xx*betaMean), lty=5)
	points(subtable$kk, 
	    subtable$peakageSEER, 
	    pch = pchVal, 
	    col = scales::alpha(colVal, 0.6),
	    cex = pointSize
	)
	#text(5.8, 45, paste("Age =", round(coef(lmfitseer)[2], digits=2), "k +", round(coef(lmfitseer)[1], digits=2)), pos=4, cex=textSize)
	#text(5.8, 38, bquote(R^2 == .(round(summary(lmfitseer)$r.squared, 3))), pos=4, cex=textSize)
	#text(5.8, 31, paste("P =" , format(summary(lmfitseer)$coefficients[8], scientific = TRUE, digits=2)), pos=4, cex=textSize)
	#text(1.5, 90, substitute(AdjR^2 == a, list(a =round(summary(lmfit)$adj.r.squared, 3))), pos=4)
	dev.off()

	return(lmfit)
}

### MAKE PLOTS ################################################################


# for males and females
for (idx in 1:length(selected)){
	whichCancer <- selected[idx];
	makeplot(newdata, ages, whichCancer, allhfits, ageToStartFit)
}

# for all population
for (idx in 1:length(selected)){
	whichCancer <- selected[idx];
	if (!(whichCancer %in% c(malecancers, femalecancers))){
		makeplotboth(newdata, ages, whichCancer, allhfits, ageToStartFit)
	}
}

# make log a vs k plot --------------------------------------------------------

badidx <- which(newdata$Site %in% EXCLUDED);
if (length(badidx) > 0){
	newdata <- newdata[-badidx, ]
}
badidx <- which(allhfits[,"cancertype"] %in% EXCLUDED);
if (length(badidx) > 0){
	allhfits <- allhfits[-badidx, ]
}
badidx <- which(as.numeric(allhfits[,"bb"]) <= 0);
if (length(badidx) > 0){
	allhfits <- allhfits[-badidx, ]
}

lmfitmale <- makelogavskplot(allhfits, 'male', malecolor, 15);
lmfitfemale <- makelogavskplot(allhfits, 'female', femalecolor, 17);
lmfitboth <- makelogavskplot(allhfits, 'both', bothcolor, 16);
lmfitmalefemale <- makelogavskplot(allhfits, 'malefemale', "red", 17, TRUE);

getFitInfo <- function(fit){
	out <- c(intercept=summary(fit)$coefficients[1], interceptStdErr =summary(fit)$coefficients[3], interceptPval=summary(fit)$coefficients[7],
	kk = summary(fit)$coefficients[2], kkStdErr = summary(fit)$coefficients[4], kkPval=summary(fit)$coefficients[8],
	R2 = summary(fit)$r.squared, adjR2 = summary(fit)$adj.r.squared);
	return(out);
}
linearFits <- rbind(c('male', getFitInfo(lmfitmale)), 
	c('female', getFitInfo(lmfitfemale)), 
	c('both', getFitInfo(lmfitboth)),
	c('male-female', getFitInfo(lmfitmalefemale))
	);


write.table(linearFits,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr,  "-", ageToStartFit, "-Harding-linear-fits-loga-k.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

# make peak age of incidence vs k plot ----------------------------------------------

lmfitmale <- makepeakagevskplot(allhfits, malehfitsnice, 'male', malecolor, 15);
lmfitfemale <- makepeakagevskplot(allhfits, femalehfitsnice, 'female', femalecolor, 17);
lmfitboth <- makepeakagevskplot(allhfits, bothhfitsnice, 'both', bothcolor, 16);
lmfitbothsexes <- makepeakagevskplotboth(allhfits, malehfitsnice, femalehfitsnice);

linearFitsAgevsK <- rbind(c('male', getFitInfo(lmfitmale)), 
	c('female', getFitInfo(lmfitfemale)), 
	c('both', getFitInfo(lmfitboth)),
	c('bothsexes', getFitInfo(lmfitbothsexes))
	);

write.table(linearFitsAgevsK,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr,  "-", ageToStartFit, "-Harding-linear-fit-age-k.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)
