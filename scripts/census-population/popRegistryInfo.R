### INFORMATION ON THE REGISTRIES, INPUT BY HAND... ###########################
# So have to check these carefully

### INFO ON STATE REGISTRIES ##################################################

stateRegInfo <- data.frame(
	state = c('Connecticut', 'Hawaii', 'Idaho', 'Iowa', 'Kentucky',
		'Louisiana', 'Massachusetts', 'New Jersey', 'New Mexico', 'New York',
		'Utah', 'Wisconsin'),
	abbrev = c('CT', 'HI', 'ID', 'IA', 'KY',
		'LA', 'MA', 'NJ', 'NM', 'NY',
		'UT', 'WI'),
	seer = c('9', '9', 'NA', '9', '18',
		'18', 'NA', '18', '9', 'NA',
		'9', 'NA'),
	stringsAsFactors = FALSE
	);

# Revised counts --------------------------------------------------------------
# For 2000: none
# For 2010: only in the total counts, which aren't used.
#	- Idaho: 1567582 -> 1567652
#	- New Jersey: 8791894 -> 8791909
#	- New Mexico: 2059179 -> 2059181


### INFO ON REGIONAL REGISTIRES ###############################################

regionalRegInfo <- data.frame(
	region = c('Alaska', 'Atlanta', 'SanFrancisco', 'Seattle', 
		'LosAngeles', 'SanJose', 'RuralGA', 'OtherCA', 'OtherGA', 'Detroit'),
	seer = c('13', '9', '9', '9', 
		'13', '13', '13', '18', '18', '9'),
	stringsAsFactors = FALSE
	)

# Folders and regions --------------------------------------------------------

# the structure of the data, to make loading easier
# a folder for one state/region sometimes has multiple registries
regionalList <- NULL
regionalList[['Georgia-counties']] = c('Atlanta', 'RuralGA', 'OtherGA')
regionalList[['California-counties']] = c('SanFrancisco', 'LosAngeles', 
	'SanJose', 'OtherCA');
regionalList[['Washington-counties']] = c('Seattle')
regionalList[['Detroit-metro']] = c('Detroit')
regionalList[['Alaska-native']] = c('Alaska')

# Counties in each region ----------------------------------------------------

# Some counties were selected when downloading the data (so do not need to be
# selected in the code as well)
countyList <- NULL

# Georgia registries ----------------------------------------------------------
countyList[['Atlanta']] <- c('Clayton County, Georgia',
	'Cobb County, Georgia',
	'DeKalb County, Georgia', # correction in total only
	'Fulton County, Georgia', # correction in total only
	'Gwinnett County, Georgia'
	);

countyList[['RuralGA']] <- c('Glascock County, Georgia',
	'Greene County, Georgia',
	'Hancock County, Georgia',
	'Jasper County, Georgia',
	'Jefferson County, Georgia',
	'Morgan County, Georgia',
	'Putnam County, Georgia',
	'Taliaferro County, Georgia',
	'Warren County, Georgia',
	'Washington County, Georgia'
	);

# California registries ------------------------------------------------------
countyList[['SanFrancisco']] <- c('Alameda County, California',
	'Contra Costa County, California',
	'Marin County, California',
	'San Francisco County, California',
	'San Mateo County, California'
	);

countyList[['SanJose']] <- c('Monterey County, California',
	'San Benito County, California',
	'Santa Clara County, California',
	'Santa Cruz County, California'
	);

countyList[['LosAngeles']] <- c('Los Angeles County, California');

# Washington state  -----------------------------------------------------------

countyList[['Seattle']] <- c('Clallam County, Washington',
	'Grays Harbor County, Washington',
	'Island County, Washington',
	'Jefferson County, Washington',
	'King County, Washington',
	'Kitsap County, Washington',
	'Mason County, Washington',
	'Pierce County, Washington',
	'San Juan County, Washington',
	'Skagit County, Washington',
	'Snohomish County, Washington',
	'Thurston County, Washington',
	'Whatcom County, Washington'
	);

# Metropolitan Detroit --------------------------------------------------------

countyList[['Detroit']] <- c('Macomb County, Michigan', 
	'Oakland County, Michigan', 
	'Wayne County, Michigan'
	);

# Alaska

countyList[['Alaska']] <- c('Alaska')
