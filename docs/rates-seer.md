## Calculation of crude rate and confidence intervals	

The crude age-specific incidence rate is computed by dividing the the number of new cancer cases diagnosed for persons in a 5-year age group by the population at risk, and then multiplied by 100,000.  The rates are computed for both time periods 2000-2003 and 2010-2013.  The number of cancer cases and the susceptible population are from the geographical regions given by the 17 selected SEER cancer registries (omitting Alaska).

The difficulty in computing the age-specific rate is for the 'oldest old' category, where the population for the 5-year age groups older than 85 years has to be inferred using the Census data from the 17 registries.

The two-sided confidence intervals were computed as in Harding et al. (2008): "Where *x* is the count of new diagnoses and *n* is the person-years at risk, +/- 34.1% two-sided confidence intervals for incidence rates were calculated according to the normal distribution (for *x* > 10), according to the Poisson distribution (for *x* < 10 and *n* > 1000), and by exact binomial proportion (for *x* < 10 and *n* < 1,000)."

### Processing Steps

The following scripts compute the crude incidence rate and the confidence intervals in R, called from the working directory `scripts/incidence-seer`.  Note that data files were saved with the system date as a prefix in the filename, and thus scripts which load that data may need to be updated with the correct date.

```r
source('seerRunOneYear.R')
```

which calls three scripts to process each year (2000, 2001, 2002, 2003, 2010, 2011, 2012 and 2013) of SEER and Census data:

*   [`seerCountsOneYear.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer/seerCountsOneYear.R):  Creates tables of the number of case counts for each cancer type for all 5 year categories (including 85-90, 90-95, ..., 110+, the 'oldest old') as well as the population for 5-year categories up to "85+" category (i.e. 19 age grouped data, excluding the 'oldest old').

*   [`seerComparePopOneYear.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer/seerComparePopOneYear.R):  Calculates the ratios of SEER vs. census data for each registry, for each of the 19 age groups, and for each year.  The results confirmed that the Alaska registry had larger differences between the SEER vs. census population data, and was omitted from subsequent analysis.

*   [`seerInferPopOneYear.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer/seerInferPopOneYear.R): Infers population for each registry for the 5-year categories above age 85 (for 85-90, 90-95, ..., 110+, i.e. the 'oldest old').

```r
rm(list=ls())
source('seerMultipleYears.R')
rm(list=ls())
source('seerErrorCalulation.R')
```

The script [`seerMultipleYears.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer/seerMultipleYears.R) uses the tables generated for each year to generate a table of all the case counts, population, and crude rate for all 5-year intervals for the time periods 2000-2003 and 2010-2013.  Note: At the top of the script, the variables `year` and `popyear` have to be changed to indicate which time period to be calculated.


The script [`seerErrorCalulation.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer/seerErrorCalculation.R) computes confidence intervals for the crude rate, as described by (Harding et al. 2008). Note: At the top of the script, the variable `fileToLoad` (different for 2000 and 2010) has to be specified.

The processed tables and output are saved in the `outputs/seer/count-data` directory.

[**Return to main page**](https://canghel.github.io/cancer-incidence-v5)