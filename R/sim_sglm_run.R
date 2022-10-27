#' sim_sglm_run
#'
#' Run brm models on list of data frames built with sim_sglm_dfs
#'
#' @references
#' Paul-Christian Bürkner (2017). brms: An R Package for Bayesian Multilevel
#' Models Using Stan. Journal of Statistical Software, 80(1), 1-28.
#' doi:10.18637/jss.v080.i01
#'
#' @param df_list a list of data frames built from sim_sglm_dfs
#' @param ... pass parameters to brm function
#'
#' @return a list of of objects containing brm model fits and model generating information
#'
#' @importFrom stats reformulate update
#'
#' @export
sim_sglm_run <- function(df_list, ...){
  #Initialize list to collect model fits
  all_fits <- vector(mode = "list", length = length(df_list))
  all_info <- vector(mode = "list", length = length(df_list))

  for (i in 1:length(df_list)){

    #Get first list of models
    df_mods <- df_list[[i]]


    #Initialize list to collect model fits
    fits <- vector(mode = "list", length = length(df_mods$df_mod))
    info <- vector(mode = "list", length = length(df_mods$df_info))

    for(j in 1:length(df_mods$df_mod)){

      inform <- df_mods$df_info[[j]]

      #Prepare this iterations data frame from df_list
      df <- df_mods$df_mod[[j]]

      if (sum(df_mods$df_mod[[j]]$prior == 1) == 0){

        #Create formula from df
        #model <- update(inform$main$sim_args$formula, reformulate(c(".")))
        model <- inform$sim_args$formula


      } else {

        #Create formula from df
        model <- update(inform$main$sim_args$formula, reformulate(c(".", "prior")))

      }

      #Run brm model on df
      fit <- brms::brm(formula = model,
                       data = df,
                       ...)

      #Collect model fits in list
      fits[[j]] <- fit
      info[[j]] <- inform

    }

    #Collect model fits in list
    all_fits[[i]] <- fits
    all_info[[i]] <- info

  }

  #Collect output
  output <- list("fits" = all_fits,
                 "info" = all_info)

  #Return list of fits
  return(output)
}
