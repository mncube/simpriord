#' Run brm Linear Models on List of Data Frames
#'
#' @param df_list a list of data frames built from sim_lm_dfs
#' @param ... pass parameters to brm function
#'
#' @return a list of of objects containing brm model fits and model names
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
  mod_name <- NULL

  #Initialize list to collect model fits
  all_fits <- vector(mode = "list", length = length(df_list))
  mod_names <- vector(mode = "list", length = length(df_list))

  for (i in 1:length(df_list)){

    #Get first list of models
    df_mods <- df_list[[i]]

    #Initialize list to collect model fits
    fits <- vector(mode = "list", length = length(df_mods))
    names <- vector(mode = "list", length = length(df_mods))

    for(j in 1:length(df_mods)){
      #Get modelname
      mni <- unlist(subset(df_mods[[j]], row.names(df_mods[[j]]) == 1, select = c(mod_name)))

      #Prepare this iterations data frame from df_list
      df <- subset(df_mods[[j]], !is.na(row.names(df_mods[[j]])), select = -c(ID, mod_name))

      #Create formula from df
      model <- stats::reformulate(".", response = sprintf("`%s`", names(df)[1]))
      #model <- stats::as.formula("Y ~ .")
      #n <- names(df)
      #model <- stats::as.formula(base::paste("Y ~", base::paste(n[!n %in% "Y"], collapse = " + ")))

      #Run brm model on df
      fit <- brms::brm(formula = model,
                       data = df,
                       ...)

      #Collect model fits in list
      fits[[j]] <- fit
      names[[j]] <- mni

    }

    #Collect model fits in list
    all_fits[[i]] <- fits
    mod_names[[i]] <- names

  }

  #Collect output
  output <- list("fits" = all_fits,
                 "mod_names" = mod_names)

  #Return list of fits
  return(output)
}

