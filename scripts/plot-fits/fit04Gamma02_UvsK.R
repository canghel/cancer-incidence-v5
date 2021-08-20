### PREAMBLE ##################################################################

library(dplyr)
library(tidyr)
library(scales)
library(car)

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

EXCLUDED <- c("Hodgkin Lymphoma", "All Sites", "All Major Non Sex", "All Major", "COADREAD", "LGG", "PCPG");

### WHICH ONES OMITTED ########################################################

print(allgfits[which(as.numeric(allgfits[, "uuPval"]) > 0.1),1:2])
print(allgfits[which(as.numeric(allgfits[, "mmPval"]) > 0.1),1:2])


### FITTING FUNCTIONS #########################################################

gmodel <- function(coefs, tt){
	uu <- coefs[1]/100 # coef = uu*100
	bb <- coefs[2]/1000 # coef  = beta*1000 
	mm <- coefs[3] # mm = k-1
	out <- uu^(mm+1)/gamma(mm+1)*(tt^mm)*(1-bb*tt)*100000;
}


### MAKE U VS K PLOT FUNCTION ##################################################

labelSize <- 2.3
axisSize <- 1.7
pointSize <- 2
textSize <- 2

makeuvskplot <- function(fittable, gender, colVal, pchVal){
	#fittable <- data.frame(fittable, stringsAsFactors=FALSE)

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
	subtable[,3:(ncol(subtable)-1)] <- apply(subtable[,3:(ncol(subtable)-1)],2, as.numeric)
	
	subtable$uuStdErr <- subtable$uux100StdErr/100;

	lmfit <- lm(uu ~ kk, data=subtable);

	xx <- seq(0.2, 11, 0.1)
	yy <- coef(lmfit)[2]*xx + coef(lmfit)[1];

	titlephase <- paste0("All cancers, ", gender,"s")
	if (gender == "both"){
		titlephase <- "Non-reproductive cancers, both sexes"
	}
	tiff(file.path(outputPath, paste0(Sys.Date(), "-u-vs-k-", firstyr, "-", lastyr, "-", ageToStartFit, "-", gender,".tiff")),
		height = 4,
		width = 5,
		units = 'in',
		res = 400,
		pointsize = 6
		);
	par(mar=c(5.1, 5.8, 4.1, 2.1))
	plot(subtable$kk, 
		subtable$uu, 
		xlab = bquote("Stages, " ~ italic("k")),,
		ylab = bquote("Stage-transition rate, " ~ italic("u")[italic(mu)] ~ " (yr"^-1 * ")"),
		main = titlephase,
		pch = subtable$pch, , 
		col = scales::alpha(subtable$colour, 0.6),
		ylim = c(0, 4.3)/100,
		xlim = c(0, 12),
		cex.lab = labelSize,
		cex.axis = axisSize,
		cex.main = labelSize+0.5,
		cex = pointSize
		)
	arrows(subtable$kk, subtable$uu - subtable$uuStdErr, subtable$kk, subtable$uu + subtable$uuStdErr, length=0.05, angle=90, code=3, col="gray")
	arrows(subtable$kk - subtable$mmStdErr, subtable$uu, subtable$kk + subtable$mmStdErr, subtable$uu, length=0.05, angle=90, code=3,  col="gray")
	lines(xx, yy, col=linecolour, lty=3)
	points(subtable$kk, 
	    subtable$uu, 
		pch = subtable$pch, , 
		col = scales::alpha(subtable$colour, 0.6),
		cex = pointSize
	)
	text(0.5, 0.039, bquote(italic("u") == .(round(coef(lmfit)[2], digits=4))  ~ italic("k") ~ " - " ~  .(round(-coef(lmfit)[1], digits=4))), pos=4, cex=textSize)
	text(0.5, 0.036, bquote(italic("R")^2 == .(round(summary(lmfit)$r.squared, 3))), pos=4, cex=textSize)
	text(0.5, 0.033, bquote(italic("P") == .(format(summary(lmfit)$coefficients[8], scientific = TRUE, digits=2))), pos=4, cex=textSize)
	# text(2, 0.033, substitute(AdjR^2 == a, list(a =round(summary(lmfit)$adj.r.squared, 3))), pos=4)
	dev.off()
	
	return(lmfit)
}

### MAKE PLOTS ################################################################

allgfits_u <- allgfits
badidx <- which(allgfits_u[,"cancertype"] %in% EXCLUDED)
if (length(badidx) > 0){
	allgfits_u <- allgfits_u[-badidx, ]
}

if (firstyr == 2010){
	badidx <- which(allgfits_u[,"cancertype"]=="READ" & allgfits_u[,"sex"]=="female")
	#print(paste("here:", badidx))
	if (length(badidx) > 0){
		allgfits_u <- allgfits_u[-badidx, ]
	}
}

if (firstyr == 2000){
	badidx <- which(allgfits_u[,"cancertype"] %in% c("ACC", "SARC") & allgfits_u[,"sex"]=="female")
	#print(paste("here:", badidx))
	if (length(badidx) > 0){
		allgfits_u <- allgfits_u[-badidx, ]
	}
	badidx <- which(allgfits_u[,"cancertype"]=="ACC" & allgfits_u[,"sex"]=="both")
	#print(paste("here:", badidx))
	if (length(badidx) > 0){
		allgfits_u <- allgfits_u[-badidx, ]
	}
}

allgfits_u <- as.data.frame(allgfits_u)
temp <- apply(allgfits_u[, 3:ncol(allgfits_u)], 2, function(x){as.numeric(as.character(x))})
allgfits_u[,3:ncol(allgfits_u)]  <- temp;
allgfits_u$uu <- allgfits_u$uux100/100
allgfits_u$bb <- allgfits_u$bbx1000/1000
allgfits_u$kk <- allgfits_u$mm + 1

lmfitmale <- makeuvskplot(allgfits_u, 'male', malecolor, 15);
lmfitfemale <- makeuvskplot(allgfits_u, 'female', femalecolor, 17);
lmfitboth <- makeuvskplot(allgfits_u, 'both', bothcolor, 16);


# save the fit info to file ---------------------------------------------------
getFitInfo <- function(fit){
	out <- c(intercept=summary(fit)$coefficients[1], interceptStdErr =summary(fit)$coefficients[3], interceptPval=summary(fit)$coefficients[7],
	kk = summary(fit)$coefficients[2], kkStdErr = summary(fit)$coefficients[4], kkPval=summary(fit)$coefficients[8],
	R2 = summary(fit)$r.squared, adjR2 = summary(fit)$adj.r.squared);
	return(out);
}
linearFits <- rbind(c('male', getFitInfo(lmfitmale)), 
	c('female', getFitInfo(lmfitfemale)), 
	c('both', getFitInfo(lmfitboth))#,
	#c('male-female', getFitInfo(lmfitmalefemale))
	);

write.table(linearFits,
	file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr,  "-", ageToStartFit, "-Gamma-linear-fits-uu-k.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)


### COMPUTE AND ADD 2-TERM INFO TO TABLE ######################################

# get the coefficients of the regression line as well as mean b for that sex
# (excluding the orrect cancer types)
get2TermCoefs <- function(sex, lmfit){
	CC <-coef(lmfit)[2]
	DD <- coef(lmfit)[1]
	BB <- mean(as.numeric(allgfits_u[which(allgfits_u[,"sex"]==sex), "bbx1000"]))/1000
	out <- c(CC, DD, BB);
	return(out)
}

coefsmale <- get2TermCoefs("male", lmfitmale)
coefsfemale <- get2TermCoefs("female", lmfitfemale)
coefsboth <- get2TermCoefs("both", lmfitboth)

# add the 2-term estimates for the probability to the tables ------------------
add2TermInfo <- function(temptable, coefs){
	CC <- coefs[1]
	DD <- coefs[2]
	BB <- coefs[3]
	
	temptable$probFit2Term <- (CC*temptable$kk + DD)^temptable$kk/((temptable$beta)^temptable$kk*gamma(temptable$kk))*(1/temptable$kk - 1/(temptable$kk+1))
	temptable$ratio <- temptable$probSEER/temptable$probFit2Term
	temptable$uu2Term <- (CC*temptable$kk + DD)

	return(temptable)
}

# put all together and also get formatted table --------------------------------

temp1 <- data.frame(sex=rep("male"), malegfitsnice)
temp1_2Term <- add2TermInfo(temp1, coefsmale)
temp2 <- data.frame(sex=rep("female"), femalegfitsnice)
temp2_2Term <- add2TermInfo(temp2, coefsfemale)
temp3 <- data.frame(sex=rep("both"), bothgfitsnice)
temp3_2Term <- add2TermInfo(temp3, coefsboth)
allnice_2Term <- rbind(temp1_2Term, temp2_2Term, temp3_2Term)

write.table(allnice_2Term,
	file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-Gamma-table-with-u.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

# this repeats what was done before, not nice, but it's easiest atm
temp_formatted <- allnice_2Term;
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
temp_formatted$ratio <- formatC(signif(temp_formatted$ratio, digits=2), digits=2,format="fg", flag="#")
temp_formatted$probFit2Term <- formatC(signif(temp_formatted$probFit2Term, digits=2), digits=2, flag="#")
temp_formatted$uu2Term <- round(temp_formatted$uu2Term, digits=3)
allniceFormatted_2Term <- temp_formatted;
rm(temp_formatted)


write.table(allniceFormatted_2Term,
	file.path(outputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-Gamma-table-formatted-with-u.csv")),
	sep = ",",
	quote = FALSE,
	col.names = TRUE,
	row.names = FALSE
	)

save(allgfits_u, allnice_2Term, allniceFormatted_2Term, coefsmale, coefsfemale, coefsboth, 
	file=file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit,  "-Gamma-with-u.RData")));


### CHECK IF HAVE SAME SLOPE/INTERCEPT ########################################
# Used this reference:
# http://rcompanion.org/rcompanion/e_04.html

# Be careful: want to use allgfits_u since that's the one that drops the
# badindices (with large-pvals for uu and kk)

mf <- allgfits_u[which(allgfits_u$sex %in% c("male", "female")),]
# check between males and females
options(contrasts=c("contr.treatment", "contr.ploy"))
mod1MF <- lm(uu ~ kk + sex + kk:sex, data = mf)
testSlopeMF <- Anova(mod1MF, type='II')
# In testSlopeMF, interaction kk:sex is not significant, so slope across groups
# is not different
mod2MF <- lm(uu ~ kk + sex, data = allgfits_u)
testInterceptMF <- Anova(mod2MF, type='II')
# in testInterceptMF, sex is not significant (it;s 0.1084), so intercepts among 
# groups are not significant

# check between males, females, and all
options(contrasts=c("contr.treatment", "contr.ploy"))
mod1 <- lm(uu ~ kk + sex + kk:sex, data = allnice)
testSlope <- Anova(mod1, type='II')
mod2 <- lm(uu ~ kk + sex, data = allnice)
testIntercept <- Anova(mod2, type='II')

save(testSlopeMF, testInterceptMF, testSlope, testIntercept , 
	file=file.path(outputPath, paste0(Sys.Date(),  "-",  firstyr, "-", lastyr, "-", ageToStartFit,  "-Gamma-with-u-Anova.RData")));


### CHECK IF HAVE SAME SLOPE/INTERCEPT ########################################

mf <- allgfits_u[which(allgfits_u$sex %in% c("male", "female")),]

model1A <- lm(uu ~ kk + as.factor(sex), data = mf)
model2A <- lm(uu ~ kk, data = mf)
print(summary(model1A))
print(summary(model2A))
print(anova(model2A, model1A))

