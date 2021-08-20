### INFO ON SEER THAT IS COMMON TO SCRIPTS ####################################
# Need to check carefully

### SITES OF INTEREST #########################################################

tcgaTypes <- c('ACC', 'BLCA', 'BRCA', 'CESC', 'COAD', 'ESCA', 'GBM', 'HNSC', 
  'KICH', 'KIRC', 'KIRP', 'LAML', 'LGG', 'LIHC', 'LUAD', 'LUSC', 'MESO', 'OV', 
  'PAAD', 'PCPG', 'PRAD', 'READ', 'SARC', 'SKCM', 'STAD', 'TGCT', 'THCA', 'THYM', 
  'UCEC', 'UCS');

malecancers <- c("PRAD", "TGCT")
femalecancers <- c("BRCA", "CESC", "OV", 'UCEC', 'UCS')

### SEER REGISTRIES SUBSET ####################################################

seer18butAK <- c("Atlanta_9", "CT_9", "Detroit_9", "HI_9", "IA_9", "KY_18" , "LA_18",  
    "LosAngeles_13", "NJ_18" , "NM_9", "OtherCA_18", "OtherGA_18", "RuralGA_13",
    "SanFrancisco_9",  "SanJose_13" , "Seattle_9", "UT_9");

seer13butAK <- c("Atlanta_9", "CT_9", "Detroit_9", "HI_9", "IA_9",  
    "LosAngeles_13", "NM_9",  "RuralGA_13", 
    "SanFrancisco_9",  "SanJose_13" , "Seattle_9", "UT_9");

### MIDPOINT OF AGE INTERVALS ##################################################

# in older ages the midpoint may be skewed more towards younger age...
ages <- c((0+4)/2, (5+9)/2, (10+14)/2, (15+19)/2, (20+24)/2,
  (25+29)/2, (30+34)/2, (35+39)/2, (40+44)/2,
  (45+49)/2, (50+54)/2, (55+59)/2, (60+64)/2,
  (65+69)/2, (70+74)/2, (75+79)/2, (80+84)/2,
  (85+89)/2, (90+94)/2, (95+99)/2, (100+104)/2,
  (105+109)/2, (110+119)/2);
ages <- ages + 0.5;