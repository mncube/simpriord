test_that("Test 1: sim_sglm_run returns an object of class list when run on
sim_args using data similar to that simulated in the Generate Response Variable section of
the Tidy Simulations vignette (Source:
          https://cran.r-project.org/web/packages/simglm/vignettes/tidy_simulation.html)",
          {
            #Get main data
            args_main <- list(
              formula = y ~ 1 + weight + age + sex,
              fixed = list(weight = list(var_type = 'continuous', mean = 0, sd = 1),
                           age = list(var_type = 'ordinal', levels = 30:60),
                           sex = list(var_type = 'factor', levels = c('male', 'female'))),
              error = list(variance = 25),
              sample_size = 10,
              reg_weights = c(2, 0.3, -0.1, 0.5)
            )

            #Get prior data
            args_prior <- list(
              formula = y ~ 1 + weight + age + sex,
              fixed = list(weight = list(var_type = 'continuous', mean = 0, sd = 2),
                           age = list(var_type = 'ordinal', levels = 30:60),
                           sex = list(var_type = 'factor', levels = c('male', 'female'))),
              error = list(variance = 25),
              sample_size = 10,
              reg_weights = c(2, 0.4, -0.2, 0.5)
            )

            #Return data frames with info
            grv_out <- sim_sglm_dfs(data_m = NULL,
                                    sim_args_m = args_main,
                                    data_p = NULL,
                                    sim_args_p = args_prior,
                                    with_prior = 1,
                                    frames = 2,
                                    mod_name = list("mod1"))

            #Fit data to model
            sglm_mod_fits <- sim_sglm_run(df_list = list(grv_out), iter = 3)

            expect_equal(
              class(sglm_mod_fits),
              "list")
          })

test_that("Test 2: sim_sglm_run returns an object of class list when run on
sim_args using no prior data",
          {
            #Get main data
            args_main <- list(
              formula = y ~ 1 + weight + age + sex,
              fixed = list(weight = list(var_type = 'continuous', mean = 0, sd = 1),
                           age = list(var_type = 'ordinal', levels = 30:60),
                           sex = list(var_type = 'factor', levels = c('male', 'female'))),
              error = list(variance = 25),
              sample_size = 10,
              reg_weights = c(2, 0.3, -0.1, 0.5)
            )

            #Return data frames with info
            grv_out <- sim_sglm_dfs(data_m = NULL,
                                    sim_args_m = args_main,
                                    data_p = NULL,
                                    with_prior = 0,
                                    frames = 2,
                                    mod_name = list("mod1"))

            #Fit data to model
            sglm_mod_fits <- sim_sglm_run(df_list = list(grv_out), iter = 3)

            expect_equal(
              class(sglm_mod_fits),
              "list")
          })
