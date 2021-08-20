## Computing Curves of Best Fit

This section describes the code used to fit two models to the age-specific cancer incidence data for different cancer types. 

The first model is given in Harding et al (2018) by the equation

<a href="https://www.codecogs.com/eqnedit.php?latex=ASR(t)&space;=&space;a&space;\cdot&space;t^{k-1}&space;\cdot&space;(1-bt)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?ASR(t)&space;=&space;a&space;\cdot&space;t^{k-1}&space;\cdot&space;(1-bt)" title="ASR(t) = a \cdot t^{k-1} \cdot (1-bt)" /></a>

where 

<a href="https://www.codecogs.com/eqnedit.php?latex=0&space;\leq&space;t&space;<&space;(1/b)." target="_blank"><img src="https://latex.codecogs.com/gif.latex?0&space;\leq&space;t&space;<&space;(1/b)." title="0 \leq t < (1/b)." /></a>

The second model is described in our manuscript and is a version of the Harding model above with the inclusion of a multistage term that generalizes the term described in Armitage and Doll (1954): 

<a href="https://www.codecogs.com/eqnedit.php?latex=ASR(t)&space;=&space;u^k/\Gamma(k)&space;\cdot&space;t^{k-1}&space;\cdot&space;(1-bt)" target="_blank"><img src="https://latex.codecogs.com/gif.latex?ASR(t)&space;=&space;u^k/\Gamma(k)&space;\cdot&space;t^{k-1}&space;\cdot&space;(1-bt)" title="ASR(t) = u^k/\Gamma(k) \cdot t^{k-1} \cdot (1-bt)" /></a>

with the same bounds on *t*.  We called this second model the 'Gamma' model in the R scripts.

For the non-linear curve fits of both equations, we followed the methods in Harding et al. (2018).  That is, the points are weighted proportionally to the inverse standard error squared and fit beginning age 50.  (We however made a few exceptions for cancer types THCA, CESC, TGCT, Thyroid, Cervix Uteri, Testis, where the incidence peaks at much younger ages than most cancer types.) Furthermore, for reproductive cancers *t*=0 corresponds to age 15, rather than birth, which is estimated to be the onset of puberty. 


### Incidence Rates of TCGA Cancer Types

The following script is called to compute the fit of both models for the TCGA cancer types, for each of the periods 2000-2003 and 2010-2013, from the working directory `scripts/model-fits`. Note: The script may need to be modified with the correct date when the data was processed/saved. 

```r
source('fitAllTCGA.R')
```

The script loads the incidence data processed as described in the [Calculation of crude age-specific incidence rate and confidence intervals](rates-seer-tcga.md), and calls two scripts to perform the curve fitting. Both scripts use the nonlinear least squares Levenberg-Marquardt algorithm from the function `nlsLM` in the R library `minpack.lm` to perform the curve fit to the corresponding equation. 

*   [`fit03Harding.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/model-fits/fit03Harding.R): Performs curve fit of the equation from Harding et al. (2018).

*   [`fit04Gamma.R`](https://github.com/canghel/cancer-incidence-v5/blob/main/scripts/model-fits/fit04Gamma.R): Performs the curve fit for the second model, described in our manuscript.

The processed tables and output are saved in the `outputs/seer-tcga/fits` directory.

### Incidence Rates of Cancer Types in Previous Literature (Supplementary)

The following script is called to compute fit both models for the cancer types listed in the previous literature such as in Harding et al. (2018), for each of the periods 2000-2003 and 2010-2013, from the working directory `scripts/model-fits`. Note: The script may need to be modified with the correct date when the data was processed/saved. 

```r
source('fitAll.R')
```

This script loads the required data sets and calls the same two curve fitting scripts, `fit03Harding.R` and `fit04Gamma.R` as above.

The processed tables and output are saved in the `outputs/seer/fits` directory.


### Other Code

Additional scripts in the directory were for performing un-weighted and weighted fits to the equation in Pompei-Wilson which is slightly different.  The scripts are were not checked or maintained.  They remain in the directory for completeness.

[**Return to main page**](https://canghel.github.io/cancer-incidence-v5)