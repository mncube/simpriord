
<!-- README.md is generated from README.Rmd. Please edit that file -->

# simpriord

<!-- badges: start -->
<!-- badges: end -->

Using Bayesian models with informative priors is a common strategy to
deal with the limitations of statistical analysis with small sample
size. The goal of this package is to facilitate simulations of Bayesian
models which incorporate previous data (i.e., pilot data, publicly
available data, etc.) as prior information. The package is inspired by
three key resources.

The first resource is the Error Structures and Hyperparameters section
of Cheung & Szpak (2021):

“Informative priors can influence the outcome of a model, especially if
the data set is small. Here, our last case study aims to test: a) How
different error structures and intra-population groups compare with each
other b) How much could hyperparameters sway the SIMMs estimation c)
What is considered a sufficient sample size that is robust enough to
stand against poorly informed hyperparameters”

The second resource is paul.buerkner’s first two posts in the Setting
Informative Priors from Pilot Study for Lognormal Model thread on the
discourse.mc-stan.org forums
(<https://discourse.mc-stan.org/t/setting-informative-priors-from-pilot-study-for-lognormal-model/4741>):

"If you analyse your final data set including both data from pilot and
main study, I wouldn’t let the priors be informed too much by the data
of the pilot study, because then you end up including this data twice
into your model (one as data and one as prior).

If you have the raw data of previous studies available, I would usually
prefer putting all data into the same model (with extended structure)
instead of trying to use the posterior of one study as prior of the
other. The latter is really hard to do correctly."

“With extended structure I mean modeling that the data came from two
different studies (e.g., via an additional factor in the model) unless
the studies are exact replications with samples from the same
populeation.”

The third resource is Dr. Gregory L. Snow’s simulation code posted in
the \[R-sig-ME\] Poer Analysis for Multi-level Models thread on the
stat.ethz.ch forums
(<https://stat.ethz.ch/pipermail/r-sig-mixed-models/2009q1/001790.html>).

## Installation

You can install the development version of simpriord from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mncube/simpriord")
```

## Simulate from a linear model

Use the sim\_lm function to simulate one data frame from a linear model.

``` r
library(simpriord)

lm_df <- sim_lm()

head(lm_df)
#>   ID           Y         X1        X2 prior
#> 1  1  0.87907100  0.6940964 1.0285225     0
#> 2  2  2.08263253 -1.2326955 1.8371075     0
#> 3  3  3.07747250  1.2573891 0.7284891     0
#> 4  4  4.69034011  1.6593525 0.6841596     0
#> 5  5 -0.03583271 -0.1131599 1.1788107     0
#> 6  6  3.25112341 -0.6272886 2.9847338     0
```

## Citations

Cheung, C., & Szpak, P. (2021). Interpreting Past Human Diets Using
Stable Isotope Mixing Models. In Journal of Archaeological Method and
Theory (Vol. 28, Issue 4, pp. 1106–1142).
<https://doi.org/10.1007/s10816-020-09492-5>
