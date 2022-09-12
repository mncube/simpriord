
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
#>   X.Intercept.     weight age sex_1    sex level1_id       error fixed_outcome
#> 1            1  0.5842873  34     0 female         1 -0.09887233    -1.2247138
#> 2            1  0.7292133  56     0 female         2  8.55904198    -3.3812360
#> 3            1  0.7433073  51     1   male         3  2.13622618    -2.3770078
#> 4            1  0.9292140  30     0 female         4  3.41962149    -0.7212358
#> 5            1 -0.1708646  37     0 female         5 -7.49823838    -1.7512594
#> 6            1 -0.2664791  33     0 female         6  2.54643264    -1.3799437
#>   random_effects          y prior
#> 1              0 -1.3235861     0
#> 2              0  5.1778060     0
#> 3              0 -0.2407816     0
#> 4              0  2.6983857     0
#> 5              0 -9.2494978     0
#> 6              0  1.1664889     0
tail(grv_out$df_mod[[1]])
#>    X.Intercept.     weight age sex_1    sex level1_id     error fixed_outcome
#> 20            1 -1.4195196  55     0 female         5 -1.587697     -9.567808
#> 21            1 -0.4082922  40     0 female         6  4.478238     -6.163317
#> 22            1 -4.4236917  35     1   male         7 13.715806     -6.269477
#> 23            1  1.9384201  47     1   male         8  2.697935     -6.124632
#> 24            1 -0.9407003  51     0 female         9  1.941786     -8.576280
#> 25            1  0.6748086  36     1   male        10  4.697821     -4.430077
#>    random_effects           y prior
#> 20              0 -11.1555051     1
#> 21              0  -1.6850787     1
#> 22              0   7.4463296     1
#> 23              0  -3.4266973     1
#> 24              0  -6.6344941     1
#> 25              0   0.2677447     1

#Extract data generating information for the first dataframe's main data
grv_out$df_info[[1]]$main
#> $sim_args
#> $sim_args$formula
#> y ~ 1 + weight + age + sex
#> <environment: 0x0000000014e8aeb0>
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
#> <environment: 0x0000000014e8aeb0>
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
#> 
#> SAMPLING FOR MODEL '80df5b78aeebf6566dac5f6e5e2e31e8' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.151 seconds (Warm-up)
#> Chain 1:                0.075 seconds (Sampling)
#> Chain 1:                0.226 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '80df5b78aeebf6566dac5f6e5e2e31e8' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.104 seconds (Warm-up)
#> Chain 2:                0.082 seconds (Sampling)
#> Chain 2:                0.186 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '80df5b78aeebf6566dac5f6e5e2e31e8' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.07 seconds (Warm-up)
#> Chain 3:                0.058 seconds (Sampling)
#> Chain 3:                0.128 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '80df5b78aeebf6566dac5f6e5e2e31e8' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.066 seconds (Warm-up)
#> Chain 4:                0.059 seconds (Sampling)
#> Chain 4:                0.125 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '361b3ab9c24c301a9dd088f3ab1b31bd' NOW (CHAIN 1).
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
#> Chain 1:                0.069 seconds (Sampling)
#> Chain 1:                0.142 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '361b3ab9c24c301a9dd088f3ab1b31bd' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.177 seconds (Warm-up)
#> Chain 2:                0.241 seconds (Sampling)
#> Chain 2:                0.418 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '361b3ab9c24c301a9dd088f3ab1b31bd' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.106 seconds (Warm-up)
#> Chain 3:                0.114 seconds (Sampling)
#> Chain 3:                0.22 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '361b3ab9c24c301a9dd088f3ab1b31bd' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.12 seconds (Warm-up)
#> Chain 4:                0.128 seconds (Sampling)
#> Chain 4:                0.248 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '9fe3ef62531d5b787d6f21ea541c181c' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.179 seconds (Warm-up)
#> Chain 1:                0.079 seconds (Sampling)
#> Chain 1:                0.258 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '9fe3ef62531d5b787d6f21ea541c181c' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.071 seconds (Warm-up)
#> Chain 2:                0.079 seconds (Sampling)
#> Chain 2:                0.15 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '9fe3ef62531d5b787d6f21ea541c181c' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.07 seconds (Warm-up)
#> Chain 3:                0.083 seconds (Sampling)
#> Chain 3:                0.153 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '9fe3ef62531d5b787d6f21ea541c181c' NOW (CHAIN 4).
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
#> Chain 4:                0.097 seconds (Sampling)
#> Chain 4:                0.187 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '065e45a68c879ae432f2ee2058943446' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.136 seconds (Warm-up)
#> Chain 1:                0.093 seconds (Sampling)
#> Chain 1:                0.229 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '065e45a68c879ae432f2ee2058943446' NOW (CHAIN 2).
#> Chain 2: 
#> Chain 2: Gradient evaluation took 0.001 seconds
#> Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 10 seconds.
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
#> Chain 2:  Elapsed Time: 0.073 seconds (Warm-up)
#> Chain 2:                0.08 seconds (Sampling)
#> Chain 2:                0.153 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '065e45a68c879ae432f2ee2058943446' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.076 seconds (Warm-up)
#> Chain 3:                0.058 seconds (Sampling)
#> Chain 3:                0.134 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '065e45a68c879ae432f2ee2058943446' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.095 seconds (Warm-up)
#> Chain 4:                0.114 seconds (Sampling)
#> Chain 4:                0.209 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'c0f98f8efe6a55c7b47580083304aff3' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.092 seconds (Warm-up)
#> Chain 1:                0.072 seconds (Sampling)
#> Chain 1:                0.164 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'c0f98f8efe6a55c7b47580083304aff3' NOW (CHAIN 2).
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
#> Chain 2:                0.115 seconds (Sampling)
#> Chain 2:                0.192 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'c0f98f8efe6a55c7b47580083304aff3' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.083 seconds (Warm-up)
#> Chain 3:                0.049 seconds (Sampling)
#> Chain 3:                0.132 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'c0f98f8efe6a55c7b47580083304aff3' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.05 seconds (Warm-up)
#> Chain 4:                0.031 seconds (Sampling)
#> Chain 4:                0.081 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '22d150648877aadce1bc109376a92dd5' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.17 seconds (Warm-up)
#> Chain 1:                0.109 seconds (Sampling)
#> Chain 1:                0.279 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '22d150648877aadce1bc109376a92dd5' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.072 seconds (Warm-up)
#> Chain 2:                0.066 seconds (Sampling)
#> Chain 2:                0.138 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '22d150648877aadce1bc109376a92dd5' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.066 seconds (Warm-up)
#> Chain 3:                0.052 seconds (Sampling)
#> Chain 3:                0.118 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '22d150648877aadce1bc109376a92dd5' NOW (CHAIN 4).
#> Chain 4: 
#> Chain 4: Gradient evaluation took 0.001 seconds
#> Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 10 seconds.
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
#> Chain 4:  Elapsed Time: 0.061 seconds (Warm-up)
#> Chain 4:                0.057 seconds (Sampling)
#> Chain 4:                0.118 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '27f4e2f9eb4b71452434c9d4bf17bf39' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.063 seconds (Warm-up)
#> Chain 1:                0.062 seconds (Sampling)
#> Chain 1:                0.125 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '27f4e2f9eb4b71452434c9d4bf17bf39' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.078 seconds (Warm-up)
#> Chain 2:                0.063 seconds (Sampling)
#> Chain 2:                0.141 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '27f4e2f9eb4b71452434c9d4bf17bf39' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.078 seconds (Warm-up)
#> Chain 3:                0.063 seconds (Sampling)
#> Chain 3:                0.141 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '27f4e2f9eb4b71452434c9d4bf17bf39' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.078 seconds (Warm-up)
#> Chain 4:                0.063 seconds (Sampling)
#> Chain 4:                0.141 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '8fc93ab40aa41f6d29248ee2b14c946c' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.091 seconds (Warm-up)
#> Chain 1:                0.101 seconds (Sampling)
#> Chain 1:                0.192 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '8fc93ab40aa41f6d29248ee2b14c946c' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.24 seconds (Warm-up)
#> Chain 2:                0.322 seconds (Sampling)
#> Chain 2:                0.562 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '8fc93ab40aa41f6d29248ee2b14c946c' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.209 seconds (Warm-up)
#> Chain 3:                0.112 seconds (Sampling)
#> Chain 3:                0.321 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '8fc93ab40aa41f6d29248ee2b14c946c' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.173 seconds (Warm-up)
#> Chain 4:                0.274 seconds (Sampling)
#> Chain 4:                0.447 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'ffd16dced1fdcdbf2cd0fc491bd520fd' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.078 seconds (Warm-up)
#> Chain 1:                0.047 seconds (Sampling)
#> Chain 1:                0.125 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'ffd16dced1fdcdbf2cd0fc491bd520fd' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.063 seconds (Warm-up)
#> Chain 2:                0.062 seconds (Sampling)
#> Chain 2:                0.125 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'ffd16dced1fdcdbf2cd0fc491bd520fd' NOW (CHAIN 3).
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
#> Chain 3:                0.078 seconds (Sampling)
#> Chain 3:                0.125 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'ffd16dced1fdcdbf2cd0fc491bd520fd' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.094 seconds (Warm-up)
#> Chain 4:                0.063 seconds (Sampling)
#> Chain 4:                0.157 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'ed51a637184841f091453c7aa7b3291a' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.074 seconds (Warm-up)
#> Chain 1:                0.061 seconds (Sampling)
#> Chain 1:                0.135 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'ed51a637184841f091453c7aa7b3291a' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.1 seconds (Warm-up)
#> Chain 2:                0.083 seconds (Sampling)
#> Chain 2:                0.183 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'ed51a637184841f091453c7aa7b3291a' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.117 seconds (Warm-up)
#> Chain 3:                0.082 seconds (Sampling)
#> Chain 3:                0.199 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'ed51a637184841f091453c7aa7b3291a' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.07 seconds (Warm-up)
#> Chain 4:                0.065 seconds (Sampling)
#> Chain 4:                0.135 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '811879913dc55af57c2a5681470d9999' NOW (CHAIN 1).
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
#> Chain 1:                0.063 seconds (Sampling)
#> Chain 1:                0.127 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '811879913dc55af57c2a5681470d9999' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.07 seconds (Warm-up)
#> Chain 2:                0.063 seconds (Sampling)
#> Chain 2:                0.133 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '811879913dc55af57c2a5681470d9999' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.089 seconds (Warm-up)
#> Chain 3:                0.069 seconds (Sampling)
#> Chain 3:                0.158 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '811879913dc55af57c2a5681470d9999' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.08 seconds (Warm-up)
#> Chain 4:                0.073 seconds (Sampling)
#> Chain 4:                0.153 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '8d8fb87d6dc8ac13e3a726ea421509b5' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.081 seconds (Warm-up)
#> Chain 1:                0.061 seconds (Sampling)
#> Chain 1:                0.142 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '8d8fb87d6dc8ac13e3a726ea421509b5' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.063 seconds (Warm-up)
#> Chain 2:                0.061 seconds (Sampling)
#> Chain 2:                0.124 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '8d8fb87d6dc8ac13e3a726ea421509b5' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.054 seconds (Warm-up)
#> Chain 3:                0.054 seconds (Sampling)
#> Chain 3:                0.108 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '8d8fb87d6dc8ac13e3a726ea421509b5' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.082 seconds (Warm-up)
#> Chain 4:                0.063 seconds (Sampling)
#> Chain 4:                0.145 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '06a82c9c905b0a8ec65a9dd772b6f7ee' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.037 seconds (Warm-up)
#> Chain 1:                0.044 seconds (Sampling)
#> Chain 1:                0.081 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '06a82c9c905b0a8ec65a9dd772b6f7ee' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.047 seconds (Warm-up)
#> Chain 2:                0.041 seconds (Sampling)
#> Chain 2:                0.088 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '06a82c9c905b0a8ec65a9dd772b6f7ee' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.05 seconds (Warm-up)
#> Chain 3:                0.039 seconds (Sampling)
#> Chain 3:                0.089 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '06a82c9c905b0a8ec65a9dd772b6f7ee' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.043 seconds (Warm-up)
#> Chain 4:                0.043 seconds (Sampling)
#> Chain 4:                0.086 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '1485ca9d54d1e8d4be7f09c65f624ca7' NOW (CHAIN 1).
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
#> Chain 1:                0.059 seconds (Sampling)
#> Chain 1:                0.127 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '1485ca9d54d1e8d4be7f09c65f624ca7' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.066 seconds (Warm-up)
#> Chain 2:                0.079 seconds (Sampling)
#> Chain 2:                0.145 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '1485ca9d54d1e8d4be7f09c65f624ca7' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.075 seconds (Warm-up)
#> Chain 3:                0.073 seconds (Sampling)
#> Chain 3:                0.148 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '1485ca9d54d1e8d4be7f09c65f624ca7' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.069 seconds (Warm-up)
#> Chain 4:                0.059 seconds (Sampling)
#> Chain 4:                0.128 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'a53bfbacd27a3456355de5b0f36de5d5' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.054 seconds (Warm-up)
#> Chain 1:                0.058 seconds (Sampling)
#> Chain 1:                0.112 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'a53bfbacd27a3456355de5b0f36de5d5' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.068 seconds (Warm-up)
#> Chain 2:                0.058 seconds (Sampling)
#> Chain 2:                0.126 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'a53bfbacd27a3456355de5b0f36de5d5' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.077 seconds (Warm-up)
#> Chain 3:                0.066 seconds (Sampling)
#> Chain 3:                0.143 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'a53bfbacd27a3456355de5b0f36de5d5' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.068 seconds (Warm-up)
#> Chain 4:                0.059 seconds (Sampling)
#> Chain 4:                0.127 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '227b50178d07496b0e353602344abbd8' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.061 seconds (Warm-up)
#> Chain 1:                0.046 seconds (Sampling)
#> Chain 1:                0.107 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '227b50178d07496b0e353602344abbd8' NOW (CHAIN 2).
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
#> Chain 2:                0.051 seconds (Sampling)
#> Chain 2:                0.116 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '227b50178d07496b0e353602344abbd8' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.051 seconds (Warm-up)
#> Chain 3:                0.044 seconds (Sampling)
#> Chain 3:                0.095 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '227b50178d07496b0e353602344abbd8' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.042 seconds (Warm-up)
#> Chain 4:                0.038 seconds (Sampling)
#> Chain 4:                0.08 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'fb2bae5e172c8dac368b5781a01ed31c' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.055 seconds (Warm-up)
#> Chain 1:                0.047 seconds (Sampling)
#> Chain 1:                0.102 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'fb2bae5e172c8dac368b5781a01ed31c' NOW (CHAIN 2).
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
#> Chain 2:                0.069 seconds (Sampling)
#> Chain 2:                0.118 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'fb2bae5e172c8dac368b5781a01ed31c' NOW (CHAIN 3).
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
#> Chain 3:                0.072 seconds (Sampling)
#> Chain 3:                0.136 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'fb2bae5e172c8dac368b5781a01ed31c' NOW (CHAIN 4).
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
#> Chain 4:                0.06 seconds (Sampling)
#> Chain 4:                0.137 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'a3599966e14d56246b7ca4a87ef41832' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.251 seconds (Warm-up)
#> Chain 1:                0.22 seconds (Sampling)
#> Chain 1:                0.471 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'a3599966e14d56246b7ca4a87ef41832' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.094 seconds (Warm-up)
#> Chain 2:                0.073 seconds (Sampling)
#> Chain 2:                0.167 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'a3599966e14d56246b7ca4a87ef41832' NOW (CHAIN 3).
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
#> Chain 3:                0.059 seconds (Sampling)
#> Chain 3:                0.147 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'a3599966e14d56246b7ca4a87ef41832' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.15 seconds (Warm-up)
#> Chain 4:                0.088 seconds (Sampling)
#> Chain 4:                0.238 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'd75e04a16abf8d4c1ef7f4803e3f2d3e' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.086 seconds (Warm-up)
#> Chain 1:                0.091 seconds (Sampling)
#> Chain 1:                0.177 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'd75e04a16abf8d4c1ef7f4803e3f2d3e' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.1 seconds (Warm-up)
#> Chain 2:                0.092 seconds (Sampling)
#> Chain 2:                0.192 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'd75e04a16abf8d4c1ef7f4803e3f2d3e' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.071 seconds (Warm-up)
#> Chain 3:                0.068 seconds (Sampling)
#> Chain 3:                0.139 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'd75e04a16abf8d4c1ef7f4803e3f2d3e' NOW (CHAIN 4).
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
#> 
#> SAMPLING FOR MODEL '5b1a2724cfc349bac99d9c72cb5aa671' NOW (CHAIN 1).
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
#> Chain 1:                0.043 seconds (Sampling)
#> Chain 1:                0.099 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '5b1a2724cfc349bac99d9c72cb5aa671' NOW (CHAIN 2).
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
#> Chain 2:                0.049 seconds (Sampling)
#> Chain 2:                0.097 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '5b1a2724cfc349bac99d9c72cb5aa671' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.055 seconds (Warm-up)
#> Chain 3:                0.041 seconds (Sampling)
#> Chain 3:                0.096 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '5b1a2724cfc349bac99d9c72cb5aa671' NOW (CHAIN 4).
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
#> Chain 4:                0.041 seconds (Sampling)
#> Chain 4:                0.097 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'ba89f5fbaafe88b0724ec5f5f9691856' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.05 seconds (Warm-up)
#> Chain 1:                0.036 seconds (Sampling)
#> Chain 1:                0.086 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'ba89f5fbaafe88b0724ec5f5f9691856' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.059 seconds (Warm-up)
#> Chain 2:                0.062 seconds (Sampling)
#> Chain 2:                0.121 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'ba89f5fbaafe88b0724ec5f5f9691856' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.052 seconds (Warm-up)
#> Chain 3:                0.055 seconds (Sampling)
#> Chain 3:                0.107 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'ba89f5fbaafe88b0724ec5f5f9691856' NOW (CHAIN 4).
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
#> Chain 4:                0.063 seconds (Sampling)
#> Chain 4:                0.119 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'ec6bf8acfe24d0324f185e660bd31711' NOW (CHAIN 1).
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
#> Chain 1:                0.054 seconds (Sampling)
#> Chain 1:                0.12 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'ec6bf8acfe24d0324f185e660bd31711' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.057 seconds (Warm-up)
#> Chain 2:                0.047 seconds (Sampling)
#> Chain 2:                0.104 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'ec6bf8acfe24d0324f185e660bd31711' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.058 seconds (Warm-up)
#> Chain 3:                0.047 seconds (Sampling)
#> Chain 3:                0.105 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'ec6bf8acfe24d0324f185e660bd31711' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.057 seconds (Warm-up)
#> Chain 4:                0.048 seconds (Sampling)
#> Chain 4:                0.105 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL 'b0cc248a9b7154705e64ea887d2f51ea' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.053 seconds (Warm-up)
#> Chain 1:                0.055 seconds (Sampling)
#> Chain 1:                0.108 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL 'b0cc248a9b7154705e64ea887d2f51ea' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.064 seconds (Warm-up)
#> Chain 2:                0.061 seconds (Sampling)
#> Chain 2:                0.125 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL 'b0cc248a9b7154705e64ea887d2f51ea' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.065 seconds (Warm-up)
#> Chain 3:                0.059 seconds (Sampling)
#> Chain 3:                0.124 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL 'b0cc248a9b7154705e64ea887d2f51ea' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.058 seconds (Warm-up)
#> Chain 4:                0.059 seconds (Sampling)
#> Chain 4:                0.117 seconds (Total)
#> Chain 4: 
#> 
#> SAMPLING FOR MODEL '42d59d9f3301c41c9a66c4869cae57f8' NOW (CHAIN 1).
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
#> Chain 1:  Elapsed Time: 0.075 seconds (Warm-up)
#> Chain 1:                0.075 seconds (Sampling)
#> Chain 1:                0.15 seconds (Total)
#> Chain 1: 
#> 
#> SAMPLING FOR MODEL '42d59d9f3301c41c9a66c4869cae57f8' NOW (CHAIN 2).
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
#> Chain 2:  Elapsed Time: 0.089 seconds (Warm-up)
#> Chain 2:                0.076 seconds (Sampling)
#> Chain 2:                0.165 seconds (Total)
#> Chain 2: 
#> 
#> SAMPLING FOR MODEL '42d59d9f3301c41c9a66c4869cae57f8' NOW (CHAIN 3).
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
#> Chain 3:  Elapsed Time: 0.11 seconds (Warm-up)
#> Chain 3:                0.077 seconds (Sampling)
#> Chain 3:                0.187 seconds (Total)
#> Chain 3: 
#> 
#> SAMPLING FOR MODEL '42d59d9f3301c41c9a66c4869cae57f8' NOW (CHAIN 4).
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
#> Chain 4:  Elapsed Time: 0.089 seconds (Warm-up)
#> Chain 4:                0.09 seconds (Sampling)
#> Chain 4:                0.179 seconds (Total)
#> Chain 4: 
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
#> Chain 1:  Elapsed Time: 0.067 seconds (Warm-up)
#> Chain 1:                0.052 seconds (Sampling)
#> Chain 1:                0.119 seconds (Total)
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
#> Chain 2:  Elapsed Time: 0.059 seconds (Warm-up)
#> Chain 2:                0.057 seconds (Sampling)
#> Chain 2:                0.116 seconds (Total)
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
#> Chain 3:  Elapsed Time: 0.067 seconds (Warm-up)
#> Chain 3:                0.066 seconds (Sampling)
#> Chain 3:                0.133 seconds (Total)
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
#> Chain 4:  Elapsed Time: 0.07 seconds (Warm-up)
#> Chain 4:                0.06 seconds (Sampling)
#> Chain 4:                0.13 seconds (Total)
#> Chain 4:
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
#> Intercept     7.03      5.92    -3.80    18.47 1.00      443      366
#> weight       -0.92      0.87    -2.60     0.82 1.02      439      295
#> age          -0.20      0.13    -0.45     0.04 0.99      476      371
#> sexmale       0.81      2.33    -3.22     5.42 1.03      190      205
#> prior        -3.21      2.47    -7.90     1.88 1.04      178       86
#> 
#> Family Specific Parameters: 
#>       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
#> sigma     5.49      0.93     4.06     7.51 1.00      381      310
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
#> 1 (Intercept)       2    0.721     1.10   29.7     8.30       0.96
#> 2 age              -0.1 -0.0124    0.0221  0.0119  0.00293    1   
#> 3 prior             0   -4.90      0.544  31.1     6.69       0.48
#> 4 sexmale           0.5  0.494     0.361   3.37    0.777      1   
#> 5 weight            0.3 -0.0833    0.156   0.588   0.133      1
```

The function also returns the parameter estimates compared to the
previous population’s parameters

``` r
sglm_comps[["prior"]][[1]][,c("term", "parameter", "bias", "bias_mcse", 
                             "mse", "mse_mcse", "covered")]
#> # A tibble: 5 x 7
#>   term        parameter    bias bias_mcse     mse mse_mcse covered
#>   <chr>           <dbl>   <dbl>     <dbl>   <dbl>    <dbl>   <dbl>
#> 1 (Intercept)       2    0.721     1.10   29.7     8.30       0.96
#> 2 age              -0.2  0.0876    0.0221  0.0194  0.00573    0.84
#> 3 prior             1   -5.90      0.544  42.0     7.74       0.36
#> 4 sexmale           0.5  0.494     0.361   3.37    0.777      1   
#> 5 weight            0.4 -0.183     0.156   0.615   0.144      1
```
