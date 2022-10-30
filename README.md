
<!-- README.md is generated from README.Rmd. Please edit that file -->

# simpriord

<!-- badges: start -->
<!-- badges: end -->

Using Bayesian models with informative priors is a common strategy to
deal with the limitations of statistical analysis with small sample
size. One way to incorporate prior information into the model is by
binding the data set from a previous study to the study’s main data set.
The goal of this package is to streamline a workflow for running
simulations to assess the performance of parameter estimation when the
main and previous data come from different populations.

This document first goes over software setup and then it outlines the
general workflow of the package.

## Installation

You can install the development version of simpriord from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mncube/simpriord")
```

## Load Package

``` r
library(simpriord)
```

## Workflow for Assessing Parameter Estimation

Step 1: Create the main data sets and previous study data sets using the
definitions for simglm’s sim_args parameter.

Note: This example closely follows the data generating mechanism from
the Generate Response Variable section of simglm’s Tidy Simulation
vignette
(<https://cran.r-project.org/web/packages/simglm/vignettes/tidy_simulation.html>)

``` r
#Define data generating process for the main data's population
args_main <- list(
  formula = y ~ 1 + weight + age + sex,
  fixed = list(weight = list(var_type = 'continuous', mean = 0, sd = 1),
               age = list(var_type = 'ordinal', levels = 30:60),
               sex = list(var_type = 'factor', levels = c('male', 'female'))),
  error = list(variance = 25),
  sample_size = 15,
  reg_weights = c(2, 0.3, -0.1, 0.5))

#Define data generating process for the previous data's population 
args_prior <- list(
  formula = y ~ 1 + weight + age + sex,
  fixed = list(weight = list(var_type = 'continuous', mean = 0, sd = 2),
               age = list(var_type = 'ordinal', levels = 30:60),
               sex = list(var_type = 'factor', levels = c('male', 'female'))),
  error = list(variance = 25),
  sample_size = 10,
  reg_weights = c(2, 0.4, -0.2, 0.5))
```

Step 2: Use the sim_sglm_dfs function to generate 25 dataframes from the
lists defined in Step 1

``` r
#Get dataframes
grv_out <- sim_sglm_dfs(data_m = NULL,
                        sim_args_m = args_main,
                        data_p = NULL,
                        sim_args_p = args_prior,
                        with_prior = 1,
                        frames = 25,
                        mod_name = list("mod1"))
```

grv_out is the list object returned from sim_sglm_dfs. The object
contains the dataframes and the data generating information

``` r
#Extract head and tail of the first dataframe 
head(grv_out$df_mod[[1]])
#>   X.Intercept.     weight age sex_1    sex level1_id      error fixed_outcome
#> 1            1  1.1622159  57     1   male         1 -0.5307605     -2.851335
#> 2            1 -0.8527697  45     1   male         2 11.3373237     -2.255831
#> 3            1  0.6297303  56     1   male         3  7.6474825     -2.911081
#> 4            1  0.8455076  43     0 female         4 -6.3619951     -2.046348
#> 5            1 -0.5295515  59     0 female         5 -4.5111203     -4.058865
#> 6            1 -0.9682034  52     0 female         6  5.0411973     -3.490461
#>   random_effects         y prior
#> 1              0 -3.382096     0
#> 2              0  9.081493     0
#> 3              0  4.736402     0
#> 4              0 -8.408343     0
#> 5              0 -8.569986     0
#> 6              0  1.550736     0
tail(grv_out$df_mod[[1]])
#>    X.Intercept.     weight age sex_1    sex level1_id      error fixed_outcome
#> 20            1  2.9319872  43     0 female         5  2.0168323     -5.427205
#> 21            1 -0.4838845  44     0 female         6 -0.4006068     -6.993554
#> 22            1  0.4934472  37     1   male         7 -6.1642994     -4.702621
#> 23            1 -1.0229982  58     0 female         8 -4.0113959    -10.009199
#> 24            1  2.2577675  39     1   male         9  3.7643140     -4.396893
#> 25            1  1.9800547  47     1   male        10  3.8549397     -6.107978
#>    random_effects          y prior
#> 20              0  -3.410373     1
#> 21              0  -7.394161     1
#> 22              0 -10.866921     1
#> 23              0 -14.020595     1
#> 24              0  -0.632579     1
#> 25              0  -2.253038     1

#Extract data generating information for the first dataframe's main data
grv_out$df_info[[1]]$main
#> $sim_args
#> $sim_args$formula
#> y ~ 1 + weight + age + sex
#> <environment: 0x000001a3ce5db258>
#> 
#> $sim_args$fixed
#> $sim_args$fixed$weight
#> $sim_args$fixed$weight$var_type
#> [1] "continuous"
#> 
#> $sim_args$fixed$weight$mean
#> [1] 0
#> 
#> $sim_args$fixed$weight$sd
#> [1] 1
#> 
#> 
#> $sim_args$fixed$age
#> $sim_args$fixed$age$var_type
#> [1] "ordinal"
#> 
#> $sim_args$fixed$age$levels
#>  [1] 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54
#> [26] 55 56 57 58 59 60
#> 
#> 
#> $sim_args$fixed$sex
#> $sim_args$fixed$sex$var_type
#> [1] "factor"
#> 
#> $sim_args$fixed$sex$levels
#> [1] "male"   "female"
#> 
#> 
#> 
#> $sim_args$error
#> $sim_args$error$variance
#> [1] 25
#> 
#> 
#> $sim_args$sample_size
#> [1] 15
#> 
#> $sim_args$reg_weights
#> [1]  2.0  0.3 -0.1  0.5
#> 
#> 
#> $prior
#> [1] 0
#> 
#> $mod_name
#> [1] "mod1"

#Extract data generating information for the first dataframe's prior data
grv_out$df_info[[1]]$prior
#> $sim_args
#> $sim_args$formula
#> y ~ 1 + weight + age + sex
#> <environment: 0x000001a3ce5db258>
#> 
#> $sim_args$fixed
#> $sim_args$fixed$weight
#> $sim_args$fixed$weight$var_type
#> [1] "continuous"
#> 
#> $sim_args$fixed$weight$mean
#> [1] 0
#> 
#> $sim_args$fixed$weight$sd
#> [1] 2
#> 
#> 
#> $sim_args$fixed$age
#> $sim_args$fixed$age$var_type
#> [1] "ordinal"
#> 
#> $sim_args$fixed$age$levels
#>  [1] 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54
#> [26] 55 56 57 58 59 60
#> 
#> 
#> $sim_args$fixed$sex
#> $sim_args$fixed$sex$var_type
#> [1] "factor"
#> 
#> $sim_args$fixed$sex$levels
#> [1] "male"   "female"
#> 
#> 
#> 
#> $sim_args$error
#> $sim_args$error$variance
#> [1] 25
#> 
#> 
#> $sim_args$sample_size
#> [1] 10
#> 
#> $sim_args$reg_weights
#> [1]  2.0  0.4 -0.2  0.5
#> 
#> 
#> $prior
#> [1] 1
#> 
#> $mod_name
#> [1] "mod1"
```

Step 3: Use the sim_sglm_run function to fit the model specified in Step
1 extended to include a prior data indicator as a fixed effect:

y \~ 1 + weight + age + sex + prior

The model was fit to each dataset in grv_out\$df_mod using brms with
default priors.

Note: To save time on computation this example set is using a small
number of dataframes (with frames = 25 in step 2) and a small number of
iterations (iter = 200).

``` r
#Fit data to model (Code commented out in this chunk and run with include=FALSE in the chunk below for cleaner presentation)
#sglm_mod_fits <- sim_sglm_run(df_list = list(grv_out), iter = 200)
```

sim_sglm_run returns a list object of parameter estimates. Extract
parameter estimates from grv_out\$df_mod first dataframe as follows

``` r
sglm_mod_fits$fits[[1]][[1]]
#>  Family: gaussian 
#>   Links: mu = identity; sigma = identity 
#> Formula: y ~ weight + age + sex + prior 
#>    Data: df (Number of observations: 25) 
#>   Draws: 4 chains, each with iter = 200; warmup = 100; thin = 1;
#>          total post-warmup draws = 400
#> 
#> Population-Level Effects: 
#>           Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
#> Intercept     3.87      6.73    -9.67    16.28 1.02      365      249
#> weight        1.29      0.69    -0.09     2.61 1.00      558      304
#> age          -0.13      0.13    -0.40     0.13 1.04      423      338
#> sexmale       2.18      2.38    -2.31     7.07 1.03      173      159
#> prior        -6.65      2.52   -11.18    -1.48 1.02      177      130
#> 
#> Family Specific Parameters: 
#>       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
#> sigma     5.44      0.83     4.13     7.17 1.01      236      288
#> 
#> Draws were sampled using sampling(NUTS). For each parameter, Bulk_ESS
#> and Tail_ESS are effective sample size measures, and Rhat is the potential
#> scale reduction factor on split chains (at convergence, Rhat = 1).
```

Step 4: Use the sim_sglm_comp function to assess parameter estimation
based on the dissimilarity between the main data’s population and the
previous data’s population.

``` r
#Get comparisons
sglm_comps <- sim_sglm_comp(fit_obj = sglm_mod_fits)
```

sim_sglm_comp returns the assessment of the parameter estimates in
sglm_mod_fits when compared to the main data’s population parameters in
Step 1’s reg_weights on arg_main’s list

``` r
sglm_comps[["main"]][[1]][,c("term", "parameter", "bias", "bias_mcse", 
                             "mse", "mse_mcse", "covered")]
#> # A tibble: 4 × 7
#>   term        parameter    bias bias_mcse     mse mse_mcse covered
#>   <chr>           <dbl>   <dbl>     <dbl>   <dbl>    <dbl>   <dbl>
#> 1 (Intercept)       2    1.44      1.16   34.5    13.9        0.96
#> 2 age              -0.1 -0.0306    0.0261  0.0173  0.00598    0.92
#> 3 sexmale           0.5 -0.383     0.431   4.61    0.849      1   
#> 4 weight            0.3  0.115     0.174   0.744   0.212      0.92
```

The function also returns the parameter estimates compared to the
previous population’s parameters

``` r
sglm_comps[["prior"]][[1]][,c("term", "parameter", "bias", "bias_mcse", 
                             "mse", "mse_mcse", "covered")]
#> # A tibble: 4 × 7
#>   term        parameter    bias bias_mcse     mse mse_mcse covered
#>   <chr>           <dbl>   <dbl>     <dbl>   <dbl>    <dbl>   <dbl>
#> 1 (Intercept)       2    1.44      1.16   34.5    13.9        0.96
#> 2 age              -0.2  0.0694    0.0261  0.0211  0.00780    0.88
#> 3 sexmale           0.5 -0.383     0.431   4.61    0.849      1   
#> 4 weight            0.4  0.0154    0.174   0.731   0.225      0.88
```
