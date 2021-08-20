## SEER Data Processing

### Raw Data

The Surveillance, Epidemiology, and End Results (SEER) Program data was downloaded using [SEERStat](https://seer.cancer.gov/seerstat/) 8.3.5, Built March 5, 2018.  

The following database was selected: Surveillance, Epidemiology, and End Results (SEER) Program ([www.seer.cancer.gov](https://seer.cancer.gov/)) SEER\*Stat Database: Incidence - SEER 18 Regs Research Data + Hurricane Katrina Impacted Louisiana Cases, Nov 2017 Sub (2000-2015) <Katrina/Rita Population Adjustment> - Linked To County Attributes - Total U.S., 1969-2016 Counties, National Cancer Institute, DCCPS, Surveillance Research Program, released April 2018, based on the November 2017 submission. Age recode with <1 year olds. 

The dates downloaded were from years 2000-2003 and 2010-2013.  The restriction to these years was to allow the Census estimates from 2000 and 2010 to be used for the estimation of the population at risk, to use the SEER 18 data for all the calculations, and to allow reasonable comparison to previous literature. 

#### Counts for ages < 85

To obtain the counts for ages less than 85, the data for the 19 age groups was downloaded using the following options in SeerStat Rate Session, for each of the years 2000 to 2003 and 2010 to 2013:

*    Statistic tab: 'Rates (Crude)'
*    Selection tab:
     *    Select Only: 'Malignant Behavior', 'Cases in Research Database', ('Known Age' is default)
     *    \{Race, Sex, Year, Registry, County, Year of diagnosis\}=(year)
     *    Check: 'Select Only the First Matching Record for Each Person'
*    Table tab (row):
     *  Race, Sex, Year Dx, Registry, County, -> SEER registy
     *  Site and Morphology -> Site reocde ICD-0-3/WHO 2003
     *  Race, Sex, Year Dx, Registry, County, -> Sex
     *  Age at Diagnosis -> Age recode with <1 year olds
*   Output tab: 'Number of Decimal Places for Rates/Trends': 0.001
*   Export options:
	*	GZipped=false
	* 	Variable format=quotedlabels
	*	File format=UNIX
	*	Field delimiter=comma
	*	Missing character="NA"
	*	Fields with delimiter in quotes=true
	*	Remove thousands separators=true
	*	Flags included=false
	*	Variable names included=true
	*	Column Variables as Stats=false

#### Counts for ages from 85 to 99

To obtain the counts for ages greater than 85, the data for each year of age at diagnosis, from 85 to 99, was downloaded using the following options in SeerStat Rate Session:

*   Statistic tab: 'Rates (Crude)'
*	Selection tab: 
	*	Select Only: 'Malignant Behavior', 'Cases in Research Database', ('Known Age' is default)
	*	{Race, Sex, Year Dx, Registry, County, Year of diagnosis}='2000','2001','2002',...,'2015'
	*   {Race and Age (case data only), Age at diagonsis}=(age)
	*	Check: 'Select Only the First Matching Record for Each Person'
*  	Table tab (row):
	* 	Race, Sex, Year Dx, Registry, County, -> Year of diagnosis
	* 	Race, Sex, Year Dx, Registry, County, -> SEER registy
	* 	Site and Morphology -> Site recode ICD-0-3/WHO 2003
	* 	Race, Sex, Year Dx, Registry, County, -> Sex
*   Output tab: 'Number of Decimal Places for Rates/Trends': 0.001
*   Export options: as before

There will be a warning that only counts (not rates) will be output.

#### Counts for ages from 100 to 110+

For the oldest population, the process is the same as for counts for ages from 85 to 99, except that rather than a single age, the {Race and Age (case data only), Age at diagonsis} variable is set to one of the ranges: '100-104', '105-109', '110-120'.


### Raw Data Directory Structure

The files downloaded above are saved in the `data/seer` folder:

```
+---seer
|       2000-2015-SEER-age-100-104.csv
|       2000-2015-SEER-age-100-104.dic
|       2000-2015-SEER-age-105-109.csv
|       2000-2015-SEER-age-105-109.dic
|       2000-2015-SEER-age-110-120.csv
|       2000-2015-SEER-age-110-120.dic
|       2000-2015-SEER-age-85.csv
|       2000-2015-SEER-age-85.dic
|       2000-2015-SEER-age-86.csv
|       2000-2015-SEER-age-86.dic
|       2000-2015-SEER-age-87.csv
|       2000-2015-SEER-age-87.dic
|       2000-2015-SEER-age-88.csv
|       2000-2015-SEER-age-88.dic
|       2000-2015-SEER-age-89.csv
|       2000-2015-SEER-age-89.dic
|       2000-2015-SEER-age-90.csv
|       2000-2015-SEER-age-90.dic
|       2000-2015-SEER-age-91.csv
|       2000-2015-SEER-age-91.dic
|       2000-2015-SEER-age-92.csv
|       2000-2015-SEER-age-92.dic
|       2000-2015-SEER-age-93.csv
|       2000-2015-SEER-age-93.dic
|       2000-2015-SEER-age-94.csv
|       2000-2015-SEER-age-94.dic
|       2000-2015-SEER-age-95.csv
|       2000-2015-SEER-age-95.dic
|       2000-2015-SEER-age-96.csv
|       2000-2015-SEER-age-96.dic
|       2000-2015-SEER-age-97.csv
|       2000-2015-SEER-age-97.dic
|       2000-2015-SEER-age-98.csv
|       2000-2015-SEER-age-98.dic
|       2000-2015-SEER-age-99.csv
|       2000-2015-SEER-age-99.dic
|       2000-SEER-19-age-groups.csv
|       2000-SEER-19-age-groups.dic
|       2001-SEER-19-age-groups.csv
|       2001-SEER-19-age-groups.dic
|       2002-SEER-19-age-groups.csv
|       2002-SEER-19-age-groups.dic
|       2003-SEER-19-age-groups.csv
|       2003-SEER-19-age-groups.dic
|       2010-SEER-19-age-groups.csv
|       2010-SEER-19-age-groups.dic
|       2011-SEER-19-age-groups.csv
|       2011-SEER-19-age-groups.dic
|       2012-SEER-19-age-groups.csv
|       2012-SEER-19-age-groups.dic
|       2013-SEER-19-age-groups.csv
\       2013-SEER-19-age-groups.dic
```


[**Return to main page**](https://canghel.github.io/cancer-incidence-v5)