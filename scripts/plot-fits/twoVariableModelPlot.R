### FIGURE 3 #################################################################
# The two variable model is a very poor model for the actual SEER data,
# please do not use as a model to fit the data - it is too board a stroke
# to have only two variables explaining the cancer incidence rate

outputPath <- "../../outputs/seer-tcga/fits/fit04-Gamma"

dd <- -0.008745176
cc <- 0.004597795
bb <- 0.009906885

tt <- seq(0, 100, by=0.1);

fun <- function(kk){
	out <- (cc*kk + dd)^kk/gamma(kk)*tt^(kk-1)*(1-bb*tt)*100000;
	return(out)
}

fun2 <- function(kk){
	out <- (cc*kk + dd)^kk/gamma(kk)*tt^(kk-1)*(1)*100000;
	return(out)
}

# labelSize <- 2.5
# axisSize <- 1.7
# pointSize <- 2.4
# textSize <- 2.2

labelSize <- 2.3
axisSize <- 1.7
pointSize <- 2  
textSize <- 2

tiff(file.path(outputPath, paste0(Sys.Date(), "-age-k-simple-", 
	round(bb, 4), "-",
	round(cc, 4), "-",
	round(dd, 4), ".tiff")),
	height = 4,
	width = 5,
	units = 'in',
	res = 400,
	pointsize = 6
	);
par(mar=c(5.1, 5.1, 4.1, 2.1))
plot(tt, 
	fun(8), 
	xlab = "Age (yr)",
	ylab = "Incidence rate per 100,000 population",
	col = scales::alpha("goldenrod", 0.8),
	cex.lab = labelSize,
	cex.axis = axisSize,
	type = "l",
	lwd = 2,
	xlim = c(0, 100),
	ylim = c(0, 45)
	)
lines(tt, fun(6), col = scales::alpha("red3", 0.8), lwd=2)
lines(tt, fun(4), col = scales::alpha("dodgerblue", 0.8), lwd=2)
lines(tt, fun(3), col = scales::alpha("darkgreen", 0.8), lwd=2)
lines(tt, fun(2), col = scales::alpha("#666666", 0.8), lwd=2)

text(83, 41.3, "8 stages", pos=4, cex=textSize)
text(77, 28, "6 stages", pos=4, cex=textSize)
text(72, 17.5, "4 stages", pos=4, cex=textSize)
text(65, 11.3, "3 stages", pos=4, cex=textSize)
text(52, 2, "2 stages", pos=4, cex=textSize)
dev.off()


### PROBABILITY ###############################################################

computeProb <- function(kk, cc, bb, dd){
	uu <- (cc*kk + dd);
	out <- uu^kk/((bb)^kk*gamma(kk))*(1/kk - 1/(kk+1))
	return(out)
}

computeProb(2, cc, bb, dd)
computeProb(3, cc, bb, dd)
computeProb(4, cc, bb, dd)
computeProb(6, cc, bb, dd)
computeProb(8, cc, bb, dd)

computeProbExp <- function(kk, cc, bb, dd){
	uu <- (cc*kk + dd);
	aa <- uu^kk/gamma(kk);
	out <- 1 - exp(-aa/(kk*bb^kk))
	return(out)
}

computeReduction <- function(kk){
	out <- 1 - computeProb(kk, cc, bb, dd)/computeProbExp(kk, cc, bb, dd)
	return(out)
}

