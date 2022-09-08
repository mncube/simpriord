test_that("Test 1: sim_sglm returns an object which contains an object of class data frame when run on sim_args
using the data simulated in the Nested Designs section of of the Tidy Simulations
vignette (Source:
          https://cran.r-project.org/web/packages/simglm/vignettes/tidy_simulation.html)",
          {
            nd_out <- sim_sglm(data = NULL,
                               sim_args = list(
                                 formula = y ~ 1 + weight + age + sex + (1 | neighborhood),
                                 reg_weights = c(4, -0.03, 0.2, 0.33),
                                 fixed = list(weight = list(var_type = 'continuous', mean = 180, sd = 30),
                                              age = list(var_type = 'ordinal', levels = 30:60),
                                              sex = list(var_type = 'factor', levels = c('male', 'female'))),
                                 randomeffect = list(int_neighborhood = list(variance = 8, var_level = 2)),
                                 sample_size = list(level1 = 10, level2 = 20)))
            expect_s3_class(
              nd_out$df_mod,
              "data.frame")
            })

test_that("Test 2: sim_sglm throws an error when run on sim_args using the data
simulated in the Nested Designs section of the Tidy Simulations vignette when the
randomeffect line of sim_arguments has been commented out (Source:
          https://cran.r-project.org/web/packages/simglm/vignettes/tidy_simulation.html)",
          {
            expect_error(
              sim_sglm(data = NULL,
                       sim_args = list(
                         formula = y ~ 1 + weight + age + sex + (1 | neighborhood),
                         reg_weights = c(4, -0.03, 0.2, 0.33),
                         fixed = list(weight = list(var_type = 'continuous', mean = 180, sd = 30),
                                      age = list(var_type = 'ordinal', levels = 30:60),
                                      sex = list(var_type = 'factor', levels = c('male', 'female'))),
                         #randomeffect = list(int_neighborhood = list(variance = 8, var_level = 2)),
                         sample_size = list(level1 = 10, level2 = 20))))
            })

test_that("Test 3: sim_sglm returns an object which contains an object of class data frame when run on
sim_args using the data simulated in the Generate Response Variable section of
the Tidy Simulations vignette (Source:
          https://cran.r-project.org/web/packages/simglm/vignettes/tidy_simulation.html)",
          {
            grv_out <- sim_sglm(data = NULL,
                                sim_args = list(
                                  formula = y ~ 1 + weight + age + sex,
                                  fixed = list(weight = list(var_type = 'continuous', mean = 180, sd = 30),
                                               age = list(var_type = 'ordinal', levels = 30:60),
                                               sex = list(var_type = 'factor', levels = c('male', 'female'))),
                                  error = list(variance = 25),
                                  sample_size = 10,
                                  reg_weights = c(2, 0.3, -0.1, 0.5)))
            expect_s3_class(
              grv_out$df_mod,
              "data.frame")
            })
