#' Run brm Linear Models on List of Data Frames
#'
#' @param df_list a list of data frames built from sim_lm_dfs
#' @param ... pass parameters to brm function
#'
#' @return a list of brm model fits
#'
#' @importFrom stats reformulate
#'
#' @export
#'
#' @examples
#' linear_mod_dfs <- sim_lm_dfs()
#' linear_mod_fits <- sim_lm_run(df_list = linear_mod_dfs, iter = 3)
sim_lm_run <- function(df_list, ...){
  #Bind local vaiables to function
  ID <- NULL

  #Initialize list to collect model fits
  all_fits <- vector(mode = "list", length = length(df_list))

  for (i in 1:length(df_list)){
    #Prepare this iterations data frame from df_list
    df <- subset(df_list[[i]], select = -c(ID))

    #Create formula from df
    model <- reformulate(".", response = sprintf("`%s`", names(df)[1]))

    #Run brm model on df
    fit <- brms::brm(formula = model,
               data = df,
               ...)

    #Collect model fits in list
    all_fits[[i]] <- fit
  }

  #Return list of fits
  return(all_fits)
}

