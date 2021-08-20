## Calculation of crude age-specific incidence rate and confidence intervals	

The crude age-specific incidence rate is computed by dividing the the number of new cancer cases diagnosed for persons in a 5-year age group by the population at risk, and then multiplied by 100,000.  The rates are computed for both time periods 2000-2003 and 2010-2013.  The number of cancer cases and the susceptible population are from the geographical regions given by the 17 selected SEER cancer registries (omitting Alaska).

The difficulty in computing the age-specific rate is for the 'oldest old' category, where the population for the 5-year age groups older than 85 years has to be inferred using the Census data from the 17 registries.

The two-sided confidence intervals were computed as in Harding et al. (2008): "Where *x* is the count of new diagnoses and *n* is the person-years at risk, +/- 34.1% two-sided confidence intervals for incidence rates were calculated according to the normal distribution (for *x* > 10), according to the Poisson distribution (for *x* < 10 and *n* > 1000), and by exact binomial proportion (for *x* < 10 and *n* < 1,000).")."

### Processing Steps

The following script is called to compute the crude incidence rate and the confidence intervals in R, called from the working directory `scripts/incidence-seer-tgca`. Note: At the top of the script, the variable `startyear` should be defined as either 2000 or 2010, indicating which time period is to be computed.  In addition, data files were saved with the system date as a prefix in the filename, and thus scripts which load that data may need to be updated with the correct date.

The processed tables and output are saved in the `outputs/seer-tcga/count-data` directory.

```r
source('seerTCGACounts.R')
```

The [`seerTCGACounts.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer-tcga/seerTCGACounts.R) script loops over every TGCA cancer type and calls three scripts, in order.

*   [`seerTCGACounts19Groups.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer-tcga/seerTCGACounts19Groups.R):  Creates tables (data frames) of the number of case counts and population for 5-year categories up to "85+" category (i.e. 19 age grouped data, excluding the 'oldest old') for one cancer type.


*   [`seerTCGACountsOlder.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer-tcga/seerTCGACountsOlder.R):  Creates tables (data frames) of the number of case counts and population for 5-year categories for ages 85-90, 90-95, ..., 110+, i.e. the 'oldest old' age categories for one cancer type.

*   [`seerTCGACountsPopCombine.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer-tcga/seerTCGACountsPopCombine.R): Combines the data from the 19 age groups and the oldest old, creating a table (data frame) for the given cancer type.

The tables from the different cancer types are concatenated to create one large table denoted `sumcounts`, with the columns Site, Sex, Age, Counts, Population and Crude Rate.  Then (still within the script `seerTCGACounts.R`, at the end):

*	[`seerTCGAErrorCalculation.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/incidence-seer-tcga/seerTCGAErrorCalculation.R) is called to compute confidence intervals for the crude age-specific rate and add columns indicating the lower and upper intervals to the `sumcounts` table.


[**Return to main page**](https://canghel.github.io/cancer-incidence-v5)