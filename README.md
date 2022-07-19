
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

# Get data to run one linear model
lm_df <- sim_lm()

# Preview data
head(lm_df$df_mod)
#>   ID          Y         X1         X2 prior
#> 1  1 -1.4109113 -0.4785356 -0.3565226     0
#> 2  2  2.2480429  0.1782073  1.7619481     0
#> 3  3 -0.2415839 -0.5319155  0.8521917     0
#> 4  4  0.1794103  0.2118967  1.1242433     0
#> 5  5 -0.1790108  0.4460750  0.8540424     0
#> 6  6  0.4062215 -1.0944565  1.3138604     0

# See model name and coefficients used to produce data
print(lm_df$df_info)
#>   b0 b1 b2 mod_name prior
#> 1  0  1  1      mod     0
```

Use the sim\_lm\_dfs function to generate a list of data frames each of
which contain main and previous data.

``` r
lm_dfs <- sim_lm_dfs(frames = 3,
                     mod_name = list("mod1", "mod2", "mod3"))

# Preview data for the second model
head(lm_dfs$df_mod[[2]])
#>   ID          Y         X1        X2 prior
#> 1  1  1.3606351  0.4941186 0.8848576     0
#> 2  2 -0.1563445 -0.7479628 0.4587837     0
#> 3  3  3.1631680  0.3326960 1.2400949     0
#> 4  4  3.6462709 -0.3812981 1.6691010     0
#> 5  5 -0.3957273 -1.0939094 1.1643046     0
#> 6  6  1.2977986 -0.6426761 0.7701330     0
tail(lm_dfs$df_mod[[2]])
#>    ID         Y         X1        X2 prior
#> 45 20 2.8047203 -0.9820452 2.0450992     1
#> 46 21 3.2504890  1.2662167 1.3723096     1
#> 47 22 3.7804471  1.2338800 1.2459707     1
#> 48 23 0.5212051 -0.4701133 0.9002691     1
#> 49 24 3.0463301  0.7166235 1.3495795     1
#> 50 25 1.9646444 -0.7336038 1.5226536     1

#See model name and coefficients used to produce second model data
print(lm_dfs$df_info[[2]])
#>   b0 b1 b2 mod_name prior
#> 1  0  1  1     mod2     0
#> 2  0  1  1     mod2     1
```

## Citations

Cheung, C., & Szpak, P. (2021). Interpreting Past Human Diets Using
Stable Isotope Mixing Models. In Journal of Archaeological Method and
Theory (Vol. 28, Issue 4, pp. 1106–1142).
<https://doi.org/10.1007/s10816-020-09492-5>
