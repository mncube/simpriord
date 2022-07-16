
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
#>   ID          Y          X1         X2 prior
#> 1  1 -0.3401712  0.06880092 -0.2009139     0
#> 2  2  1.9327134 -0.55113682  1.4233193     0
#> 3  3  0.1291933  0.44232099 -0.4503055     0
#> 4  4  3.1988761 -2.16736451  2.6617757     0
#> 5  5 -1.6601806  0.16789238 -0.4864062     0
#> 6  6  3.4984111  0.80613725  1.2911096     0
```

Use the sim\_lm\_dfs function to generate a list of data frames each of
which contain main and previous data.

``` r
lm_dfs <- sim_lm_dfs(frames = 3)

str(lm_dfs)
#> List of 3
#>  $ :'data.frame':    50 obs. of  5 variables:
#>   ..$ ID   : int [1:50] 1 2 3 4 5 6 7 8 9 10 ...
#>   ..$ Y    : num [1:50] -0.735 1.136 1.429 3.783 2.54 ...
#>   ..$ X1   : num [1:50] -0.483 -0.793 0.515 -1.033 0.686 ...
#>   ..$ X2   : num [1:50] 1.183 0.828 1.177 2.639 1.693 ...
#>   ..$ prior: num [1:50] 0 0 0 0 0 0 0 0 0 0 ...
#>  $ :'data.frame':    50 obs. of  5 variables:
#>   ..$ ID   : int [1:50] 1 2 3 4 5 6 7 8 9 10 ...
#>   ..$ Y    : num [1:50] -0.798 -0.263 2.34 3.197 -0.819 ...
#>   ..$ X1   : num [1:50] -1.253 -1.499 -0.133 1.816 -0.453 ...
#>   ..$ X2   : num [1:50] 1.61 0.46 1.53 1.09 1.15 ...
#>   ..$ prior: num [1:50] 0 0 0 0 0 0 0 0 0 0 ...
#>  $ :'data.frame':    50 obs. of  5 variables:
#>   ..$ ID   : int [1:50] 1 2 3 4 5 6 7 8 9 10 ...
#>   ..$ Y    : num [1:50] -0.0441 3.3719 -2.3622 4.1734 3.1831 ...
#>   ..$ X1   : num [1:50] -0.439 1.513 -2.452 0.394 0.471 ...
#>   ..$ X2   : num [1:50] 1.4446 0.7892 0.0421 1.2726 1.7159 ...
#>   ..$ prior: num [1:50] 0 0 0 0 0 0 0 0 0 0 ...

head(lm_dfs[[2]])
#>   ID          Y         X1            X2 prior
#> 1  1 -0.7978892 -1.2531693  1.6065383116     0
#> 2  2 -0.2626061 -1.4990258  0.4604678419     0
#> 3  3  2.3401913 -0.1333948  1.5315711670     0
#> 4  4  3.1969702  1.8159040  1.0947668634     0
#> 5  5 -0.8189302 -0.4526068  1.1474901338     0
#> 6  6  0.3120240  0.7517403 -0.0002401534     0

tail(lm_dfs[[2]])
#>    ID          Y         X1         X2 prior
#> 45 20 -0.1096262 -0.4605706  0.2305376     1
#> 46 21  0.8042151 -0.5588187  1.7279928     1
#> 47 22  2.4533718  0.1268485  1.8530649     1
#> 48 23  2.0131152 -0.8426832  2.2162514     1
#> 49 24  1.7683343  1.6104728 -0.2718735     1
#> 50 25  1.2869096  0.3956867  0.3062405     1
```

## Citations

Cheung, C., & Szpak, P. (2021). Interpreting Past Human Diets Using
Stable Isotope Mixing Models. In Journal of Archaeological Method and
Theory (Vol. 28, Issue 4, pp. 1106–1142).
<https://doi.org/10.1007/s10816-020-09492-5>
