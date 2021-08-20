# Process the Census populations, in particular to obtain the older fractions
# in every registry

### CENSUS 2000 #############################################################

rm(list=ls())
year <- '2000';
dateSaved <- '2021-08-20'

print("=== Population processing for Census 2000 ==========================")
source("popStateProcessing.R");
source("popRegionalProcessing.R");
source("popCreateTables.R");
source("popOlderFraction.R");

### CENSUS 2010 #############################################################

rm(list=ls())
year <- '2010';
dateSaved <- '2021-08-20'

print("=== Population processing for Census 2010 ==========================")
source("popStateProcessing.R");
source("popRegionalProcessing.R");
source("popCreateTables.R");
source("popOlderFraction.R");

# Three warning about numerical data since spreadsheet contains corrections
# for totals (which don't affect male/female counts):
# - Detroit, Wayne county
# - Gerogia counties for within Atlanta and OtherGA registries