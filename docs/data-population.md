## U.S. Census Data Processing

### Raw Data

The population data from the United States Census for the years 2000 and 2010 was downloaded from the (now decommissioned) United States Census Bureau American Fact Finder https://factfinder.census.gov/  website (accessed on 2018-10-21 and 2018-10-22).  We used the Advanced Search with the following options:

*	Topics -> People -> Age and Sex -> both "Age" and "Sex" selected
*   Topics -> Year -> Either 2000 or 2010 selected
*   Geographies -> Under "Select a geographic type", selected either "County - 050" or "State - 040" -> Selected the SEER counties within a single registry or selected the 12 states which have a SEER registry for the entire state - or Alaska

For instance, to obtain the information for the Detroit metropolitan area registry, the "County" geographic type was selected, and the three counties:'Macomb County, Michigan', 'Oakland County, Michigan', and 'Wayne County, Michigan'.  

The PCT12 or PCT012 file with sex and age by single year intervals was downloaded for each query, and PCT12C in the case of Alaska.  For Alaska, the population counts are restricted to American Indian/Alaska Native individuals.

The information about the state and counties in a SEER registry can be found from the [list on the SEER website](https://seer.cancer.gov/registries/list.html), as well as more detailed information in an [SEER manual appendix (2016)](https://seer.cancer.gov/archive/manuals/2016/SPSCM_2016_AppendixA.pdf).


### Raw Data Directory Structure

The files downloaded above are saved in the `data/population` folder, in two subfolders labelled `2000` and `2010`:

```
+---2000
|   +---2000-Alaska-native
|   |       aff_download_readme_ann.txt
|   |       DEC_00_SF1_PCT012C.txt
|   |       DEC_00_SF1_PCT012C_metadata.csv
|   |       DEC_00_SF1_PCT012C_with_ann.csv
|   |
|   +---2000-California-counties
|   |       aff_download_readme_ann.txt
|   |       DEC_00_SF1_PCT012.txt
|   |       DEC_00_SF1_PCT012_metadata.csv
|   |       DEC_00_SF1_PCT012_with_ann.csv
|   |
|   +---2000-Detroit-metro
|   |       aff_download_readme_ann.txt
|   |       DEC_00_SF1_PCT012.txt
|   |       DEC_00_SF1_PCT012_metadata.csv
|   |       DEC_00_SF1_PCT012_with_ann.csv
|   |
|   +---2000-Georgia-counties
|   |       aff_download_readme_ann.txt
|   |       DEC_00_SF1_PCT012.txt
|   |       DEC_00_SF1_PCT012_metadata.csv
|   |       DEC_00_SF1_PCT012_with_ann.csv
|   |
|   +---2000-states
|   |       aff_download_readme_ann.txt
|   |       DEC_00_SF1_PCT012.txt
|   |       DEC_00_SF1_PCT012_metadata.csv
|   |       DEC_00_SF1_PCT012_with_ann.csv
|   |
|   \---2000-Washington-counties
|           aff_download_readme_ann.txt
|           DEC_00_SF1_PCT012.txt
|           DEC_00_SF1_PCT012_metadata.csv
|           DEC_00_SF1_PCT012_with_ann.csv
|
\---2010
    +---2010-Alaska-native
    |       aff_download_readme_ann.txt
    |       DEC_10_SF1_PCT12C.txt
    |       DEC_10_SF1_PCT12C_metadata.csv
    |       DEC_10_SF1_PCT12C_with_ann.csv
    |
    +---2010-California-counties
    |       aff_download_readme_ann.txt
    |       DEC_10_SF1_PCT12.txt
    |       DEC_10_SF1_PCT12_metadata.csv
    |       DEC_10_SF1_PCT12_with_ann.csv
    |
    +---2010-Detroit-metro
    |       aff_download_readme_ann.txt
    |       DEC_10_SF1_PCT12.txt
    |       DEC_10_SF1_PCT12_metadata.csv
    |       DEC_10_SF1_PCT12_with_ann.csv
    |
    +---2010-Georgia-counties
    |       aff_download_readme_ann.txt
    |       DEC_10_SF1_PCT12.txt
    |       DEC_10_SF1_PCT12_metadata.csv
    |       DEC_10_SF1_PCT12_with_ann.csv
    |
    +---2010-states
    |       aff_download_readme_ann.txt
    |       DEC_10_SF1_PCT12.txt
    |       DEC_10_SF1_PCT12_metadata.csv
    |       DEC_10_SF1_PCT12_with_ann.csv
    |
    \---2010-Washington-counties
            aff_download_readme_ann.txt
            DEC_10_SF1_PCT12.txt
            DEC_10_SF1_PCT12_metadata.csv
            DEC_10_SF1_PCT12_with_ann.csv

```

### Processing Steps

Information for different registries is saved and then sourced for subsequent scripts from the R file [`popRegistryInfo.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/census-population/popRegistryInfo.R). 

The processing of the population files is done by running the following script in R, called from the working directory `scripts/census-population`:

```r
source('popProcessAll.R')
```

which calls four scripts to process the data from each of the Census years:

*   [`popStateProcessing.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/census-population/popStateProcessing.R):  Takes the raw data of population by single age years and sex for the state registries Connecticut, Hawaii, Idaho, Iowa, Kentucky, Louisiana, Massachusetts, New Jersey, New Mexico, New York, Utah, and Wisconsin, and produces a table. 

*   [`popRegionalProcessing.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/census-population/popRegionalProcessing.R):  Takes the raw data table of population by single age years and sex for the counties within regional registries Alaska, Atlanta, Rural Georgia, Greater Georgia, San Francisco, San Jose, Los Angeles, Greater California, Seattle-Puget Sound, and Detroit and produces a table.  For each registry, the population for a certain sex and year of age is summed over the counties forming that registry.

*   [`popCreateTables.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/census-population/popCreateTables.R): Creates summary 1 year and 5 year age-group tables for all registries.

*   [`popOlderFraction.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/census-population/popOlderFraction.R): Creates the table of the fraction of total 85+ population by gender, in each registry, in each of the groups 85-89, 90-94, 100-104, 105-109, and 100+. This table is the most important output, as it is the one used to estimate the registry population for each of these age groups.

Processed files are saved in the `outputs/population` directory.  Note that the files are saved with the system date as a prefix in the filename, so that subsequent scripts which load that data may need to be edited to have the updated date. 

### Older fraction by gender and registry

The output `.csv` files for the older fraction of the 85+ population for the 2000 Census (by different age groups and different registries) are given below:
#*   [Male](https://github.com/canghel/cancer-incidence-v5/blob/main/docs/2021-08-20-pop-85-fract-male-2000.csv)
#*   [Female](https://github.com/canghel/cancer-incidence-v5/blob/main/docs/2021-08-20-pop-85-fract-female-2000.csv)
#*   [Both](https://github.com/canghel/cancer-incidence-v5/blob/main/docs/2021-08-20-pop-85-fract-both-2000.csv)


[**Return to main page**](https://canghel.github.io/cancer-incidence-v5)