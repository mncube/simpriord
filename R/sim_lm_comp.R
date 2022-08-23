#' Compare Linear Model Performance Metrics
#'
#' @param fit_obj A list of model fits built from the sim_lm_run function
#'
#' @param with_prior Set to 0 if data does not contain prior data.
#'
#' @return a nested list of performance metric data frames.  One top level list for the main data
#' and one top level list for the prior data.  Within each top level list, there is one data frame of
#' performance metrics for each model.
#'
#' @importFrom stats sd var
#'
#' @export
sim_lm_comp <- function(fit_obj, with_prior = 1){

  #Create local bindings for variables
  `1` <- NULL
  `2` <- NULL
  K <- NULL
  bias <- NULL
  bias_j_sq <- NULL
  bias_mcse <- NULL
  conf.high <- NULL
  conf.low <- NULL
  covered <- NULL
  estimate <- NULL
  g_t <- NULL
  k_t <- NULL
  mse <- NULL
  mse_mcse <- NULL
  parameter <- NULL
  rmse <- NULL
  rmse_j <- NULL
  rmse_mcse <- NULL
  s_sq_t_j <- NULL
  s_t <- NULL
  t_bar <- NULL
  t_bar_j <- NULL
  term <- NULL
  true_param <- NULL
  var_mcse <- NULL
  var_t <- NULL
  var <- NULL

  #Initialize list to store fit dfs
  all_prior <- all_main <- vector(mode = "list", length = length(fit_obj$fits))

  #Get fits
  for (i in 1:length(fit_obj$fits)){

    #Collect model fits and info for each simulation
    mod_infos <- fit_obj$info[[i]]
    mod_fits <- fit_obj$fits[[i]]

    #Get simulation results for each simulation
    for (j in 1:length(mod_fits)){

      #Initialize list to store results
      if (j == 1){
        res_prior <- res_main <- vector(mode = "list", length = length(mod_fits))
      }

      #Tidy model fit
      tidy_fit <- broom.mixed::tidy(mod_fits[[j]])

      #Get model alias as isolated data frame
      mod_name <- mod_infos[[j]] %>%
        dplyr::select(mod_name) %>%
        dplyr::slice_head(n = 1)

      #Connect model fit with model info
      if (nrow(mod_infos[[j]]) == 1 | with_prior == 0){
        comp_main <- cbind(tidy_fit,
                           t(mod_infos[[j]][mod_infos[[j]]$prior == 0,]),
                           mod_name) %>%
          dplyr::rename(parameter = `1`) %>%
          dplyr::slice_head(n = -1)
        comp_prior <- as.data.frame("No Prior")
      } else {
        comp_main <- cbind(tidy_fit,
                           t(mod_infos[[j]][mod_infos[[j]]$prior == 0,]),
                           mod_name) %>%
          dplyr::rename(parameter = `1`) %>%
          dplyr::slice_head(n = -1)
        comp_prior <- cbind(tidy_fit,
                            t(mod_infos[[j]][mod_infos[[j]]$prior == 1,]),
                            mod_name) %>%
          dplyr::rename(parameter = `2`) %>%
          dplyr::slice_head(n = -1)
      }

      #Return results from each simulation
      res_main[[j]] <- comp_main
      res_prior[[j]] <- comp_prior

      #Bind results and perform get performance metrics on last loop through j
      if (j == length(mod_fits)){
        res_main <- do.call(rbind, res_main)

        res_main <- res_main %>% dplyr::mutate(parameter = as.numeric(parameter)) %>%
          dplyr::mutate(covered = ifelse(parameter >= conf.low & parameter <= conf.high, 1, 0)) %>%
          dplyr::group_by(term) %>%
          dplyr::summarise(true_param = mean(parameter),
                           K = dplyr::n(),
                           t_bar = mean(estimate), # mean of estimates
                           bias = t_bar - true_param, # bias
                           var_t =  var(estimate), # variance
                           s_t = sd(estimate), # standard deviation
                           g_t = (1/(K * s_t^3)) * sum((estimate - t_bar)^3), # skewness
                           k_t = (1/(K * s_t^4)) * sum((estimate - t_bar)^4), # kurtosis
                           mse = mean((estimate - true_param)^2),  # calculate mse
                           #jacknife
                           t_bar_j = (1/(K - 1)) * (K * t_bar - estimate), # jacknife t bar
                           bias_j_sq = (t_bar_j - true_param)^2, # jacknife bias
                           s_sq_t_j = (1 / (K - 2)) * ((K - 1) * var_t - (K / (K - 1)) * (estimate - t_bar)^2), # jacknife var
                           rmse_j = sqrt(bias_j_sq + s_sq_t_j), # jacknife rmse
                           bias_mcse = sqrt(var_t / K),
                           var_mcse = var_t * sqrt(((k_t - 1) / K)),
                           mse_mcse = sqrt((1/K) * (s_t^4 * (k_t -1) + 4 * s_t^3 * g_t * bias + 4 * var_t * bias^2)),
                          rmse = sqrt(mse),
                          rmse_mcse = sqrt(((K - 1)/(K)) * sum((rmse_j - rmse)^2)),
                          covered = mean(covered)) %>%
          dplyr::ungroup() %>%
          dplyr::select(term, parameter = true_param, iteration = K, bias, bias_mcse,
                        var = var_t, var_mcse, mse, mse_mcse, rmse, rmse_mcse,
                        covered) %>%
          dplyr::distinct()

        if (with_prior != 0){

          res_prior <- do.call(rbind, res_prior)

          res_prior <- res_prior %>% dplyr::mutate(parameter = as.numeric(parameter)) %>%
            dplyr::mutate(covered = ifelse(parameter >= conf.low & parameter <= conf.high, 1, 0)) %>%
            dplyr::group_by(term) %>%
            dplyr::summarise(true_param = mean(parameter),
                             K = dplyr::n(),
                             t_bar = mean(estimate), # mean of estimates
                             bias = t_bar - true_param, # bias
                             var_t =  var(estimate), # variance
                             s_t = sd(estimate), # standard deviation
                             g_t = (1/(K * s_t^3)) * sum((estimate - t_bar)^3), # skewness
                             k_t = (1/(K * s_t^4)) * sum((estimate - t_bar)^4), # kurtosis
                             mse = mean((estimate - true_param)^2),  # calculate mse
                             #jacknife
                             t_bar_j = (1/(K - 1)) * (K * t_bar - estimate), # jacknife t bar
                             bias_j_sq = (t_bar_j - true_param)^2, # jacknife bias
                             s_sq_t_j = (1 / (K - 2)) * ((K - 1) * var_t - (K / (K - 1)) * (estimate - t_bar)^2), # jacknife var
                             rmse_j = sqrt(bias_j_sq + s_sq_t_j), # jacknife rmse
                             bias_mcse = sqrt(var_t / K),
                             var_mcse = var_t * sqrt(((k_t - 1) / K)),
                             mse_mcse = sqrt((1/K) * (s_t^4 * (k_t -1) + 4 * s_t^3 * g_t * bias + 4 * var_t * bias^2)),
                             rmse = sqrt(mse),
                             rmse_mcse = sqrt(((K - 1)/(K)) * sum((rmse_j - rmse)^2)),
                             covered = mean(covered)) %>%
            dplyr::ungroup() %>%
            dplyr::select(term, parameter = true_param, iteration = K, bias, bias_mcse,
                          var = var_t, var_mcse, mse, mse_mcse, rmse, rmse_mcse,
                          covered) %>%
            dplyr::distinct()
        }
      }
    }

    #Store across simulations
    all_main[[i]] <- res_main
    all_prior[[i]] <- res_prior
  }

  #Collect output in list
  output <- list("main" = all_main,
                "prior" = all_prior)
  }
