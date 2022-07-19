
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
#>   ID         Y          X1          X2 prior mod_name
#> 1  1 -1.463634 -1.77658601  1.56386025     0      mod
#> 2  2  1.541915  0.28789767 -0.09705887     0      mod
#> 3  3  1.163752 -0.35709529  2.40613755     0      mod
#> 4  4  1.209965  0.04806279  0.91916916     0      mod
#> 5  5  2.022074  0.24504037  1.44164083     0      mod
#> 6  6  2.650186  0.04812894  1.25188420     0      mod
```

Use the sim\_lm\_dfs function to generate a list of data frames each of
which contain main and previous data.

``` r
lm_dfs <- sim_lm_dfs(frames = 3,
                     mod_name = list("mod1", "mod2", "mod3"))

str(lm_dfs)
#> List of 3
#>  $ :'data.frame':    50 obs. of  6 variables:
#>   ..$ ID      : int [1:50] 1 2 3 4 5 6 7 8 9 10 ...
#>   ..$ Y       : num [1:50] 0.296 2.704 1.619 3.08 2.459 ...
#>   ..$ X1      : num [1:50] 0.177 0.146 0.448 0.328 1.187 ...
#>   ..$ X2      : num [1:50] 1.54 0.37 1.95 2.05 1.49 ...
#>   ..$ prior   : num [1:50] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ mod_name: chr [1:50] "mod1" "mod1" "mod1" "mod1" ...
#>  $ :'data.frame':    50 obs. of  6 variables:
#>   ..$ ID      : int [1:50] 1 2 3 4 5 6 7 8 9 10 ...
#>   ..$ Y       : num [1:50] 2.2439 -0.3793 0.6569 0.0902 1.137 ...
#>   ..$ X1      : num [1:50] 0.982 -0.557 -1.165 -1.854 0.502 ...
#>   ..$ X2      : num [1:50] 2.732 -1.324 -0.333 2.203 -0.4 ...
#>   ..$ prior   : num [1:50] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ mod_name: chr [1:50] "mod2" "mod2" "mod2" "mod2" ...
#>  $ :'data.frame':    50 obs. of  6 variables:
#>   ..$ ID      : int [1:50] 1 2 3 4 5 6 7 8 9 10 ...
#>   ..$ Y       : num [1:50] 2.142 2.891 0.174 1.881 0.319 ...
#>   ..$ X1      : num [1:50] 1.25 -0.47 -1.082 -0.957 -0.38 ...
#>   ..$ X2      : num [1:50] 1.042 0.916 1.375 1.973 0.594 ...
#>   ..$ prior   : num [1:50] 0 0 0 0 0 0 0 0 0 0 ...
#>   ..$ mod_name: chr [1:50] "mod3" "mod3" "mod3" "mod3" ...

head(lm_dfs[[2]])
#>   ID           Y         X1         X2 prior mod_name
#> 1  1  2.24390356  0.9815430  2.7315683     0     mod2
#> 2  2 -0.37931020 -0.5571479 -1.3235670     0     mod2
#> 3  3  0.65689449 -1.1650335 -0.3334242     0     mod2
#> 4  4  0.09017216 -1.8540171  2.2027655     0     mod2
#> 5  5  1.13695840  0.5019779 -0.4000873     0     mod2
#> 6  6  3.41458178  1.0775598  0.4583933     0     mod2

tail(lm_dfs[[2]])
#>    ID         Y          X1          X2 prior mod_name
#> 45 20 2.1871825 -1.26533409  1.27983425     1     mod2
#> 46 21 2.4803149  0.03427607  2.60677495     1     mod2
#> 47 22 1.2063949  0.43493011 -0.17937295     1     mod2
#> 48 23 1.7291627  0.19598015  2.03132754     1     mod2
#> 49 24 5.3075955  1.80656123  2.75275553     1     mod2
#> 50 25 0.3178834 -0.45860470  0.06294389     1     mod2
```

## Citations

Cheung, C., & Szpak, P. (2021). Interpreting Past Human Diets Using
Stable Isotope Mixing Models. In Journal of Archaeological Method and
Theory (Vol. 28, Issue 4, pp. 1106–1142).
<https://doi.org/10.1007/s10816-020-09492-5>
