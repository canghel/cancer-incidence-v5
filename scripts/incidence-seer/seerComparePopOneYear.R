# run IMMEDIATELY after seerCountsOneYear.R without clearing workspace

### OPTIONS ###################################################################
# needs to be specified before calling the script
# popyear and seeryear specified in previous script
# date that seer processed cases were saved
dateSaved <- '2021-08-20'

### PREAMBLE ##################################################################

library(RColorBrewer);
library(gplots);
popPath <- file.path(outputPath, 'population', 
	paste0(dateSaved, '-pop-data-tables-', popyear, '.RData'));

### GET POPULATION DATA #######################################################

load(popPath);

### COMPARE ###################################################################

summaryRatios <- NULL;
for (gender in c("Male", "Female", "Both")){ 

	seerpop <- all5yrpoptable[which(all5yrpoptable$Sex==gender), ];
	censuspop <- popdata5yr[which(popdata5yr$sex==gender), ];

	# get only one site, since values are same for all sites
	seerpop <- seerpop[which(seerpop$Site=="Esophagus"), ]
	seerpop$Site <- NULL;

	# create 19 group population table
	censuspopsubset <- censuspop[which(censuspop$ages < 85),]
	temp <- colSums(censuspop[which(censuspop$ages >= 85), 3:ncol(censuspop)])
	censuspopsubset <- rbind(censuspopsubset, c(gender, 85, temp))
	censuspopsubset$ages <- as.numeric(censuspopsubset$ages)
	censuspopsubset <- censuspopsubset[order(censuspopsubset$ages),]

	seerpopsubset <- seerpop[complete.cases(seerpop),]
	seerpopsubset$Age[seerpopsubset$Age=="85+"] <- 85;
	seerpopsubset$Age <- as.numeric(seerpopsubset$Age);
	seerpopsubset <- seerpopsubset[order(seerpopsubset$Age),]

	# after sorting, take out just numerical data for seer populations
	seerpopval <- seerpopsubset[,3:ncol(seerpopsubset)];
	rownames(seerpopval) <- seerpopsubset$Age;
	# and for census population
	censuspopval <- censuspopsubset[,3:ncol(censuspopsubset)]
	censuspopval <- censuspopval[,(colnames(censuspopval) %in% colnames(seerpopval))]
	rownames(censuspopval) <- censuspopsubset$ages;
	censuspopval <- apply(censuspopval,2,as.numeric);


	fractcensus <- censuspopval;
	for (jj in 1:ncol(fractcensus)){
		fractcensus[,jj] <- fractcensus[,jj]/(colSums(censuspopval)[jj])
	}
	fractseer <- seerpopval;
	for (jj in 1:ncol(fractseer)){
		fractseer[,jj] <- fractseer[,jj]/(colSums(seerpopval)[jj])
	}

	# compute ratios from seer populations relative to census populations
	if (identical(colnames(censuspopval), colnames(seerpopval))){
		seertocensusdiff <- (fractseer-fractcensus)/fractseer;
		rownames(seertocensusdiff) <- censuspopsubset$ages
	}

	write.table(seertocensusdiff,
		file.path(outputPath, 'seer', 'seer-checks', paste0(Sys.Date(), '-seer-to-census-pop-ratio-by-registry-census-', popyear, '-seer-', seeryear, '-gender-', gender, '.csv')),
		sep = ",",
		quote = FALSE,
		col.names = TRUE,
		row.names = FALSE
	)


	flog.info("The summary of the seer to census data")
	print(summary(as.vector(as.matrix(seertocensusdiff))))
	summaryRatios <- rbind(summaryRatios, c(gender, summary(as.vector(as.matrix(seertocensusdiff)))))

	sumRatios <- rowSums(seerpopval)/rowSums(apply(censuspopval,2,as.numeric))

	# visualize using heatmap (& small histogram)
	png(file.path(outputPath, 'seer', 'seer-checks', paste0(Sys.Date(), '-seer-to-census-pop-ratio-census-', popyear, '-seer-', seeryear, '-', gender, '.png')),
		height = 4,
		width = 4,
		units = 'in',
		res = 300,
		pointsize = 6
		);
	heatmap.2(as.matrix(seertocensusdiff),
		dendrogram = 'none',
		Colv = NULL,
		Rowv = NULL,
		col = colorRampPalette(brewer.pal(8, "RdBu"))(24),
		labRow = rownames(seertocensusdiff),
		trace = 'none',
		cexCol = 0.7
		);
	dev.off()
}

# write the summary ratios to table -------------------------------------------
write.table(summaryRatios,
	file.path(outputPath, 'seer', 'seer-checks', paste0(Sys.Date(), '-seer-to-census-pop-ratio-census-', popyear, '-seer-', seeryear, '.csv')),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

write.table(sumRatios,
	file.path(outputPath, 'seer', 'seer-checks', paste0(Sys.Date(), '-seer-to-census-pop-sum-ratio-census-', popyear, '-seer-', seeryear, '.csv')),
	sep = ",",
	quote = FALSE,
	col.names = FALSE,
	row.names = TRUE
	)

rm(seerpop, censuspop, seerpopsubset, censuspopsubset, seerpopval, censuspopval, seertocensusdiff, summaryRatios, gender)