## SEER Data Corresponding to TCGA Cancer Types

### Raw Data

We download the raw data as in the case [SEER data processing](data-seer.md), with the modification that we need to match the SEER ICD-O-3 Histology types to the TCGA cancer types.  For instance, rather than "Brain and Other Nervous System Cancers", we download the number of cases specifically for "Glioblastoma multiforme (GBM)" and "Brain lower grade glioma (LGG)". The correspondence of cancer types in TCGA and SEER site (histology) codes were taken from Wang et al. (2018).

### Custom Variable for ICD-O-3 Hist/behav

Some of the TCGA cancer types cover a large range of "ICD-O-3 Hist/behav" value.  For instance, for the BRCA cancer, the "Primary Site - labeled" variable takes values C50.0-C50.9 and the "ICD-O-3 Hist/behav" variable takes values 801-857. 

It is not possible to select all the values 801 to 857 separately.  Thus we create a custom variable as follows:

*    Click on the "Dictionary" icon (beside the question mark icon).
*    Select "Site and Morphology" -> "ICD-O-3 Hist/behav" and then click "Create..." button.
*    On the right, in the "Values" panel, highlight all the values from "8010/0: Epithelial tumor, benign" to "8576/3: Hepatoid andonocarcinoma".  (Since we have selected "Malignant behaviour" under the "Selection tab", it is okay to have non-malignant values highlighted. The correspondence between the 3 and 4 digit histology codes are given in the [ICD-O-3 Seer Site/Histology Validation List, March 2018](https://peerj.com/articles/6539/FileS2.ICD-O-03_list_2018.pdf).)
*    Click "Add all..." button.
*    Keep the default option "Added as one grouping (all values combined)".
*    Give this grouping a name (e.g. "Hist-801-to-857")
*    Give the variable a name as well, in the top left "Name:" box.  It could be the same as the grouping name.  
*    Click "Ok".  The variable name will now appear in the "User-Defined" variables.

Other value ranges of "ICD-O-3 Hist/behav" can be defined similarly.  We will filter our selections based on these user-defined variables as described below. 


#### Counts for ages < 85

To obtain the counts for ages less than 85, the data for the 19 age groups was downloaded using the following options in SeerStat Rate Session, for each of the years 2000 to 2003 and 2010 to 2013:

*    Statistic tab: 'Rates (Crude)'
*    Selection tab:
     *    Select Only: 'Malignant Behavior', 'Cases in Research Database', ('Known Age' is default)
     *    \{Race, Sex, Year, Registry, County, Year of diagnosis\}=(year)
     *    Other (Case Files):
          *    For the variable "Site and Morphology" -> "Primary Site - labeled", select "is = to" the primary sites corresponding to the TCGA cancer type.  For instance, for BRCA, the values "C50.0" to "C50.9" should be selected.
          *    We will also need to select a range for "ICD-O-3 Hist/behav".  In the case when this range has many values, we have to use a custom variable we have defined, and this will be found under the "User-Defined" folder.  For instance, for BRCA we would select "User-Defined" -> "Hist-801-to-857", and then "is = to Hist-801-to-857" in the "Values" box on the right.
     *    Check: 'Select Only the First Matching Record for Each Person'
*    Table tab (row):
     *   Race, Sex, Year Dx, Registry, County, -> SEER registy
     *   Race, Sex, Year Dx, Registry, County, -> Sex
     *   Age at Diagnosis -> Age recode with <1 year olds
*   Output tab:
     *   For the title, I used the TCGA code for all files corresponding to that cancer type.
     *   'Number of Decimal Places for Rates/Trends': 0.001
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

#### Counts for ages from 85 to 120

To obtain the counts for ages greater than 85, the data for each year of age at diagnosis, from 85 to 99, was downloaded using the following options in SeerStat Rate Session:

*   Statistic tab: 'Rates (Crude)'
*	Selection tab: 
	*	Select Only: 'Malignant Behavior', 'Cases in Research Database', ('Known Age' is default)
	*	\{Race, Sex, Year Dx, Registry, County, Year of diagnosis\}='2000','2001','2002',...,'2015'
	*    Other (Case Files):
		 *    For the variable "Site and Morphology" -> "Primary Site - labeled", select "is = to" the primary sites corresponding to the TCGA cancer type.
         *    Select a range for ICD-O-3 histology, usually using a custom variable as described above. 
	     *    \{Race and Age (case data only), Age at diagonsis\}=(age range, e.g. 85-89)
	*	Check: 'Select Only the First Matching Record for Each Person'
*  	Table tab (row):
	* 	Race, Sex, Year Dx, Registry, County, -> Year of diagnosis
	* 	Race, Sex, Year Dx, Registry, County, -> SEER registy
	* 	Race, Sex, Year Dx, Registry, County, -> Sex
*   Output tab: 'Number of Decimal Places for Rates/Trends': 0.001
*   Export options: as before

There will be a warning that only counts (not rates) will be output.

### Raw Data Directory Structure

The files downloaded above are saved in the `data/seer-tcga` folder, which has sub-folders for each of the TCGA cancer types:

```
+---seer-tcga
    +---ACC
    |       2000-2015-SEER-age-100-104.csv
    |       2000-2015-SEER-age-100-104.dic
    |       2000-2015-SEER-age-105-109.csv
    |       2000-2015-SEER-age-105-109.dic
    |       2000-2015-SEER-age-110-120.csv
    |       2000-2015-SEER-age-110-120.dic
    |       2000-2015-SEER-age-85-89.csv
    |       2000-2015-SEER-age-85-89.dic
    |       2000-2015-SEER-age-90-94.csv
    |       2000-2015-SEER-age-90-94.dic
    |       2000-2015-SEER-age-95-99.csv
    |       2000-2015-SEER-age-95-99.dic
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
    |       2013-SEER-19-age-groups.dic
    |
    +---BLCA
    |       2000-2015-SEER-age-100-104.csv
    |       2000-2015-SEER-age-100-104.dic
    |       2000-2015-SEER-age-105-109.csv
    |       2000-2015-SEER-age-105-109.dic
    |       2000-2015-SEER-age-110-120.csv
    |       2000-2015-SEER-age-110-120.dic
    |       2000-2015-SEER-age-85-89.csv
    |       2000-2015-SEER-age-85-89.dic
    |       2000-2015-SEER-age-90-94.csv
    |       2000-2015-SEER-age-90-94.dic
    |       2000-2015-SEER-age-95-99.csv
    |       2000-2015-SEER-age-95-99.dic
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
    |       2013-SEER-19-age-groups.dic
    |
    +---BRCA
    ...
```


[**Return to main page**](https://canghel.github.io/cancer-incidence-v5)