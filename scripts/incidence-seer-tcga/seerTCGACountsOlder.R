### COLLECT DATA FOR OLDER AGES ###############################################

dataOlderCounts <- foreach(aa=seq(85, 110, by=5), .combine=rbind) %dopar% {
	if (aa==110){bb <- 120} else {bb <- aa+4}
	output <- read.table(file = file.path(seerTcgaPath, cancertype, paste0('2000-2015-SEER-age-', aa ,'-', bb,'.csv')),
		header = TRUE,
		stringsAsFactors = FALSE,
		sep = ","
		);
	colnames(output) <- c('year', 'Seer', 'Sex', 'Rate', 'Count', 'Population');

	output <- output[which(output$year %in% startyear:(startyear+3)), ]
	output <- output[ , c(1,2,3,5)];
	output <- spread(output, Seer, Count)


	output$year <- NULL;
	output <- output %>% group_by(Sex) %>% summarize_all(list(sum))
	output$Age <- rep(aa, nrow(output));
	return(output)
}


for (jj in 1:nrow(registrydic)){
	idx <- which(colnames(dataOlderCounts)==registrydic$seer[jj])
	if (length(idx > 0)){
	  colnames(dataOlderCounts)[idx] <- as.character(registrydic$pop[jj])
	}
}

dataOlderCounts$Sex[which(dataOlderCounts$Sex=="Male and female")] <- "Both"


