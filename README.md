
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
definitions for simglm’s sim\_args parameter.

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

Step 2: Use the sim\_sglm\_dfs function to generate 25 dataframes from
the lists defined in Step 1

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

grv\_out is the list object returned from sim\_sglm\_dfs. The object
contains the dataframes and the data generating information

``` r
#Extract head and tail of the first dataframe 
head(grv_out$df_mod[[1]])
#>   X.Intercept.      weight age sex_1    sex level1_id      error fixed_outcome
#> 1            1 -0.04621852  39     0 female         1 -2.7569838    -1.9138656
#> 2            1 -0.68580094  56     1   male         2  8.5956260    -3.3057403
#> 3            1  0.62816770  36     0 female         3  0.8684099    -1.4115497
#> 4            1  0.86617794  36     1   male         4  3.3039384    -0.8401466
#> 5            1 -0.81918049  31     1   male         5 -2.5848153    -0.8457541
#> 6            1 -1.03703351  30     0 female         6 -6.7040745    -1.3111101
#>   random_effects          y prior
#> 1              0 -4.6708493     0
#> 2              0  5.2898857     0
#> 3              0 -0.5431398     0
#> 4              0  2.4637918     0
#> 5              0 -3.4305694     0
#> 6              0 -8.0151845     0
tail(grv_out$df_mod[[1]])
#>    X.Intercept.     weight age sex_1    sex level1_id      error fixed_outcome
#> 20            1  1.5655704  60     0 female         5 -4.9235296     -9.373772
#> 21            1 -0.7583463  32     0 female         6  0.5833964     -4.703339
#> 22            1  1.5127282  42     1   male         7  8.7367972     -5.294909
#> 23            1  1.5641435  38     1   male         8 -1.7713850     -4.474343
#> 24            1 -1.4995549  38     1   male         9  9.8184251     -5.699822
#> 25            1  1.8899977  45     0 female        10  3.2818590     -6.244001
#>    random_effects          y prior
#> 20              0 -14.297301     1
#> 21              0  -4.119942     1
#> 22              0   3.441888     1
#> 23              0  -6.245728     1
#> 24              0   4.118603     1
#> 25              0  -2.962142     1

#Extract data generating information for the first dataframe's main data
grv_out$df_info[[1]]$main
#> $sim_args
#> $sim_args$formula
#> y ~ 1 + weight + age + sex
#> <environment: 0x0000000014e8a738>
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

#Extract data generating information for the first dataframe's main data
grv_out$df_info[[1]]$prior
#> $sim_args
#> $sim_args$formula
#> y ~ 1 + weight + age + sex
#> <environment: 0x0000000014e8a738>
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

Step 3: Use the sim\_sglm\_run function to fit the model specified in
Step 1 extended to include a prior data indicator as a fixed effect:

y \~ 1 + weight + age + sex + prior

The model was fit to each dataset in grv\_out$df\_mod using brms with
default priors.

Note: To save time on computation this example set is using a small
number of dataframes (with frames = 25 in step 2) and a small number of
iterations (iter = 200).

sim\_sglm\_run returns a list object of parameter estimates. Extract
parameter estimates from grv\_out$df\_mod first dataframe as follows

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
#> Intercept    -1.01      5.22   -11.97     9.52 1.01      424      314
#> weight        0.49      0.94    -1.43     2.34 1.01      438      313
#> age          -0.06      0.12    -0.30     0.18 1.02      435      328
#> sexmale       4.88      2.25     0.29     9.48 1.05      135      195
#> prior        -4.22      2.25    -8.88     0.17 1.02      170      162
#> 
#> Family Specific Parameters: 
#>       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
#> sigma     4.86      0.80     3.64     6.61 1.01      371      355
#> 
#> Draws were sampled using sampling(NUTS). For each parameter, Bulk_ESS
#> and Tail_ESS are effective sample size measures, and Rhat is the potential
#> scale reduction factor on split chains (at convergence, Rhat = 1).
```

Step 4: Use the sim\_sglm\_comp function to assess parameter estimation
based on the dissimilarity between the main data’s population and the
previous data’s population.

``` r
#Get comparisons
sglm_comps <- sim_sglm_comp(fit_obj = sglm_mod_fits)
```

sim\_sglm\_comp returns the assessment the parameter estimates in
sglm\_mod\_fits when compared to the main data’s population parameters
in Step 1’s reg\_weights on arg\_main’s list

``` r
sglm_comps[["main"]][[1]][,c("term", "parameter", "bias", "bias_mcse", 
                             "mse", "mse_mcse", "covered")]
#> # A tibble: 5 x 7
#>   term        parameter     bias bias_mcse     mse mse_mcse covered
#>   <chr>           <dbl>    <dbl>     <dbl>   <dbl>    <dbl>   <dbl>
#> 1 (Intercept)       2    2.12       1.09   33.0     8.46       1   
#> 2 age              -0.1 -0.0496     0.0235  0.0157  0.00369    1   
#> 3 prior             0   -4.45       0.401  23.6     3.54       0.52
#> 4 sexmale           0.5  0.266      0.417   4.24    1.19       1   
#> 5 weight            0.3  0.00124    0.145   0.504   0.139      0.92
```

The function also returns the parameter estimates compared to the
previous population’s parameters

``` r
sglm_comps[["prior"]][[1]][,c("term", "parameter", "bias", "bias_mcse", 
                             "mse", "mse_mcse", "covered")]
#> # A tibble: 5 x 7
#>   term        parameter    bias bias_mcse     mse mse_mcse covered
#>   <chr>           <dbl>   <dbl>     <dbl>   <dbl>    <dbl>   <dbl>
#> 1 (Intercept)       2    2.12      1.09   33.0     8.46       1   
#> 2 age              -0.2  0.0504    0.0235  0.0158  0.00408    0.92
#> 3 prior             1   -5.45      0.401  33.5     4.33       0.28
#> 4 sexmale           0.5  0.266     0.417   4.24    1.19       1   
#> 5 weight            0.4 -0.0988    0.145   0.514   0.151      0.88
```
