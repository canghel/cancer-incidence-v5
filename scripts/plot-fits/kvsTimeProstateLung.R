### PREAMBLE ##################################################################

library(scales)

outputPath <- "../../outputs/seer/fits/fit03-Harding"

femalecolor <- "red3" # "#D73027"
malecolor <- "dodgerblue4" #"#4575B4" 
bothcolor <- "black"

### MAKE k VS TIME: PROSTATE ##################################################

# data ------------------------------------------------------------------------
progression = 0:3 * 10
kProstate = c(9.8, 8.5, 6.2, 5.3)

lmfitProstate <- lm(kProstate ~ progression)
xx <- seq(0, 30, 1)
yy <- coef(lmfitProstate)[1] + coef(lmfitProstate)[2]*xx

# plotting text and options ---------------------------------------------------
textEqn <- paste0('y = ', round(coef(lmfitProstate)[2], 2), 'x + ', 
	round(coef(lmfitProstate)[1], 2))
textR2 <-  bquote(R^2 == .(round(summary(lmfitProstate)$r.squared, 3)))	
textPval <- bquote(italic("P") == .(round(summary(lmfitProstate)$coefficients[8], 3)))

#bquote(italic("P") == .(format(summary(lmfitProstate)$coefficients[8], 
#	scientific = TRUE, digits=2)))

labelSize <- 2.3
axisSize <- 1.7
pointSize <- 2
textSize <- 2

# plot ------------------------------------------------------------------------
png(file.path(outputPath, paste0(Sys.Date(), "-k-vs-time-prostate.png")),
	height = 4,
	width = 5,
	units = 'in',
	res = 400,
	pointsize = 6
	);
par(mar=c(5.1, 5.1, 6.1, 2.1))
plot(progression, kProstate, 
	xlab = 'Years since 1979', 
    ylab = 'Stages, k', 
    main = 'Prostate Cancer',
    col = scales::alpha(malecolor, 0.8), 
    pch = 15,
    cex.lab = labelSize,
	cex.main = labelSize+0.5,
	cex.axis = axisSize,
	cex = pointSize
    )
points(21, 5.5,  
	col = scales::alpha(malecolor, 0.8), 
    pch = 0,
    cex.lab = labelSize,
	cex.main = labelSize+0.5,
	cex.axis = axisSize,
	cex = pointSize)
lines(xx, yy, 
	col = malecolor, 
	lty=3)
#text(2, 6.7, textEqn, pos=4, cex=textSize)
#text(2, 6.3, textR2, pos=4, cex=textSize)
#text(2, 5.9, textPval, pos=4, cex=textSize)
dev.off();

### MAKE k VS TIME: LUNG ######################################################

# data ------------------------------------------------------------------------
kLungBrochusMale <- c(6.3, 6.6, 7.2, 8.2)
kLungBrochusFemale <- c(4.0, 5.1, 6.0, 7.4)

lmfitLungBrochusMale <- lm(kLungBrochusMale ~ progression)
lmfitLungBrochusFemale <- lm(kLungBrochusFemale ~ progression)

xx <- seq(0, 30, 1)
yyM <- coef(lmfitLungBrochusMale)[1] + coef(lmfitLungBrochusMale)[2]*xx
yyF <- coef(lmfitLungBrochusFemale)[1] + coef(lmfitLungBrochusFemale)[2]*xx

# plotting text and options ---------------------------------------------------
textEqnFemale <- paste0('y = ', round(coef(lmfitLungBrochusFemale)[2], 2), 'x + ', 
	round(coef(lmfitLungBrochusFemale)[1], 2))
textR2Female <-  bquote(R^2 == .(round(summary(lmfitLungBrochusFemale)$r.squared, 3)))	
textPvalFemale <-  bquote(italic("P") == .(round(summary(lmfitLungBrochusFemale)$coefficients[8], 3)))

#bquote(italic("P") == .(format(summary(lmfitLungBrochusFemale)$coefficients[8], 
#	scientific = TRUE, digits=2)))

textEqnMale <- paste0('y = ', round(coef(lmfitLungBrochusMale)[2], 2), 'x + ', 
	round(coef(lmfitLungBrochusMale)[1], 2))
textR2Male <-  bquote(R^2 == .(round(summary(lmfitLungBrochusMale)$r.squared, 3)))	
textPvalMale <- bquote(italic("P") == .(round(summary(lmfitLungBrochusMale)$coefficients[8], 3)))

#bquote(italic("P") == .(format(summary(lmfitLungBrochusMale)$coefficients[8], 
#	scientific = TRUE, digits=2)))

# plot ------------------------------------------------------------------------
png(file.path(outputPath, paste0(Sys.Date(), "-k-vs-time-lung-male-female.png")),
	height = 4,
	width = 5,
	units = 'in',
	res = 400,
	pointsize = 6
	);
par(mar=c(5.1, 5.1, 6.1, 2.1))
plot(progression, kLungBrochusMale,  
	xlab = 'Years since 1979', 
	ylab = 'Stages, k', 
    main = 'Lung and Bronchus Cancer',
    col = scales::alpha(malecolor, 0.8), 
    pch = 15,
    cex.lab = labelSize,
	cex.main = labelSize+0.5,
	cex.axis = axisSize,
	cex = pointSize,
	ylim = c(3.5, 8.5)
    )
points(21, 7.4,  
	col = scales::alpha(malecolor, 0.8), 
    pch = 0,
	cex = pointSize)
points(progression, kLungBrochusFemale,  
    col = scales::alpha(femalecolor, 0.8), 
    pch = 17,
	cex = pointSize
    )
points(21, 6.7,  
	col = scales::alpha(femalecolor, 0.8), 
    pch = 2,
	cex = pointSize)
lines(xx, yyF, 
	col = femalecolor, 
	lty=3)
lines(xx, yyM, 
	col = malecolor, 
	lty=3)
#text(2, 8.0, textEqnMale, pos=4, cex=textSize)
#text(2, 7.6, textR2Male, pos=4, cex=textSize)
#text(2, 7.2, textPvalMale, pos=4, cex=textSize)
#text(15, 5.2, textEqnFemale, pos=4, cex=textSize)
#text(15, 4.8, textR2Female, pos=4, cex=textSize)
#text(15, 4.4, textPvalFemale, pos=4, cex=textSize)
dev.off()