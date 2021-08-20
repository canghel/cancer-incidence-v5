### CALCULATE ERRORS FOR # CASES GIVEN THE POPULATION #########################
# calculate errors bars according to Harding:

# x = new diagnoses, n = person years at risk
# x > 10: normal distribution
# x < 10 and n > 1000: Poisson distribution
# x < 10 and n < 1000: exact binomial proportion

### PREAMBLE ##################################################################


outputPath <- "../../outputs/seer-tcga/count-data"
plotPath <- "../../outputs/seer-tcga/count-data/error-plots" 

firstyr <- startyear
lastyr <- firstyr+3


### ADD COLUMNS FOR ERRORS #################################################### 

sumcounts$pp <- rep(NA, nrow(sumcounts))
sumcounts$SE <- rep(NA, nrow(sumcounts))
sumcounts$II <- rep(NA, nrow(sumcounts))
sumcounts$minb <- rep(NA, nrow(sumcounts))
sumcounts$maxb <- rep(NA, nrow(sumcounts))


### NORMAL SE #################################################################

idxNorm <- which(sumcounts$Count > 10 & sumcounts$Population > 1000);

sumcounts$pp[idxNorm] <- sumcounts$Count[idxNorm]/sumcounts$Population[idxNorm];
sumcounts$SE[idxNorm] <- sqrt(sumcounts$pp[idxNorm]*(1-sumcounts$pp[idxNorm])/sumcounts$Population[idxNorm]);
sumcounts$II[idxNorm] <- sumcounts$SE[idxNorm]*sumcounts$Population[idxNorm];
sumcounts$minb[idxNorm]  <- sumcounts$Count[idxNorm] - sumcounts$II[idxNorm]; 
sumcounts$maxb[idxNorm]  <- sumcounts$Count[idxNorm] + sumcounts$II[idxNorm];


### POISSON ####################################################################

idxPoiss <- which(sumcounts$Count <= 10 & sumcounts$Population > 1000);

sumcounts$minb[idxPoiss]  <- sapply(sumcounts$Count[idxPoiss], 
	function(x){out <- poisson.test(x, conf.level=0.682)$conf.int[1]}
	);
sumcounts$maxb[idxPoiss]  <- sapply(sumcounts$Count[idxPoiss], 
	function(x){out <- poisson.test(x, conf.level=0.682)$conf.int[2]}
	);


### EXACT BINOMIAL PROPORTION #################################################

idxBin <- which(sumcounts$Count <= 10 & sumcounts$Population <= 1000); 

sumcounts$pp[idxBin] <- sumcounts$Count[idxBin]/sumcounts$Population[idxBin];
for (jj in idxBin){
	binTest <- binom.test(sumcounts$Count[jj], 
		sumcounts$Population[jj], 
		p=sumcounts$pp[jj], 
		conf.level=0.682
		);
	sumcounts$minb[jj] <- binTest$conf.int[1]*sumcounts$Population[jj]	
	sumcounts$maxb[jj] <- binTest$conf.int[2]*sumcounts$Population[jj]
}


### GO FROM BOUNDS FOR COUNTS TO BOUNDS FOR RATES #############################

sumcounts$minb <- sumcounts$minb/sumcounts$Population*100000
sumcounts$maxb <- sumcounts$maxb/sumcounts$Population*100000

## PLOT DATA #################################################################

makeploterrbars <- function(alldata, ages, cancertype){
	male <- filter(alldata, Site  == cancertype & Sex=="Male");
	female <- filter(alldata, Site  == cancertype & Sex=="Female");
  
	male$Age <- as.numeric(male$Age)
	female$Age <- as.numeric(female$Age)
	male <- arrange(male, Age)
	female <- arrange(female, Age)
	
	# browser();
	subdata <- data.frame(
		age = male$Age,
		male = male[,"CrudeRate"],
		malemin = male[, "minb"],
		malemax = male[, "maxb"],
		female = female[,"CrudeRate"],
		femalemin = female[, "minb"],
		femalemax = female[, "maxb"]
	)

	maxyval <- max(c(subdata$male, subdata$female));

	png(file.path(plotPath, paste0(Sys.Date(), "-", cancertype, "-", firstyr, "-", lastyr, "-with-error-bars.png")),
		height = 4,
		width = 4,
		units = 'in',
		res = 300,
		pointsize = 6,
		type = 'cairo'
		);
	#par(mar=c(1,1,1,1))
	plot(ages, subdata$male, ylim=c(0, ceiling(maxyval)+1), pch = 0, ylab='', xlab='age'); 
	points(ages, subdata$female, pch = 17, col="red");
	arrows(ages, subdata$malemin, ages, subdata$malemax, length=0.05, angle=90, code=3, col="gray")
	arrows(ages, subdata$femalemin, ages, subdata$femalemax, length=0.05, angle=90, code=3, col="gray")
	dev.off();
}

cancertypes <- unique(sort(sumcounts$Site));

for (cancertype in cancertypes){
	makeploterrbars(sumcounts, ages, cancertype);
}

### SAVE TO FILE ##############################################################

save(sumcounts, file=file.path(outputPath, paste0(Sys.Date(),  "-", firstyr, "-", lastyr, "-counts-and-errs.RData")));

write.table(sumcounts,
	file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-counts-and-errs.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)
