# Assuming that the current directory is either plot-fits...

# LOAD DATA ----
extrinsicFactor <- read.csv('../../data/2021-02-04-extrinsic-factors.csv',
                            stringsAsFactors = F)
# Purpose: to examine the correlation between ratio of cumulative probabilities,
# SEER/2-term model, and the proportion contribution of extrinsic factors

# Distribution check ----
hist(extrinsicFactor$Extrinsic_MS_Total) # non-normal
hist(100/(100 - extrinsicFactor$Extrinsic_MS_Known)) # exponential
hist(extrinsicFactor$Both_Ratio) # weird...

# All cancers ----
# Both
bothRatioExtrinsic <- extrinsicFactor[, c('TCGA_Code', 
                                          'Extrinsic_MS_Total', 'Both_Ratio')]
bothRatioExtrinsic <- na.omit(bothRatioExtrinsic) # 13 points
plot(bothRatioExtrinsic$Extrinsic_MS_Total, bothRatioExtrinsic$Both_Ratio, 
     pch = 16,xlab = 'extrinsic contribution, both', ylab = 'ratio, both')
cor.test(bothRatioExtrinsic$Extrinsic_MS_Total, bothRatioExtrinsic$Both_Ratio, 
         alternative = 'two.sided', method = 'spearman')
# rho = 0.282, P = 0.35...

# Male
maleRatioExtrinsic <- extrinsicFactor[, c('TCGA_Code', 
                                          'Extrinsic_MS_Total', 'Male_Ratio')]
maleRatioExtrinsic <- na.omit(maleRatioExtrinsic) # 13 points
plot(maleRatioExtrinsic$Extrinsic_MS_Total, maleRatioExtrinsic$Male_Ratio, 
     pch = 16, xlab = 'extrinsic contribution, male', ylab = 'ratio, male')
cor.test(maleRatioExtrinsic$Extrinsic_MS_Total, maleRatioExtrinsic$Male_Ratio, 
         alternative = 'two.sided', method = 'spearman')
# rho = 0.024, P = 0.93

# Female
femaleRatioExtrinsic <- extrinsicFactor[, c('TCGA_Code', 
                                          'Extrinsic_MS_Total', 'Female_Ratio')]
femaleRatioExtrinsic <- na.omit(femaleRatioExtrinsic) # 13 points
plot(femaleRatioExtrinsic$Extrinsic_MS_Total, femaleRatioExtrinsic$Female_Ratio, 
     pch = 16, xlab = 'extrinsic contribution, female', ylab = 'ratio, female')
cor.test(femaleRatioExtrinsic$Extrinsic_MS_Total, 
         femaleRatioExtrinsic$Female_Ratio, 
         alternative = 'two.sided', method = 'spearman')
# rho = 0.098, P = 0.71

# Non-Reproductive ----
nonreproExtrinsic <- subset(extrinsicFactor, 
                            !TCGA_Code %in% c('PRAD', 'BRCA', 'CESC', 'OV',
                                              'UCS'))
nonreproExtrinsic <- na.omit(nonreproExtrinsic)
# both:
plot(rank(100/(100 - nonreproExtrinsic$Extrinsic_MS_Known)), 
     rank(nonreproExtrinsic$Both_Ratio), pch = 16, 
     xlab = 'rank of 1/(1 - known extrinsic ratio)', 
     ylab = 'rank of ratio of SEER to model-fitted', main = 'both')
print(cor.test(nonreproExtrinsic$Extrinsic_MS_Known, nonreproExtrinsic$Both_Ratio, 
               alternative = 'two.sided', method = 'spearman'))
# spearman's rho = 0.729, p-value = 0.0047
# Note: Spearman's correlation is the same even if one quantity undergoes 
# strictly increasing transformation.

# female:
plot(rank(100/(100 - nonreproExtrinsic$Extrinsic_MS_Known)), 
     rank(nonreproExtrinsic$Female_Ratio), pch = 16, 
     xlab = 'rank of 1/(1 - known extrinsic ratio)', 
     ylab = 'rank of ratio of SEER to model-fitted', main = 'female')
print(cor.test(nonreproExtrinsic$Extrinsic_MS_Known, nonreproExtrinsic$Female_Ratio, 
               alternative = 'two.sided', method = 'spearman'))
# spearman's rho = 0.633, p-value = 0.0203

# male: 
plot(rank(100/(100 - nonreproExtrinsic$Extrinsic_MS_Known)), 
     rank(nonreproExtrinsic$Male_Ratio), pch = 16, 
     xlab = 'rank of 1/(1 - known extrinsic ratio)', 
     ylab = 'rank of ratio of SEER to model-fitted', main = 'male')
print(cor.test(nonreproExtrinsic$Extrinsic_MS_Known, nonreproExtrinsic$Male_Ratio, 
               alternative = 'two.sided', method = 'spearman'))
# spearman's rho = 0.685, p-value = 0.0098