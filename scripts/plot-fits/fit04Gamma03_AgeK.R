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

load(file.path(outputPath, fileOfCleanTable));

### MAKE AGE OF PEAK INCIDENCE VS K PLOT ######################################


labelSize <- 2.3
axisSize <- 1.7
pointSize <- 2
textSize <- 2

# messy...
makepeakagevskplot <- function(fittable, smalltable, gender, colVal, pchVal){
	
	subtable <- fittable[which(fittable$sex==gender),];

	smalltable <- smalltable[, c("Site", "peakrateFit", "peakageFit")];
	subtable <- merge(subtable, smalltable, by.x='cancertype', by.y='Site')

	xx <- seq(1, 12, 0.1)
	betaMean <- 0.01;

	titlesuffix <- paste0(gender,"s")
	if (gender == "both"){
		titlesuffix <- "non-reproductive, both sexes"
	}
	#browser()

	tiff(file.path(outputPath, paste0(Sys.Date(), "-peak-age-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-", gender,".tiff")),
		height = 4,
		width = 5,
		units = 'in',
		res = 300,
		pointsize = 6
		);
	par(mar=c(5.1, 5.1, 6.1, 2.1))
	plot(subtable$kk, 
		subtable$peakageFit, 
		xlab = "Stages, k",
		ylab = "Age at peak incidence (years)",
		main = paste("Model fit,", titlesuffix),
		pch = pchVal, 
		col = scales::alpha(colVal, 0.6),
		xlim = c(0, 10),
		ylim = c(12, 117),
		cex.lab = labelSize,
		cex.axis = axisSize,
		cex = pointSize,
		cex.main = labelSize+0.5,
		)
	arrows(subtable$kk - subtable$mmStdErr, subtable$peakageFit, subtable$kk + subtable$mmStdErr, subtable$peakageFit, length=0.05, angle=90, code=3,  col="gray")
	#lines(xx, yy, col=colVal, lty=3)
	lines(xx, (xx-1)/(xx*betaMean), col=colVal, lty=5)
	points(subtable$kk, 
	    subtable$peakageFit, 
	    pch = pchVal, 
	    col = scales::alpha(colVal, 0.6),
		cex = pointSize
	)
	dev.off()

	xx <- seq(1, 12, 0.1)

	tiff(file.path(outputPath, paste0(Sys.Date(), "-peak-seer-age-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-", gender, ".tiff")),
		height = 4,
		width = 5,
		units = 'in',
		res = 400,
		pointsize = 6
		);
	par(mar=c(5.1, 5.1, 6.1, 2.1))
	plot(subtable$kk, 
		subtable$peakageseer, 
		xlab = "Stages, k",
		ylab = "Age at peak incidence (years)",
		main = paste("SEER,", titlesuffix),
		pch = pchVal, 
		col = scales::alpha(colVal, 0.6),
		xlim = c(0, 10),
		ylim = c(12, 117),
		cex.lab = labelSize,
		cex.axis = axisSize,
		cex = pointSize,
		cex.main = labelSize+0.5
		)
	arrows(subtable$kk - subtable$mmStdErr, subtable$peakageseer, subtable$kk + subtable$mmStdErr, subtable$peakageseer, length=0.05, angle=90, code=3,  col="gray")
	# lines(xx, yy, lty=3)
	lines(xx, (xx-1)/(xx*betaMean), lty=5)
	points(subtable$kk, 
	    subtable$peakageseer, 
	    pch = pchVal, 
	    col = scales::alpha(colVal, 0.6),
	    cex = pointSize
	)
	dev.off()
	
	return(subtable)
}

makepeakagevskplotboth <- function(fittable, smalltablemale, smalltablefemale){

	# female ------------------------------------------------------------------
	subtablefemale <- fittable[which(fittable$sex=="female"),];

	smalltable <- smalltablefemale[, c("Site", "peakrateFit", "peakageFit", "peakageSEER")];
	subtablefemale <- merge(subtablefemale, smalltable, by.x='cancertype', by.y='Site')


	# male --------------------------------------------------------------------
	subtablemale <- fittable[which(fittable$sex=="male"),];

	smalltable <- smalltablemale[, c("Site", "peakrateFit", "peakageFit", "peakageSEER")];
	subtablemale <- merge(subtablemale, smalltable, by.x='cancertype', by.y='Site')

	subtable <- rbind(subtablefemale, subtablemale);
	subtable$colour <- c(rep(femalecolor, nrow(subtablefemale)), rep(malecolor, nrow(subtablemale)))
	subtable$pch <- c(rep(17, nrow(subtablefemale)), rep(15, nrow(subtablemale)))

	pchVal <- subtable$pch 
	colVal <- subtable$colour;

	betaMean <- 0.01

	xx <- seq(1, 12, 0.1)

	tiff(file.path(outputPath, paste0(Sys.Date(), "-peak-age-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-both-sexes.tiff")),
		height = 4,
		width = 5,
		units = 'in',
		res = 400,
		pointsize = 6
		);
	par(mar=c(5.1, 5.1, 6.1, 2.1))
	plot(subtable$kk, 
		subtable$peakageFit, 
		xlab = bquote("Stages, " ~ italic("k")),
		ylab = "Age at peak incidence (yr)",
		main = "Model-fitted, males and females",
		pch = pchVal, 
		col = scales::alpha(colVal, 0.6),
		xlim = c(0, 12),
		ylim = c(12, 117),
		cex.lab = labelSize,
		cex.main = labelSize+0.5,
		cex.axis = axisSize,
		cex = pointSize
		)
	arrows(subtable$kk - subtable$mmStdErr, subtable$peakageFit, subtable$kk + subtable$mmStdErr, subtable$peakageFit, length=0.05, angle=90, code=3,  col="gray")
	lines(xx, (xx-1)/(xx*betaMean), lty=5)
	points(subtable$kk, 
	    subtable$peakageFit, 
	    pch = pchVal, 
	    col = scales::alpha(colVal, 0.6),
	    cex = pointSize
	)
	dev.off()
	
	xx <- seq(1, 12.2, 0.1)

	tiff(file.path(outputPath, paste0(Sys.Date(), "-peak-seer-age-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-both-sexes.tiff")),
		height = 4,
		width = 5,
		units = 'in',
		res = 400,
		pointsize = 6
		);
	par(mar=c(5.1, 5.1, 6.1, 2.1))
	plot(subtable$kk, 
		subtable$peakageSEER, 
		xlab = bquote("Stages, " ~ italic("k")),,
		ylab = "Age at peak incidence (yr)",
		main = "SEER, males and females",
		pch = pchVal, 
		col = scales::alpha(colVal, 0.6),
		xlim = c(0, 12),
		ylim = c(12, 117),
		cex.lab = labelSize,
		cex.main = labelSize+0.5,
		cex.axis = axisSize,
		cex = pointSize
		)
	arrows(subtable$kk - subtable$mmStdErr, subtable$peakageSEER, subtable$kk + subtable$mmStdErr, subtable$peakageSEER, length=0.05, angle=90, code=3,  col="gray")
	lines(xx, (xx-1)/(xx*betaMean), lty=5)
	points(subtable$kk, 
	    subtable$peakageSEER, 
	    pch = pchVal, 
	    col = scales::alpha(colVal, 0.6),
	    cex = pointSize
	)
	dev.off()

	return(subtable)

	}

# make peak age of incidence vs k plot ----------------------------------------------
agekfitmale <- makepeakagevskplot(allgfits_u, malegfitsnice, 'male', malecolor, 15);
agekfitfemale <- makepeakagevskplot(allgfits_u, femalegfitsnice, 'female', femalecolor, 17);
agekfitboth <- makepeakagevskplot(allgfits_u, bothgfitsnice, 'both', bothcolor, 16);
agekfitbothsexes <- makepeakagevskplotboth(allgfits_u, malegfitsnice, femalegfitsnice);

### CHECK FOR PATTERNS ##################################################################

# should be 23 for males
# should be 25 for females
# should be 21 for both

ageCorMaleSEER <- cor.test(agekfitmale$kk, agekfitmale$peakageseer, method="spearman") 
ageCorMaleFit <- cor.test(agekfitmale$kk, agekfitmale$peakageFit, method="spearman")  
rateCorMaleSEER <- cor.test(agekfitmale$kk, agekfitmale$peakrateseer, method="spearman")  
rateCorMaleFit <- cor.test(agekfitmale$kk, agekfitmale$peakrateFit, method="spearman")  
nnMale <- nrow(agekfitmale)

ageCorFemaleSEER <- cor.test(agekfitfemale$kk, agekfitfemale$peakageseer, method="spearman")  
ageCorFemaleFit <- cor.test(agekfitfemale$kk, agekfitfemale$peakageFit, method="spearman")  
rateCorFemaleSEER <- cor.test(agekfitfemale$kk, agekfitfemale$peakrateseer, method="spearman")  
rateCorFemaleFit <- cor.test(agekfitfemale$kk, agekfitfemale$peakrateFit, method="spearman") 
nnFemale <- nrow(agekfitfemale) 

ageCorBothSEER <- cor.test(agekfitboth$kk, agekfitboth$peakageseer, method="spearman")  
ageCorBothFit <- cor.test(agekfitboth$kk, agekfitboth$peakageFit, method="spearman")  
rateCorBothSEER <- cor.test(agekfitboth$kk, agekfitboth$peakrateseer, method="spearman")  
rateCorBothFit <- cor.test(agekfitboth$kk, agekfitboth$peakrateFit, method="spearman") 
nnBoth <- nrow(agekfitboth)

ageCorMFSEER <- cor.test(agekfitbothsexes$kk, agekfitbothsexes$peakageseer, method="spearman")  
ageCorMFFit <- cor.test(agekfitbothsexes$kk, agekfitbothsexes$peakageFit, method="spearman")  
rateCorMFSEER <- cor.test(agekfitbothsexes$kk, agekfitbothsexes$peakrateseer, method="spearman")  
rateCorMFFit <- cor.test(agekfitbothsexes$kk, agekfitbothsexes$peakrateFit, method="spearman") 
nnMF <- nrow(agekfitbothsexes)

ageCorResults <- data.frame(
	comparison = c("male, SEER", "male, fit", "female, SEER", "female, fit", 
		"both, SEER", "both, fit", "male and female, SEER", "male and female, fit"),
	rho = c(ageCorMaleSEER$estimate, ageCorMaleFit$estimate, 
			ageCorFemaleSEER$estimate, ageCorFemaleFit$estimate,
			ageCorBothSEER$estimate, ageCorBothFit$estimate,
			ageCorMFSEER$estimate, ageCorMFFit$estimate),
	pval = c(ageCorMaleSEER$p.value, ageCorMaleFit$p.value, 
			ageCorFemaleSEER$p.value, ageCorFemaleFit$p.value,
			ageCorBothSEER$p.value, ageCorBothFit$p.value,
			ageCorMFSEER$p.value, ageCorMFFit$p.value),
	n = c(nnMale, nnMale, nnFemale, nnFemale, nnBoth, nnBoth, nnMF, nnMF)
	)

write.table(ageCorResults,
	file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-Spearman-corr-age-of-peak-and-k.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)


rateCorResults <- data.frame(
	comparison = c("male, SEER", "male, fit", "female, SEER", "female, fit", 
		"both, SEER", "both, fit", "male and female, SEER", "male and female, fit"),
	rho = c(rateCorMaleSEER$estimate, rateCorMaleFit$estimate, 
			rateCorFemaleSEER$estimate, rateCorFemaleFit$estimate,
			rateCorBothSEER$estimate, rateCorBothFit$estimate,
			rateCorMFSEER$estimate, rateCorMFFit$estimate),
	pval = c(rateCorMaleSEER$p.value, rateCorMaleFit$p.value, 
			rateCorFemaleSEER$p.value, rateCorFemaleFit$p.value,
			rateCorBothSEER$p.value, rateCorBothFit$p.value,
			rateCorMFSEER$p.value, rateCorMFFit$p.value),
	n = c(nnMale, nnMale, nnFemale, nnFemale, nnBoth, nnBoth, nnMF, nnMF)
	)

write.table(rateCorResults,
	file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-Spearman-corr-peak-rate-and-k.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)
	