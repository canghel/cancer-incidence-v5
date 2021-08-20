## Figures

For all figures, the working directory should be `scripts/plot-fits`.

### Figures of Incidence, Age of Peak Incidence vs. *k*, and Stage Transition Rate *u* vs. *k* for TCGA Cancer Types

The following script loads the parameters from the curve fits for the 'Gamma' fit described in [Model fits](model-fits.md), and produces plots, including those for Figure 1 and Figure 2 in the manuscript (as well as analogous plots for the 2000-2003 data set).  All figures and table outputs are saved in the directory `outputs/seer-tcga/fits/fit04-Gamma`.

```r
source('fitPlotsTCGAGamma.R')
```

The script above calls three scripts to perform plotting:

*   [`fit04Gamma01_Incidence.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/plot-fits/fit04Gamma01_Incidence.R): Creates cancer incidence plots for every TCGA cancer type.

*   [`fit04Gamma02_UvsK.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/plot-fits/fit04Gamma02_UvsK.R): Plots the geometric mean of the stage transition rate *u* vs. the number of stages *k*, and fits a linear regression.  Also, performs ANOVA on the trends from the male and female data, to check if the slopes and intercepts differ significantly.

*   [`fit04Gamma03_AgeK.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/plot-fits/fit04Gamma03_AgeK.R): Plots the age of peak cancer incidence vs. the number of stages *k*.

### Figure of the Two-Variable Model

The following command generates Figure 3 in the manuscript, of the trend of age-specific cancer incidence vs. age for hypothetical cancers of different stages *k* using the two-variable model.  The two variable model is too general to fit the SEER data, and produces very poor fits.  The plot is generated to illustrate possible idealized trends.  The figure is saved in the directory `outputs/seer-tcga/fits/fit04-Gamma`.

```r
rm(list=ls())
source('twoVariableModelPlot.R')
```

### Figure of Driver Mutations vs. *k*

The following script generates Figure 4 in the manuscript (as well as an analogous figure for the 2000-2003 data), of the number of mutations as assessed by Iranzo et al (2018) plotted against the values of *k* for each TCGA cancer type.  The figure and outputs are saved in the directory `outputs/seer-tcga/mutations`.

```r
rm(list=ls())
source('runMutationPlots.R')
```

The script above loads either the 2000-2003 or 2010-2013 data, then calls the following script, which generates the plot.  

*   [`mutationPlots.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/plot-fits/mutationPlots.R): Plots number of driver mutations estimated in Iranzo et al (2018) vs. *k*.


### Figure of  *k* for Prostate Cancer vs. Time (Supplementary)

The following script generates Figure S1 in the Supplementary Files, showing the trend of the parameter *k*, from the model of Harding et al. (2008), given different cohorts over time, for prostate cancer (as well as lung cancer). 

```r
rm(list=ls())
source("kvsTimeProstateLung.R")
```

### Additional Plots (Not Included in Manuscript)

To obtain figures of the age-specific cancer incidence rate for cancer types in previous literature, as well as plots of the age of peak incidence vs. *k*, etc. the following code can be run.  Outputs are saved in `outputs/seer/fits`.

```r
rm(list=ls())
source('fitPlots.R')
```

Furthermore, plots of the Harding model for TCGA cancer types can be run using the following code, which also generates the plots for the 'Gamma' model.

```r
rm(list=ls())
source('fitPlotsTCGA.R')
```

## Computations

Many of the statistical computations are already included in the previous scripts, but there are a few additional computations included in the manuscript.  As above, the working directory should be `scripts/plot-fits`.

### Computations of Means, t-Tests, etc.

The computations were run interactively, so not all results will be output to file or to the screen.  Different lines from the script may be commented out to isolate a certain calculation.  The script called is:

```r
rm(list=ls())
source('runSmallCalculations.R')
```

The following three scripts are called:

*   [`smallCalculationsBK`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/plot-fits/smallCalculationsBK.R): Computes means, SD of the parameters *b* and *k* for males, females and both sexes pooled.  Compares the values of these parameters for male/females reproductive vs. non-reproductive cancers using t-tests.

*   [`smallCalculationsProb.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/plot-fits/smallCalculationsProb.R): Computes the cumulative probability for males and females of being diagnosed with at least one of the cancers considered. 

*   [`smallCalculationsPairedComparison.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/plot-fits/smallCalculationsPairedComparison.R): Computes the last three rows of Table 1 in the manuscript, which are the paired t-tests between the parameters computed for male vs. female non-reproductive cancers.


### Extrinsic factors

The following script computes the correlation between ratio of cumulative probabilities, SEER/2-term model, and the proportion contribution of extrinsic factors.

```r
rm(list=ls())
source('smallCalculationsExtrinsic.R')
```

[**Return to main page**](https://canghel.github.io/cancer-incidence-v5)