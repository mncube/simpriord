#' sim_sglm_dfs
#'
#' Simulate main and previous datasets using simglm's sim_args parameter
#'
#' @references
#' LeBeau B (2022). _simglm: Simulate Models Based on the Generalized Linear
#' Model_. R package version 0.8.9, <https://CRAN.R-project.org/package=simglm>.
#'
#' @param data_m this parameter was taken from simglm:
#' https://github.com/lebebr01/simglm/blob/main/R/fixef_sim.r
#' "Data simulated from other functions to pass to this function.
#' Can pass NULL if first in simulation string." (main data)
#' @param sim_args_m Define model using simglm's sim_args parameter (main data)
#' @param data_p "Data simulated from other functions to pass to this function.
#' Can pass NULL if first in simulation string." (previous data)
#' @param sim_args_p Define model using simglm's sim_args parameter (previous data)
#' @param with_prior if with_prior = 1, generate data frames that contain main and previous data
#' @param frames The number of data frames to generate
#' @param mod_name A list of model aliases
#' @param ... Other arguments to pass to simglm's simulate_fixed,
#' simulate_randomeffect, simulate_error, or generate_response
#'
#' @return A nested list of data frames (see sim_sglm for more information)
#' @export
sim_sglm_dfs <- function(data_m = NULL,
                         sim_args_m,
                         data_p = NULL,
                         sim_args_p,
                         with_prior = 1,
                         frames = 2,
                         mod_name = list("mod1"),
                         ...) {
  #Initialize lists to store dfs
  all_df_mod <- vector(mode = "list", length = frames)
  all_df_info <- vector(mode = "list", length = frames)

  #Loop through and make dfs based on function parameters
  for (i in 1:frames){

    #Get mod name
    if (length(mod_name) == 1){
      mni <- unlist(mod_name)
    } else {
      mni <- mod_name[[i]]
    }

    #Get each df for main data
    df <- sim_sglm(data = data_m,
                   sim_args_m,
                   prior = 0,
                   mod_name = mni,
                   ...)

    #If prior data is included, get each df for prior data
    if (with_prior == 1){
      df_prior <- sim_sglm(data = data_p,
                         sim_args_p,
                         prior = 1,
                         mod_name = mni,
                         ...)

      #Combine main and prior data into one df
      df_mod <- rbind(df$df_mod, df_prior$df_mod)
      df_info <- list("main" = df$df_info, "prior" = df_prior$df_info)
    } else {
      #Get main data as df_mod
      df_mod <- df$df_mod
      df_info <- df$df_info
    }

    #Collect dfs in lists
    all_df_mod[[i]] <- df_mod
    all_df_info[[i]] <- df_info
  }

  #Collect output
  Output <- list("df_mod" = all_df_mod,
                 "df_info" = all_df_info)

  #Return dfs
  return(Output)
}
