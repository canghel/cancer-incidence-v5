## Introduction

This site gives a detailed description data and code associated to the manuscript "Profound synchrony of age-specific incidence rates and tumor suppression for different cancer types as revealed by the multistage-senescence model of carcinogenesis" by Richard B. Richardson, Catalina V. Anghel and Dennis Siyuan Deng. 

A general description of the methods is given in the manuscript. The focus in these pages is the description of the data acquisition and instructions to run the code, which may not be easy to understand without the context provided in the manuscript.

## Methods

The files in the repository are organized in a fixed [directory structure](directory-structure.md), and R scripts use relative paths to make the code more portable. Scripts may return errors if the directory structure does not match this.

The GitHub repository does not contain the data files, as the user requires an approved research use agreement from the Surveillance, Epidemiology, and End Results Program (SEER).  Census data in this manuscript is publicly available, but since certain population counts are very small, we have also omitted the raw Census data at this time.

<!---
grep -r "library" . | cut -d ":" -f 2 | sort | uniq
-->

For the code, R version 3.6.0 was used along with the following R libraries:

```r
library(RColorBrewer)
library(car)
library(dplyr)
library(foreach)
library(futile.logger)
library(ggplot2)
library(gplots)
library(minpack.lm)
library(scales)
library(tidyr)
```

### Data Processing 

#### Corresponding to TCGA Cancer Types

These methods were used to process the SEER and Census data and compute crude age-specific incidence rates for cancers that match the TCGA cancer types.

*  [U.S. Census data processing](data-population.md)
*  [SEER data processing for TCGA cases](data-seer-tcga.md)
*  [Calculation of crude age-specific incidence rate and confidence intervals](rates-seer-tcga.md)

#### Corresponding to Cancer Types in Previous Literature (Supplementary)

These methods were used for the Supplementary tables and results.  The cancer types match the types in previous research by Pompei and Wilson (2001), Harding et al. (2008), Harding, Pompei and Wilson (2011).

*  [SEER data processing cancer types from previous literature](data-seer.md)
*  [Calculation of crude age-specific incidence rate and confidence intervals](rates-seer.md)

### Curves of Best Fit

The R scripts used to find the curves of best fit for both and the original Harding et al (2008) model 

<a href="https://www.codecogs.com/eqnedit.php?latex=ASR(t)&space;=&space;a&space;\cdot&space;t^{k-1}&space;\cdot&space;(1-bt)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?ASR(t)&space;=&space;a&space;\cdot&space;t^{k-1}&space;\cdot&space;(1-bt)" title="ASR(t) = a \cdot t^{k-1} \cdot (1-bt)" /></a>

and the model presented in our manuscript, 

<a href="https://www.codecogs.com/eqnedit.php?latex=ASR(t)&space;=&space;u^k/\Gamma(k)&space;\cdot&space;t^{k-1}&space;\cdot&space;(1-bt)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?ASR(t)&space;=&space;u^k/\Gamma(k)&space;\cdot&space;t^{k-1}&space;\cdot&space;(1-bt)" title="ASR(t) = u^k/\Gamma(k) \cdot t^{k-1} \cdot (1-bt)" /></a>

where 

<a href="https://www.codecogs.com/eqnedit.php?latex=0&space;\leq&space;t&space;<&space;(1/b)." target="_blank"><img src="https://latex.codecogs.com/gif.latex?0&space;\leq&space;t&space;<&space;(1/b)." title="0 \leq t < (1/b)." /></a>

described in the link below.

*  [Model fits](model-fits.md)

### Figures and Analysis

Code for the figures and various calculations in the manuscript is described in the link below.

*  [Figures and Computations](plot-fits.md)

