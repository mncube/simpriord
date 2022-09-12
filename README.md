
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
#> 1            1  1.32168772  36     0 female         1  3.0722268     -1.203494
#> 2            1 -0.32437622  46     0 female         2  0.5076302     -2.697313
#> 3            1 -1.46386688  54     0 female         3 11.6259466     -3.839160
#> 4            1 -0.01215356  41     0 female         4 -2.5679390     -2.103646
#> 5            1 -0.03694367  43     1   male         5 -3.1366699     -1.811083
#> 6            1  0.50508345  60     0 female         6  4.3585091     -3.848475
#>   random_effects          y prior
#> 1              0  1.8687331     0
#> 2              0 -2.1896827     0
#> 3              0  7.7867866     0
#> 4              0 -4.6715851     0
#> 5              0 -4.9477530     0
#> 6              0  0.5100342     0
tail(grv_out$df_mod[[1]])
#>    X.Intercept.      weight age sex_1    sex level1_id      error fixed_outcome
#> 20            1 -0.22064940  36     1   male         5   4.880667     -4.788260
#> 21            1  0.01191317  57     1   male         6   4.133832     -8.895235
#> 22            1  0.65826764  40     0 female         7 -11.424716     -5.736693
#> 23            1 -0.51872362  37     1   male         8   1.857523     -5.107489
#> 24            1 -1.06940196  47     0 female         9  -6.793569     -7.827761
#> 25            1 -1.54847638  55     0 female        10  -3.359969     -9.619391
#>    random_effects            y prior
#> 20              0   0.09240773     1
#> 21              0  -4.76140306     1
#> 22              0 -17.16140904     1
#> 23              0  -3.24996667     1
#> 24              0 -14.62132975     1
#> 25              0 -12.97935971     1

#Extract data generating information for the first dataframe's main data
grv_out$df_info[[1]]$main
#> $sim_args
#> $sim_args$formula
#> y ~ 1 + weight + age + sex
#> <environment: 0x0000000014e99458>
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
#> <environment: 0x0000000014e99458>
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

``` r
#Fit data to model (Code commented out in this chunk and run with include=FALSE in the chunk below for cleaner presentation)
#sglm_mod_fits <- sim_sglm_run(df_list = list(grv_out), iter = 200)
```

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
#> Intercept     1.98      5.56   -10.74    13.66 1.00      491      363
#> weight       -0.61      0.95    -2.32     1.28 1.01      287      317
#> age          -0.13      0.12    -0.37     0.13 1.00      499      322
#> sexmale       3.05      2.33    -1.29     7.78 1.03      209      218
#> prior        -6.21      2.80   -11.77    -0.25 1.02      167      120
#> 
#> Family Specific Parameters: 
#>       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
#> sigma     5.72      0.84     4.34     7.76 1.00      403      263
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
#>   term        parameter    bias bias_mcse     mse mse_mcse covered
#>   <chr>           <dbl>   <dbl>     <dbl>   <dbl>    <dbl>   <dbl>
#> 1 (Intercept)       2    2.71      1.04   33.5     7.93       0.96
#> 2 age              -0.1 -0.0633    0.0222  0.0158  0.00340    0.96
#> 3 prior             0   -4.36      0.544  26.1     4.81       0.56
#> 4 sexmale           0.5  0.254     0.476   5.51    1.04       0.92
#> 5 weight            0.3 -0.105     0.164   0.658   0.155      0.96
```

The function also returns the parameter estimates compared to the
previous population’s parameters

``` r
sglm_comps[["prior"]][[1]][,c("term", "parameter", "bias", "bias_mcse", 
                             "mse", "mse_mcse", "covered")]
#> # A tibble: 5 x 7
#>   term        parameter    bias bias_mcse     mse mse_mcse covered
#>   <chr>           <dbl>   <dbl>     <dbl>   <dbl>    <dbl>   <dbl>
#> 1 (Intercept)       2    2.71      1.04   33.5     7.93       0.96
#> 2 age              -0.2  0.0367    0.0222  0.0131  0.00360    0.92
#> 3 prior             1   -5.36      0.544  35.8     5.85       0.36
#> 4 sexmale           0.5  0.254     0.476   5.51    1.04       0.92
#> 5 weight            0.4 -0.205     0.164   0.689   0.178      0.96
```
