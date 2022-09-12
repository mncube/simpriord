
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
#>   X.Intercept.     weight age sex_1    sex level1_id      error fixed_outcome
#> 1            1  0.4455372  36     0 female         1  0.3174736    -1.4663388
#> 2            1 -0.8585127  38     0 female         2  9.9659911    -2.0575538
#> 3            1 -0.3409558  52     0 female         3  0.3605772    -3.3022867
#> 4            1  0.5388196  35     1   male         4 -8.5119627    -0.8383541
#> 5            1 -0.2138987  59     0 female         5 -0.4079529    -3.9641696
#> 6            1 -0.1927873  48     0 female         6  8.9301861    -2.8578362
#>   random_effects         y prior
#> 1              0 -1.148865     0
#> 2              0  7.908437     0
#> 3              0 -2.941710     0
#> 4              0 -9.350317     0
#> 5              0 -4.372122     0
#> 6              0  6.072350     0
tail(grv_out$df_mod[[1]])
#>    X.Intercept.     weight age sex_1    sex level1_id       error fixed_outcome
#> 20            1  0.7269990  42     0 female         5   1.7569816     -6.109200
#> 21            1 -0.4965253  42     0 female         6  -2.1619503     -6.598610
#> 22            1 -0.9363542  46     1   male         7  -0.5249207     -7.074542
#> 23            1  2.5486230  43     0 female         8   1.4013755     -5.580551
#> 24            1 -1.2169338  30     1   male         9 -10.7693276     -3.986774
#> 25            1  1.5899250  39     1   male        10  -5.6202990     -4.664030
#>    random_effects          y prior
#> 20              0  -4.352219     1
#> 21              0  -8.760560     1
#> 22              0  -7.599462     1
#> 23              0  -4.179175     1
#> 24              0 -14.756101     1
#> 25              0 -10.284329     1

#Extract data generating information for the first dataframe's main data
grv_out$df_info[[1]]$main
#> $sim_args
#> $sim_args$formula
#> y ~ 1 + weight + age + sex
#> <environment: 0x0000000014e99f58>
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
#> <environment: 0x0000000014e99f58>
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
#Fit data to model
sglm_mod_fits <- sim_sglm_run(df_list = list(grv_out), iter = 200)
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'd93f2de1ed4a304ab6b798302746058b' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.068 seconds (Warm-up)
#> Chain 1:                0.053 seconds (Sampling)
#> Chain 1:                0.121 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'd93f2de1ed4a304ab6b798302746058b' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.112 seconds (Warm-up)
#> Chain 2:                0.044 seconds (Sampling)
#> Chain 2:                0.156 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'd93f2de1ed4a304ab6b798302746058b' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.056 seconds (Warm-up)
#> Chain 3:                0.055 seconds (Sampling)
#> Chain 3:                0.111 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'd93f2de1ed4a304ab6b798302746058b' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.067 seconds (Warm-up)
#> Chain 4:                0.059 seconds (Sampling)
#> Chain 4:                0.126 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '6c6daf37ed7e538e1a8c959279725799' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.073 seconds (Warm-up)
#> Chain 1:                0.055 seconds (Sampling)
#> Chain 1:                0.128 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '6c6daf37ed7e538e1a8c959279725799' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.055 seconds (Warm-up)
#> Chain 2:                0.066 seconds (Sampling)
#> Chain 2:                0.121 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '6c6daf37ed7e538e1a8c959279725799' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.067 seconds (Warm-up)
#> Chain 3:                0.061 seconds (Sampling)
#> Chain 3:                0.128 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '6c6daf37ed7e538e1a8c959279725799' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.064 seconds (Warm-up)
#> Chain 4:                0.107 seconds (Sampling)
#> Chain 4:                0.171 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '54dae564c192cf3c5c2ee110dd7291aa' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.073 seconds (Warm-up)
#> Chain 1:                0.063 seconds (Sampling)
#> Chain 1:                0.136 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '54dae564c192cf3c5c2ee110dd7291aa' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.054 seconds (Warm-up)
#> Chain 2:                0.047 seconds (Sampling)
#> Chain 2:                0.101 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '54dae564c192cf3c5c2ee110dd7291aa' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.062 seconds (Warm-up)
#> Chain 3:                0.059 seconds (Sampling)
#> Chain 3:                0.121 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '54dae564c192cf3c5c2ee110dd7291aa' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.072 seconds (Warm-up)
#> Chain 4:                0.056 seconds (Sampling)
#> Chain 4:                0.128 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '233638e1dea959c1686625758c6a2e2b' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.044 seconds (Warm-up)
#> Chain 1:                0.037 seconds (Sampling)
#> Chain 1:                0.081 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '233638e1dea959c1686625758c6a2e2b' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 2:                0.035 seconds (Sampling)
#> Chain 2:                0.083 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '233638e1dea959c1686625758c6a2e2b' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.039 seconds (Warm-up)
#> Chain 3:                0.038 seconds (Sampling)
#> Chain 3:                0.077 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '233638e1dea959c1686625758c6a2e2b' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.044 seconds (Warm-up)
#> Chain 4:                0.038 seconds (Sampling)
#> Chain 4:                0.082 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '317fab8aa03d0a4a5e5c532ae9a82328' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.072 seconds (Warm-up)
#> Chain 1:                0.081 seconds (Sampling)
#> Chain 1:                0.153 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '317fab8aa03d0a4a5e5c532ae9a82328' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.103 seconds (Warm-up)
#> Chain 2:                0.076 seconds (Sampling)
#> Chain 2:                0.179 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '317fab8aa03d0a4a5e5c532ae9a82328' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.084 seconds (Warm-up)
#> Chain 3:                0.07 seconds (Sampling)
#> Chain 3:                0.154 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '317fab8aa03d0a4a5e5c532ae9a82328' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.079 seconds (Warm-up)
#> Chain 4:                0.08 seconds (Sampling)
#> Chain 4:                0.159 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'b531af99fe75f49e595615209c5d5f67' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.042 seconds (Warm-up)
#> Chain 1:                0.037 seconds (Sampling)
#> Chain 1:                0.079 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'b531af99fe75f49e595615209c5d5f67' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.056 seconds (Warm-up)
#> Chain 2:                0.036 seconds (Sampling)
#> Chain 2:                0.092 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'b531af99fe75f49e595615209c5d5f67' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.037 seconds (Warm-up)
#> Chain 3:                0.037 seconds (Sampling)
#> Chain 3:                0.074 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'b531af99fe75f49e595615209c5d5f67' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.046 seconds (Warm-up)
#> Chain 4:                0.043 seconds (Sampling)
#> Chain 4:                0.089 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '197b68d323cbff78e1560bb707143374' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0.001 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 10 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.056 seconds (Warm-up)
#> Chain 1:                0.052 seconds (Sampling)
#> Chain 1:                0.108 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '197b68d323cbff78e1560bb707143374' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.116 seconds (Warm-up)
#> Chain 2:                0.071 seconds (Sampling)
#> Chain 2:                0.187 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '197b68d323cbff78e1560bb707143374' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.245 seconds (Warm-up)
#> Chain 3:                0.153 seconds (Sampling)
#> Chain 3:                0.398 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '197b68d323cbff78e1560bb707143374' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.172 seconds (Warm-up)
#> Chain 4:                0.096 seconds (Sampling)
#> Chain 4:                0.268 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'e9bcde884501848fbc20b088ab88a93e' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.163 seconds (Warm-up)
#> Chain 1:                0.184 seconds (Sampling)
#> Chain 1:                0.347 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'e9bcde884501848fbc20b088ab88a93e' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.105 seconds (Warm-up)
#> Chain 2:                0.133 seconds (Sampling)
#> Chain 2:                0.238 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'e9bcde884501848fbc20b088ab88a93e' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.128 seconds (Warm-up)
#> Chain 3:                0.107 seconds (Sampling)
#> Chain 3:                0.235 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'e9bcde884501848fbc20b088ab88a93e' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.135 seconds (Warm-up)
#> Chain 4:                0.096 seconds (Sampling)
#> Chain 4:                0.231 seconds (Total)
#> Chain 4:
#> Warning: The largest R-hat is 1.09, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'e3c762ebf0ff5feb55263d5a668d72c8' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0.001 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 10 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.053 seconds (Warm-up)
#> Chain 1:                0.045 seconds (Sampling)
#> Chain 1:                0.098 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'e3c762ebf0ff5feb55263d5a668d72c8' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.046 seconds (Warm-up)
#> Chain 2:                0.045 seconds (Sampling)
#> Chain 2:                0.091 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'e3c762ebf0ff5feb55263d5a668d72c8' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.064 seconds (Warm-up)
#> Chain 3:                0.051 seconds (Sampling)
#> Chain 3:                0.115 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'e3c762ebf0ff5feb55263d5a668d72c8' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.077 seconds (Warm-up)
#> Chain 4:                0.051 seconds (Sampling)
#> Chain 4:                0.128 seconds (Total)
#> Chain 4:
#> Warning: The largest R-hat is 1.09, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '18f8b671ae7f05984b1d2b46c86f7812' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0.001 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 10 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.087 seconds (Warm-up)
#> Chain 1:                0.077 seconds (Sampling)
#> Chain 1:                0.164 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '18f8b671ae7f05984b1d2b46c86f7812' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.077 seconds (Warm-up)
#> Chain 2:                0.065 seconds (Sampling)
#> Chain 2:                0.142 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '18f8b671ae7f05984b1d2b46c86f7812' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.1 seconds (Warm-up)
#> Chain 3:                0.07 seconds (Sampling)
#> Chain 3:                0.17 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '18f8b671ae7f05984b1d2b46c86f7812' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.077 seconds (Warm-up)
#> Chain 4:                0.072 seconds (Sampling)
#> Chain 4:                0.149 seconds (Total)
#> Chain 4:
#> Warning: The largest R-hat is 1.07, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'c6c90a3dc11793b3d041782a7c47352c' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.046 seconds (Warm-up)
#> Chain 1:                0.035 seconds (Sampling)
#> Chain 1:                0.081 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'c6c90a3dc11793b3d041782a7c47352c' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.035 seconds (Warm-up)
#> Chain 2:                0.038 seconds (Sampling)
#> Chain 2:                0.073 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'c6c90a3dc11793b3d041782a7c47352c' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.035 seconds (Warm-up)
#> Chain 3:                0.032 seconds (Sampling)
#> Chain 3:                0.067 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'c6c90a3dc11793b3d041782a7c47352c' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.046 seconds (Warm-up)
#> Chain 4:                0.032 seconds (Sampling)
#> Chain 4:                0.078 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'cdd1ce067aa370c6b779b7d32e2e5686' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 1:                0.04 seconds (Sampling)
#> Chain 1:                0.088 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'cdd1ce067aa370c6b779b7d32e2e5686' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.04 seconds (Warm-up)
#> Chain 2:                0.048 seconds (Sampling)
#> Chain 2:                0.088 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'cdd1ce067aa370c6b779b7d32e2e5686' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.056 seconds (Warm-up)
#> Chain 3:                0.043 seconds (Sampling)
#> Chain 3:                0.099 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'cdd1ce067aa370c6b779b7d32e2e5686' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 4:                0.04 seconds (Sampling)
#> Chain 4:                0.088 seconds (Total)
#> Chain 4:
#> Warning: The largest R-hat is 1.07, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'cd2f310a9fd5726412289836157a97db' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.057 seconds (Warm-up)
#> Chain 1:                0.04 seconds (Sampling)
#> Chain 1:                0.097 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'cd2f310a9fd5726412289836157a97db' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 2:                0.032 seconds (Sampling)
#> Chain 2:                0.08 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'cd2f310a9fd5726412289836157a97db' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.04 seconds (Warm-up)
#> Chain 3:                0.04 seconds (Sampling)
#> Chain 3:                0.08 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'cd2f310a9fd5726412289836157a97db' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 4:                0.032 seconds (Sampling)
#> Chain 4:                0.08 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'fc8f21619e28e9337534c85bcfe9478f' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.057 seconds (Warm-up)
#> Chain 1:                0.066 seconds (Sampling)
#> Chain 1:                0.123 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'fc8f21619e28e9337534c85bcfe9478f' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.065 seconds (Warm-up)
#> Chain 2:                0.06 seconds (Sampling)
#> Chain 2:                0.125 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'fc8f21619e28e9337534c85bcfe9478f' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.06 seconds (Warm-up)
#> Chain 3:                0.06 seconds (Sampling)
#> Chain 3:                0.12 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'fc8f21619e28e9337534c85bcfe9478f' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.059 seconds (Warm-up)
#> Chain 4:                0.05 seconds (Sampling)
#> Chain 4:                0.109 seconds (Total)
#> Chain 4:
#> Warning: The largest R-hat is 1.05, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '4ddfef508d5ac90de3981c3988c8cc0f' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.066 seconds (Warm-up)
#> Chain 1:                0.075 seconds (Sampling)
#> Chain 1:                0.141 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '4ddfef508d5ac90de3981c3988c8cc0f' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.095 seconds (Warm-up)
#> Chain 2:                0.075 seconds (Sampling)
#> Chain 2:                0.17 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '4ddfef508d5ac90de3981c3988c8cc0f' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.085 seconds (Warm-up)
#> Chain 3:                0.08 seconds (Sampling)
#> Chain 3:                0.165 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '4ddfef508d5ac90de3981c3988c8cc0f' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.09 seconds (Warm-up)
#> Chain 4:                0.07 seconds (Sampling)
#> Chain 4:                0.16 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'd93344171aae77cae5a405505fe6e04b' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.04 seconds (Warm-up)
#> Chain 1:                0.032 seconds (Sampling)
#> Chain 1:                0.072 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'd93344171aae77cae5a405505fe6e04b' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.04 seconds (Warm-up)
#> Chain 2:                0.031 seconds (Sampling)
#> Chain 2:                0.071 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'd93344171aae77cae5a405505fe6e04b' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.047 seconds (Warm-up)
#> Chain 3:                0.031 seconds (Sampling)
#> Chain 3:                0.078 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'd93344171aae77cae5a405505fe6e04b' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.032 seconds (Warm-up)
#> Chain 4:                0.046 seconds (Sampling)
#> Chain 4:                0.078 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '5a19cb698ff6f3f2b4da9c7d95d585c8' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.094 seconds (Warm-up)
#> Chain 1:                0.08 seconds (Sampling)
#> Chain 1:                0.174 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '5a19cb698ff6f3f2b4da9c7d95d585c8' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.074 seconds (Warm-up)
#> Chain 2:                0.08 seconds (Sampling)
#> Chain 2:                0.154 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '5a19cb698ff6f3f2b4da9c7d95d585c8' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.087 seconds (Warm-up)
#> Chain 3:                0.092 seconds (Sampling)
#> Chain 3:                0.179 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '5a19cb698ff6f3f2b4da9c7d95d585c8' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.116 seconds (Warm-up)
#> Chain 4:                0.084 seconds (Sampling)
#> Chain 4:                0.2 seconds (Total)
#> Chain 4:
#> Warning: The largest R-hat is 1.05, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '3fbf47e3e90c6baa329488157fb4f878' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.05 seconds (Warm-up)
#> Chain 1:                0.044 seconds (Sampling)
#> Chain 1:                0.094 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '3fbf47e3e90c6baa329488157fb4f878' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.049 seconds (Warm-up)
#> Chain 2:                0.05 seconds (Sampling)
#> Chain 2:                0.099 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '3fbf47e3e90c6baa329488157fb4f878' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.056 seconds (Warm-up)
#> Chain 3:                0.044 seconds (Sampling)
#> Chain 3:                0.1 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '3fbf47e3e90c6baa329488157fb4f878' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.056 seconds (Warm-up)
#> Chain 4:                0.035 seconds (Sampling)
#> Chain 4:                0.091 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '172aecdd8afc0672db627f7485cb1bcb' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.056 seconds (Warm-up)
#> Chain 1:                0.032 seconds (Sampling)
#> Chain 1:                0.088 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '172aecdd8afc0672db627f7485cb1bcb' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.034 seconds (Warm-up)
#> Chain 2:                0.04 seconds (Sampling)
#> Chain 2:                0.074 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '172aecdd8afc0672db627f7485cb1bcb' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 3:                0.04 seconds (Sampling)
#> Chain 3:                0.088 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '172aecdd8afc0672db627f7485cb1bcb' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.049 seconds (Warm-up)
#> Chain 4:                0.036 seconds (Sampling)
#> Chain 4:                0.085 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '8da37778a3593fc4a67ae2f633b60068' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.04 seconds (Warm-up)
#> Chain 1:                0.04 seconds (Sampling)
#> Chain 1:                0.08 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '8da37778a3593fc4a67ae2f633b60068' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 2:                0.04 seconds (Sampling)
#> Chain 2:                0.088 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '8da37778a3593fc4a67ae2f633b60068' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 3:                0.04 seconds (Sampling)
#> Chain 3:                0.088 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '8da37778a3593fc4a67ae2f633b60068' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 4:                0.04 seconds (Sampling)
#> Chain 4:                0.088 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'f66f4515a0bc049412b9728ff050a690' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.04 seconds (Warm-up)
#> Chain 1:                0.036 seconds (Sampling)
#> Chain 1:                0.076 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'f66f4515a0bc049412b9728ff050a690' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.032 seconds (Warm-up)
#> Chain 2:                0.032 seconds (Sampling)
#> Chain 2:                0.064 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'f66f4515a0bc049412b9728ff050a690' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.032 seconds (Warm-up)
#> Chain 3:                0.032 seconds (Sampling)
#> Chain 3:                0.064 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'f66f4515a0bc049412b9728ff050a690' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.04 seconds (Warm-up)
#> Chain 4:                0.032 seconds (Sampling)
#> Chain 4:                0.072 seconds (Total)
#> Chain 4:
#> Warning: The largest R-hat is 1.06, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'c72eb33c02e0509f41d580e15ad5a753' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.056 seconds (Warm-up)
#> Chain 1:                0.041 seconds (Sampling)
#> Chain 1:                0.097 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'c72eb33c02e0509f41d580e15ad5a753' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 2:                0.04 seconds (Sampling)
#> Chain 2:                0.088 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'c72eb33c02e0509f41d580e15ad5a753' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 3:                0.04 seconds (Sampling)
#> Chain 3:                0.088 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'c72eb33c02e0509f41d580e15ad5a753' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.048 seconds (Warm-up)
#> Chain 4:                0.032 seconds (Sampling)
#> Chain 4:                0.08 seconds (Total)
#> Chain 4:
#> Warning: The largest R-hat is 1.1, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '4eff141defa7b2b31555904b80f66538' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.064 seconds (Warm-up)
#> Chain 1:                0.072 seconds (Sampling)
#> Chain 1:                0.136 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '4eff141defa7b2b31555904b80f66538' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.08 seconds (Warm-up)
#> Chain 2:                0.064 seconds (Sampling)
#> Chain 2:                0.144 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '4eff141defa7b2b31555904b80f66538' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.088 seconds (Warm-up)
#> Chain 3:                0.272 seconds (Sampling)
#> Chain 3:                0.36 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '4eff141defa7b2b31555904b80f66538' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.272 seconds (Warm-up)
#> Chain 4:                0.216 seconds (Sampling)
#> Chain 4:                0.488 seconds (Total)
#> Chain 4:
#> Warning: The largest R-hat is 1.05, indicating chains have not mixed.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#r-hat
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess
#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'b684ce0845a0e446c8663cebb1ed1602' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.047 seconds (Warm-up)
#> Chain 1:                0.031 seconds (Sampling)
#> Chain 1:                0.078 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'b684ce0845a0e446c8663cebb1ed1602' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.046 seconds (Warm-up)
#> Chain 2:                0.032 seconds (Sampling)
#> Chain 2:                0.078 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'b684ce0845a0e446c8663cebb1ed1602' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.032 seconds (Warm-up)
#> Chain 3:                0.031 seconds (Sampling)
#> Chain 3:                0.063 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'b684ce0845a0e446c8663cebb1ed1602' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.047 seconds (Warm-up)
#> Chain 4:                0.031 seconds (Sampling)
#> Chain 4:                0.078 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
#> Compiling Stan program...
#> Start sampling
#> 
#> SAMPLING FOR MODEL '62c9ea3affe1d932ac4a490a3103581b' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 0 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: WARNING: There aren't enough warmup iterations to fit the
#> Chain 1:          three stages of adaptation as currently configured.
#> Chain 1:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 1:          the given number of warmup iterations:
#> Chain 1:            init_buffer = 15
#> Chain 1:            adapt_window = 75
#> Chain 1:            term_buffer = 10
#> Chain 1: 
#> Chain 1: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 1: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 1: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 1: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 1: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 1: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 1: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 1: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 1: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 1: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 1: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 1: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 0.031 seconds (Warm-up)
#> Chain 1:                0.047 seconds (Sampling)
#> Chain 1:                0.078 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '62c9ea3affe1d932ac4a490a3103581b' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 2: Adjust your expectations accordingly!
#> Chain 2: 
#> Chain 2: 
#> Chain 2: WARNING: There aren't enough warmup iterations to fit the
#> Chain 2:          three stages of adaptation as currently configured.
#> Chain 2:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 2:          the given number of warmup iterations:
#> Chain 2:            init_buffer = 15
#> Chain 2:            adapt_window = 75
#> Chain 2:            term_buffer = 10
#> Chain 2: 
#> Chain 2: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 2: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 2: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 2: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 2: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 2: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 2: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 2: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 2: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 2: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 2: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 2: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 2: 
#> Chain 2:  Elapsed Time: 0.046 seconds (Warm-up)
#> Chain 2:                0.047 seconds (Sampling)
#> Chain 2:                0.093 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '62c9ea3affe1d932ac4a490a3103581b' NOW (CHAIN 3).
#> Chain 3: 
#> Chain 3: Gradient evaluation took 0 seconds
#> Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 3: Adjust your expectations accordingly!
#> Chain 3: 
#> Chain 3: 
#> Chain 3: WARNING: There aren't enough warmup iterations to fit the
#> Chain 3:          three stages of adaptation as currently configured.
#> Chain 3:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 3:          the given number of warmup iterations:
#> Chain 3:            init_buffer = 15
#> Chain 3:            adapt_window = 75
#> Chain 3:            term_buffer = 10
#> Chain 3: 
#> Chain 3: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 3: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 3: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 3: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 3: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 3: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 3: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 3: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 3: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 3: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 3: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 3: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 3: 
#> Chain 3:  Elapsed Time: 0.047 seconds (Warm-up)
#> Chain 3:                0.031 seconds (Sampling)
#> Chain 3:                0.078 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '62c9ea3affe1d932ac4a490a3103581b' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0 seconds.
#> Chain 4: Adjust your expectations accordingly!
#> Chain 4: 
#> Chain 4: 
#> Chain 4: WARNING: There aren't enough warmup iterations to fit the
#> Chain 4:          three stages of adaptation as currently configured.
#> Chain 4:          Reducing each adaptation stage to 15%/75%/10% of
#> Chain 4:          the given number of warmup iterations:
#> Chain 4:            init_buffer = 15
#> Chain 4:            adapt_window = 75
#> Chain 4:            term_buffer = 10
#> Chain 4: 
#> Chain 4: Iteration:   1 / 200 [  0%]  (Warmup)
#> Chain 4: Iteration:  20 / 200 [ 10%]  (Warmup)
#> Chain 4: Iteration:  40 / 200 [ 20%]  (Warmup)
#> Chain 4: Iteration:  60 / 200 [ 30%]  (Warmup)
#> Chain 4: Iteration:  80 / 200 [ 40%]  (Warmup)
#> Chain 4: Iteration: 100 / 200 [ 50%]  (Warmup)
#> Chain 4: Iteration: 101 / 200 [ 50%]  (Sampling)
#> Chain 4: Iteration: 120 / 200 [ 60%]  (Sampling)
#> Chain 4: Iteration: 140 / 200 [ 70%]  (Sampling)
#> Chain 4: Iteration: 160 / 200 [ 80%]  (Sampling)
#> Chain 4: Iteration: 180 / 200 [ 90%]  (Sampling)
#> Chain 4: Iteration: 200 / 200 [100%]  (Sampling)
#> Chain 4: 
#> Chain 4:  Elapsed Time: 0.031 seconds (Warm-up)
#> Chain 4:                0.047 seconds (Sampling)
#> Chain 4:                0.078 seconds (Total)
#> Chain 4:
#> Warning: Bulk Effective Samples Size (ESS) is too low, indicating posterior means and medians may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#bulk-ess

#> Warning: Tail Effective Samples Size (ESS) is too low, indicating posterior variances and tail quantiles may be unreliable.
#> Running the chains for more iterations may help. See
#> https://mc-stan.org/misc/warnings.html#tail-ess
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
#> Intercept     3.60      6.02    -7.90    14.91 1.01      381      264
#> weight       -0.09      0.92    -1.80     1.63 1.01      381      268
#> age          -0.07      0.13    -0.32     0.17 1.01      482      286
#> sexmale      -0.45      2.54    -5.72     3.86 1.03      144      137
#> prior        -7.53      2.16   -11.86    -3.29 1.03      129      149
#> 
#> Family Specific Parameters: 
#>       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
#> sigma     5.50      0.92     4.13     7.74 1.00      273      225
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
#>   term        parameter    bias bias_mcse      mse mse_mcse covered
#>   <chr>           <dbl>   <dbl>     <dbl>    <dbl>    <dbl>   <dbl>
#> 1 (Intercept)       2    1.53      0.946  23.8      4.33       1   
#> 2 age              -0.1 -0.0298    0.0187  0.00925  0.00191    1   
#> 3 prior             0   -4.37      0.392  22.7      3.28       0.48
#> 4 sexmale           0.5 -0.308     0.466   5.32     1.33       0.96
#> 5 weight            0.3 -0.0704    0.151   0.551    0.132      0.88
```

The function also returns the parameter estimates compared to the
previous population’s parameters

``` r
sglm_comps[["prior"]][[1]][,c("term", "parameter", "bias", "bias_mcse", 
                             "mse", "mse_mcse", "covered")]
#> # A tibble: 5 x 7
#>   term        parameter    bias bias_mcse     mse mse_mcse covered
#>   <chr>           <dbl>   <dbl>     <dbl>   <dbl>    <dbl>   <dbl>
#> 1 (Intercept)       2    1.53      0.946  23.8     4.33       1   
#> 2 age              -0.2  0.0702    0.0187  0.0133  0.00350    0.92
#> 3 prior             1   -5.37      0.392  32.5     4.05       0.32
#> 4 sexmale           0.5 -0.308     0.466   5.32    1.33       0.96
#> 5 weight            0.4 -0.170     0.151   0.575   0.142      0.88
```
