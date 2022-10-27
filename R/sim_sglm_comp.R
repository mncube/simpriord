#' sim_sglm_comp
#'
#' Compare model performance metrics for sim_sglm_run model fits using measures
#' of estimator performance found in the simhelpers' calc_absolute function.
#'
#' @references
#' Joshi M, Pustejovsky J (2022). _simhelpers: Helper Functions for Simulation
#' Studies_. R package version 0.1.2,
#' <https://CRAN.R-project.org/package=simhelpers>.
#'
#' @param fit_obj Model fits built from the sim_sglm_run function
#' @param with_prior Set to 0 if data does not contain prior data.
#'
#' @return  A nested list of performance metric data frames.
#'
#' @importFrom stats sd var
#'
#' @export
sim_sglm_comp <- function(fit_obj, with_prior = 1){

  #Create local bindings for variables
  `"Intercept"` <- NULL
  `"prior"` <- NULL
  V1 <- NULL
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
  parnames <- NULL
  effect <- NULL

  if (with_prior == 0){
    `mod_infos[[j]]$sim_args$reg_weights` <- NULL
    `mod_infos[[j]]$prior` <- NULL
    `mod_infos[[j]]r$sim_args$reg_weights` <- NULL
    `mod_infos[[j]]$prior` <- NULL
  } else {
    `mod_infos[[j]]$main$sim_args$reg_weights` <- NULL
    `mod_infos[[j]]$main$prior` <- NULL
    `mod_infos[[j]]$prior$sim_args$reg_weights` <- NULL
    `mod_infos[[j]]$prior$prior` <- NULL
  }

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
      if (with_prior == 0){

        mod_name <- as.data.frame(mod_infos[[j]]$mod_name)

      } else {

        mod_name <- as.data.frame(mod_infos[[j]]$main$mod_name)

      }

      colnames(mod_name) <- "mod_name"
      #%>%
        #dplyr::rename(mod_name = `mod_infos[[j]]$prior$mod_name`)
      #  dplyr::rename(mod_name = 1)

      #Get Intercept as isolated data frame
      mod_int <- as.data.frame("Intercept") %>%
        dplyr::rename(Intercept = `"Intercept"`)


      #Get Prior as isolated data frame
      mod_prior <- as.data.frame("prior") %>%
        dplyr::rename(prior = `"prior"`)

      if (with_prior == 0) {

        #Get main parameter information
        comp_main_parnames <- as.data.frame(t(cbind(mod_int,
                                                    as.data.frame(strsplit(names(mod_infos[[j]]$sim_args$fixed), " ")),
                                                    mod_prior))) %>%
          dplyr::rename(parnames = V1) %>%
          dplyr::filter(parnames != "prior")


        comp_main_pars <- dplyr::bind_rows(as.data.frame(mod_infos[[j]]$sim_args$reg_weights) %>%
                                             dplyr::rename(parameter = `mod_infos[[j]]$sim_args$reg_weights`),
                                           as.data.frame(mod_infos[[j]]$prior) %>%
                                             dplyr::rename(parameter = `mod_infos[[j]]$prior`)) %>%
          dplyr::slice_head(n = -1)

      } else {

        #Get main parameter information
        comp_main_parnames <- as.data.frame(t(cbind(mod_int,
                                                    as.data.frame(strsplit(names(mod_infos[[j]]$main$sim_args$fixed), " ")),
                                                    mod_prior))) %>%
          dplyr::rename(parnames = V1)

        comp_main_pars <- dplyr::bind_rows(as.data.frame(mod_infos[[j]]$main$sim_args$reg_weights) %>%
                                             dplyr::rename(parameter = `mod_infos[[j]]$main$sim_args$reg_weights`),
                                           as.data.frame(mod_infos[[j]]$main$prior) %>%
                                             dplyr::rename(parameter = `mod_infos[[j]]$main$prior`))

      }

      #Connect model fit with model info
      ### Come back and fix section with mod_infos[[j]]) == 1 | with_prior == 0
      if (length(mod_infos[[j]]) == 1 | with_prior == 0){
        comp_main <- cbind(tidy_fit %>% dplyr::filter(effect != "ran_pars"),#dplyr::slice_head(n = -1),
                           comp_main_parnames,
                           comp_main_pars)
        #comp_prior <- as.data.frame("No Prior")

        comp_prior <- comp_main
        comp_prior[!is.na(comp_prior)] <- NA

      } else {
        comp_main <- cbind(tidy_fit %>% dplyr::filter(effect != "ran_pars"),#dplyr::slice_head(n = -1),
                           comp_main_parnames,
                           comp_main_pars)

        comp_prior_parnames <- as.data.frame(t(cbind(mod_int,
                                                    as.data.frame(strsplit(names(mod_infos[[j]]$prior$sim_args$fixed), " ")),
                                                    mod_prior))) %>%
          dplyr::rename(parnames = V1)

        comp_prior_pars <- dplyr::bind_rows(as.data.frame(mod_infos[[j]]$prior$sim_args$reg_weights) %>%
                                             dplyr::rename(parameter = `mod_infos[[j]]$prior$sim_args$reg_weights`),
                                           as.data.frame(mod_infos[[j]]$prior$prior) %>%
                                             dplyr::rename(parameter = `mod_infos[[j]]$prior$prior`))

        comp_prior <- cbind(tidy_fit %>% dplyr::filter(effect != "ran_pars"),#dplyr::slice_head(n = -1),
                           comp_prior_parnames,
                           comp_prior_pars)
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
        } else {
          res_prior <- res_main
          res_prior[!is.na(res_prior)] <- NA
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
