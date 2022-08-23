#' Run brm Linear Models on List of Data Frames
#'
#' @param df_list a list of data frames built from sim_lm_dfs
#' @param ... pass parameters to brm function
#'
#' @return a list of of objects containing brm model fits and model generating information
#'
#' @importFrom stats reformulate
#'
#' @export
#'
#' @examples
#' linear_mod_dfs <- sim_lm_dfs()
#' linear_mod_fits <- sim_lm_run(df_list = list(linear_mod_dfs), iter = 3)
sim_lm_run <- function(df_list, ...){
  #Bind local vaiables to function
  ID <- NULL

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
      df <- subset(df_mods$df_mod[[j]], !is.na(row.names(df_mods$df_mod[[j]])), select = -c(ID))

      #Create formula from df
      model <- reformulate(".", response = sprintf("`%s`", names(df)[1]))

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

