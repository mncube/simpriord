sim_lm_comp <- function(fit_obj){

  #Create local bindings for variables
  `1` <- NULL
  `2` <- NULL

  #Initialize list to store fit dfs
  all_main <- vector(mode = "list", length = length(fit_obj$fits))
  all_prior <- vector(mode = "list", length = length(fit_obj$info))

  #Get fits
  for (i in 1:length(fit_obj$fits)){

    #Collect model fits and info for each simulation
    mod_infos <- fit_obj$info[[i]]
    mod_fits <- fit_obj$fits[[i]]

    #Get simulation results for each simulation
    for (j in 1:length(mod_fits)){

      #Initialize list to store results
      res_main <- vector(mode = "list", length = length(mod_fits))
      res_prior <- vector(mode = "list", length = length(mod_fits))


      #Tidy model fit
      tidy_fit <- broom.mixed::tidy(mod_fits[[j]])

      #Get model alias as isolated data frame
      mod_name <- mod_infos[[j]] %>%
        dplyr::select(mod_name) %>%
        dplyr::slice_head(n = 1)

      #Connect model fit with model info
      if (nrow(mod_infos[[j]] == 1)){
        comp_main <- cbind(tidy_fit,
                           t(mod_infos[[j]][mod_infos[[j]]$prior == 0,]),
                           mod_name) %>%
          dplyr::rename(parameter = `1`) %>%
          dplyr::slice_head(n = -1)
        comp_prior <- NULL
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
    if (length(mod_fits) == 1){
      res_main[[j]] <- comp_main
      res_prior[[j]] <- comp_prior
    } else {
      res_main[[j]] <- rbind(res_main, comp_main)
      res_prior[[j]] <- rbind(res_prior, comp_prior)
    }
    }

    #Store across simulations
    all_main[[i]] <- res_main
    all_prior[[i]] <- res_prior
  }

  #Collect output in list
  ouput <- list("main" = all_main,
                "prior" = all_prior)
  }

