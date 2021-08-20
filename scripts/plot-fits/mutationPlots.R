### PREAMBLE ##################################################################

library(dplyr);
library(ggplot2);
library(scales);

newOutputPath <- "../../outputs/seer-tcga/mutations/"

### MUTATION DATA ##############################################################
### Iranzo et al data ---------------------------------------------------------

iranzodata <- rbind(c('ACC', 1.61162, 0.27344),
    c('BLCA',	3.0893, 	0.15423),
    c('BRCA',	1.61776, 	0.085528),
    c('CESC',	1.01874,	0.4296),
    c('COADREAD', 3.2367,	0.13767),
    c('ESCA',	1.719079, 	0.1923),
    c('GBM', 	1.50526, 	0.13749),
    c('HNSC',	2.27458,	0.12686),
    c('KICH',	0.6356, 	0.3287),		
    c('KIRC',	1.627012, 	0.24922),
    c('KIRP',	1.14122, 	0.33835),
    c('LAML',   2.13418,    0.25667),
    c('LGG',	2.00717, 	0.10643),
    c('LIHC',	1.38391, 	0.13425),
    c('LUAD', 	1.9522, 	0.12744),
    c('LUSC',	2.1929,		0.22592),
    c('MESO',   1.23538,    0.34942),
    c('OV',		1.3064, 	0.21015),
    c('PAAD',	2.44044,	0.31974),
    c('PCPG',   0.9368,     0.50116),
    c('PRAD',	0.83871, 	0.14),
    c('SARC',   1.26424,    0.15982),
    c('SKCM',	2.14658, 	0.13057),
    c('STAD',	1.05136,	0.12733),
    c('TGCT',	1.18911, 	0.24691),
    c('THCA',	1.05581, 	0.1945),
    c('THYM',   1.09844,    0.27907),
    c('UCEC',	3.7094, 	0.15353),
    c('UCS', 	2.50607,    0.32395)
    ) 
iranzodata <- data.frame(iranzodata, stringsAsFactors = FALSE)
colnames(iranzodata) <- c('tcga', 'idrivers', 'SE')
iranzodata$idrivers <- as.numeric(iranzodata$idrivers)
iranzodata$SE <- as.numeric(iranzodata$SE)
iranzodata$tcga = reorder(iranzodata$tcga, iranzodata$idrivers)

# paper lists the 7664 vs. 7665 cancers used in previous one, but
# only mentions the 3000 mut per genome values
# they used samples with <500 muts/exome for models
suppl2 <- data.frame(
    tcga = c('ACC', 'BLCA', 'BRCA', 'CESC', 'COADREAD',
        'ESCA', 'GBM', 'HNSC', 'KICH', 'KIRC',
        'KIRP', 'LAML', 'LGG', 'LIHC', 'LUAD',
        'LUSC', 'MESO', 'OV', 'PAAD', 'PCPG',
        'PRAD', 'SARC', 'SKCM', 'STAD', 'TGCT',
        'THCA', 'THYM', 'UCEC', 'UCS'),
    nn = c(91, 390, 702, 38, 266,
        180, 255, 507, 66, 314,
        275, 136, 467, 339, 367,
        167, 80, 262, 145, 178,
        497, 247, 437, 360, 142,
        438, 29, 233, 56),
    stringsAsFactors = FALSE)

iranzodata <- merge(iranzodata, suppl2, by.x='tcga', by.y='tcga');

# Bailey data from Richard's table --------------------------------------------

baileydata <- rbind(c('ACC', 0.52),
    c('BLCA',   5.10),
    c('BRCA',   1.84),
    c('CESC',   1.89),
    c('COADREAD', 3.84),
    c('ESCA',   1.87),
    c('GBM',    1.84),
    c('HNSC',   3.21),
    c('KICH',   0.48),        
    c('KIRC',   1.45),
    c('KIRP',   0.35),
    c('LAML',   0.77),
    c('LGG',    2.90),
    c('LIHC',   1.84),
    c('LUAD',   2.19),
    c('LUSC',   2.68),
    c('MESO',   0.87),
    c('OV',     1.19),
    c('PAAD',   2.19),
    c('PCPG',   NA),
    c('PRAD',   0.55),
    c('SARC',   0.63),
    c('SKCM',   2.45),
    c('STAD',   1.92),
    c('TGCT',   0.34),
    c('THCA',   0.77),
    c('THYM',   0.63),
    c('UCEC',   7.34),
    c('UCS',    3.13)
    ) 

baileydata  <- data.frame(baileydata , stringsAsFactors = FALSE)
colnames(baileydata) <- c('tcga', 'bdrivers')
baileydata$bdrivers <- as.numeric(baileydata$bdrivers)

### LOAD CURVE FIT DATA  ######################################################

load(file.path(inputPath, fileOfResults));

firstyr <- strsplit(fileOfResults, '-')[[1]][4]
lastyr <- strsplit(fileOfResults, '-')[[1]][5]
ageToStartFit <- as.numeric(strsplit(fileOfResults, '-')[[1]][6])

femalecolor <- "red3" # "#D73027"
malecolor <- "dodgerblue4" #"#4575B4" 
bothcolor <- "black"

load(file.path(inputPath, fileOfCleanTable));

df <- allnice_2Term[which(allnice$sex=="both" | allnice$Site %in% c(malecancers, femalecancers)), ]
dfsubset <- df[, c("sex", "Site", "uu", "kk", "ratio")]

if (firstyr==2010){
    excluded <- c("LGG", "PCPG")
} 
if (firstyr==2000){
    excluded <- c("ACC", "LGG", "PCPG")
}

dfsubset <- dfsubset[which(!(dfsubset$Site %in% excluded)), ]

### MERGE DATA  ###############################################################

muts <- merge(iranzodata, baileydata, by.x = "tcga", by.y="tcga")
muts <- merge(muts, dfsubset, by.x="tcga", by.y="Site")
muts$idiff <- muts$kk - muts$idrivers
muts$bdiff <- muts$kk - muts$bdrivers

mutsformatted <- muts[, c("tcga", "idrivers", "bdrivers", "kk", "idiff", "bdiff")]
mutsformatted$idrivers <- round(mutsformatted$idrivers, 2)
mutsformatted$kk <- round(mutsformatted$kk, 2)
mutsformatted$idiff <- round(mutsformatted$idiff, 2)
mutsformatted$bdiff <- round(mutsformatted$bdiff, 2)

write.table(mutsformatted,
    file.path(newOutputPath, paste0(Sys.Date(), "-", firstyr, "-", lastyr, "-", ageToStartFit, "-mutation-table-formatted.csv")),
    sep = ",",
    quote = FALSE,
    col.names = TRUE,
    row.names = FALSE
    )

# LINEAR FIT AND PLOT #########################################################

#  barplot(rstandard(lmfiti), names = muts$tcga, cex.names =0.6); abline(h=2, col="red")
lmfiti <- lm(idrivers ~ kk, muts)
#print(summary(lmfiti))
outliersi <- which(abs(rstandard(lmfiti)) > 2)
print(paste("Outliers for Iranzo drivers:", muts$tcga[outliersi]))

lmfitb <- lm(bdrivers ~ kk, muts)
#print(summary(lmfitb))
rstandard(lmfitb)
outliersb <- which(abs(rstandard(lmfitb)) > 2)
print(paste("Outliers for Bailey drivers:", muts$tcga[outliersb]))

badidxi <- which(abs(rstandard(lmfiti)) > 2)
badidxb <- which(abs(rstandard(lmfitb)) > 2)

print(badidxi)
print(badidxb)

if (badidxi==badidxb){
    badidx = badidxi

    mutsnew <- muts[-badidx, ]
    lmfitinew <- lm(idrivers ~ kk, mutsnew)
    print(summary(lmfitinew))
    lmfitbnew <- lm(bdrivers ~ kk, mutsnew)
    print(summary(lmfitbnew))

    # Plotting options and set up ---------------------------------------------

    muts$color <- rep(bothcolor, nrow(muts))
    muts$color[which(muts$tcga %in% femalecancers)] <- femalecolor
    muts$color[which(muts$tcga %in% malecancers)] <- malecolor

    muts$pch <- rep(16, nrow(muts))
    muts$pch[which(muts$tcga %in% femalecancers)] <- 17
    muts$pch[which(muts$tcga=="UCEC")] <- 2
    muts$pch[which(muts$tcga %in% malecancers)] <- 15

    labelSize <- 2.3
    axisSize <- 1.7
    pointSize <- 2  
    textSize <- 2

    xx <- seq(0.2, 11, 0.1)
    yy <- coef(lmfitinew)[2]*xx + coef(lmfitinew)[1];


    ### PLOT ##################################################################

    tiff(file.path(newOutputPath, paste0(Sys.Date(), "-drivers-Iranzo-vs-k-TCGA-", 
        firstyr, "-", lastyr,  "-", ageToStartFit, ".tiff")),
        height = 4,
        width = 5,
        units = 'in',
        res = 400,
        pointsize = 6
        );
    par(mar=c(5.1, 5.1, 4.1, 2.1))
    plot(muts$kk, muts$idrivers, 
        col = scales::alpha(muts$color, 0.4),
        pch = muts$pch, 
        ylab = bquote("Number of driver mutations, " ~ italic("y")), ,
        xlab = bquote("Stages, " ~ italic("k")),
        xlim = c(0.5, 10.5),
        ylim = c(0, 4.7),
        cex.lab = labelSize,
        cex.axis = axisSize,
        cex = muts$nn/100
        );
    lines(xx, yy, lty=3)
    points(muts$kk, 
        muts$idrivers, 
        pch = muts$pch, 
        col = scales::alpha(muts$color, 0.4),
        cex = muts$nn/100
    )
    offsetx <- rep(0.41, nrow(muts))
    offsety <- rep(0.08, nrow(muts))
    #idx <- which(muts$tcga=="BRCA"); offsety[idx] <- 0.03; offsetx[idx] <- 0; 
    idx <- which(muts$tcga=="BRCA"); offsety[idx] <- 0.13; offsetx[idx] <- 0.48; 
    idx <- which(muts$tcga=="CESC"); offsety[idx] <- 0.03; offsetx[idx] <- 0.37;
    idx <- which(muts$tcga=="COADREAD"); offsety[idx] <- 0.15; offsetx[idx] <- 0.55;
    idx <- which(muts$tcga=="OV"); offsety[idx] <- 0.03; offsetx[idx] <- 0.27; 
    idx <- which(muts$tcga=="UCS"); offsetx[idx] <- 0.1; offsetx[idx] <- 0.28; 
    idx <- which(muts$tcga=="KIRC"); offsety[idx] <- 0.12; offsetx[idx] <- 0.37; 
    idx <- which(muts$tcga=="GBM"); offsetx[idx] <- 0.35; 
    idx <- which(muts$tcga=="LUSC"); offsety[idx] <- 0.12; offsetx[idx] <- 0.37; 
    idx <- which(muts$tcga=="LGG"); offsety[idx] <- 0.15; offsetx[idx] <- 0.44; 
    idx <- which(muts$tcga=="THCA"); offsety[idx] <- 0.13; offsetx[idx] <- 0.44; 
    idx <- which(muts$tcga=="HNSC"); offsety[idx] <- 0.1; offsetx[idx] <- 0.55; 
    idx <- which(muts$tcga=="SKCM"); offsety[idx] <- 0.15; offsetx[idx] <- 0.44; 
    idx <- which(muts$tcga=="BLCA"); offsety[idx] <- 0.12; offsetx[idx] <- 0.44; 
    idx <- which(muts$tcga=="STAD"); offsety[idx] <- 0.11; offsetx[idx] <- 0.42; 
    idx <- which(muts$tcga=="MESO"); offsety[idx] <- 0.12; offsetx[idx] <- 0.02
    idx <- which(muts$tcga=="THYM"); offsety[idx] <- 0.02; offsetx[idx] <- 0.32
    idx <- which(muts$tcga=="KIRP"); offsety[idx] <- 0.08; offsetx[idx] <- 0.37
    idx <- which(muts$tcga=="PAAD"); offsety[idx] <- 0.08; offsetx[idx] <- 0.37
    idx <- which(muts$tcga=="ESCA"); offsety[idx] <- -0.08; offsetx[idx] <- 0.37
    idx <- which(muts$tcga=="LAML"); offsety[idx] <- 0.06; offsetx[idx] <- 0.39
    idx <- which(muts$tcga=="PRAD");  offsety[idx] <- 0; offsetx[idx] <- 0.56;
    idx <- which(muts$tcga=="KICH"); offsety[idx] <- -0.06; offsetx[idx] <- 0.3
    for (jj in 1:nrow(muts)){
        text(muts$kk[jj]+offsetx[jj], muts$idrivers[jj]+offsety[jj], muts$tcga[jj])
    }
    text(0.35, 4.5, bquote(italic("y") == .(round(coef(lmfitinew)[2], digits=2)) ~ italic("k") ~ " + " ~ .(round(coef(lmfitinew)[1], digits=2))), pos=4, cex=textSize)
    text(0.35, 4.1, bquote(italic("R")^2 == .(round(summary(lmfitinew)$r.squared, 3))), pos=4, cex=textSize)
    text(0.35, 3.7, bquote(italic("P") == .(format(summary(lmfitinew)$coefficients[8], digits=2))), pos=4, cex=textSize)
    dev.off()

    print("--- Iranzo Pearson's cor --------- ")
    print(nrow(mutsnew))
    print(cor.test(mutsnew$kk, mutsnew$idrivers, method="pearson"))
    print("--- Bailey Pearson's cor --------- ")
    print(nrow(mutsnew))
    print(cor.test(mutsnew$kk, mutsnew$bdrivers, method="pearson"))
}
