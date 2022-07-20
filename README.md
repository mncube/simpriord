
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
#>   ID          Y          X1         X2 prior
#> 1  1 -1.7565484 -1.21866965 -1.6212373     0
#> 2  2 -0.1822512 -1.98544212  1.9275381     0
#> 3  3  1.2837034 -1.11812431  2.0035658     0
#> 4  4  1.8350516 -0.35302477  1.8258843     0
#> 5  5  0.3129830  0.05043747  0.7161601     0
#> 6  6  1.0014337 -2.08664405  1.2717655     0

# See model name and coefficients used to produce data
print(lm_df$df_info)
#>   b0 b1 b2 prior mod_name
#> 1  0  1  1     0      mod
```

Use the sim\_lm\_dfs function to generate a list of data frames each of
which contain main and previous data.

``` r
lm_dfs <- sim_lm_dfs(frames = 3,
                     mod_name = list("mod1", "mod2", "mod3"))

# Preview data for the second model
head(lm_dfs$df_mod[[2]])
#>   ID           Y         X1        X2 prior
#> 1  1  0.85046895  0.2858240 0.8890214     0
#> 2  2 -0.02755483 -0.9887543 0.1920631     0
#> 3  3  0.15982635 -0.3664843 1.0903230     0
#> 4  4  3.62196384  1.6581033 1.0424110     0
#> 5  5  3.86403997 -0.5172706 1.9787910     0
#> 6  6  4.07320896  1.0512514 1.9641142     0
tail(lm_dfs$df_mod[[2]])
#>    ID          Y           X1         X2 prior
#> 45 20  0.4483163 -1.816751214  0.8869469     1
#> 46 21 -0.6355314  0.005233216  0.1668184     1
#> 47 22  5.2718542  0.321780781  2.8269892     1
#> 48 23 -3.4701951 -0.556069615 -0.6196824     1
#> 49 24  2.9111208  0.726215038  1.3666211     1
#> 50 25  1.9337771 -0.206634335  2.4448987     1

#See model name and coefficients used to produce second model data
print(lm_dfs$df_info[[2]])
#>   b0 b1 b2 prior mod_name
#> 1  0  1  1     0     mod2
#> 2  0  1  1     1     mod2
```

## Citations

Cheung, C., & Szpak, P. (2021). Interpreting Past Human Diets Using
Stable Isotope Mixing Models. In Journal of Archaeological Method and
Theory (Vol. 28, Issue 4, pp. 1106–1142).
<https://doi.org/10.1007/s10816-020-09492-5>
