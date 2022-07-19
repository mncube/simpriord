#' Simulate Datasets from a Linear Model
#'
#' @param n_m number of units (main data)
#' @param b0_m intercept (main data)
#' @param bj_m a list of coefficients (main data)
#' @param distj_m a list of distributions matching bj_m by position (main data)
#' @param paramsj_m a list of parameter vectors matching distj_m by position (main data)
#' @param transj_m a list of transformations (infix transformations must specify transrhs_m) (main data)
#' @param transrhs_m a list of right-hand-sides for transj_m (set to NULL if transj_m has no rhs) (main data)
#' @param intj_m a nested list specifying an interaction between two variable.
#' The list should take the form list(int1 = list(coef = 1, v1 = "X1", v2 = "X2")) (main data)
#' @param diste_m distribution for error term (main data)
#' @param paramse_m parameters for the error terms distribution (main data)
#' @param n_p number of units (previous data)
#' @param b0_p intercept (previous data)
#' @param bj_p a list of coefficients (previous data)
#' @param distj_p a list of distributions matching bj_p by position (previous data)
#' @param paramsj_p a list of parameter vectors matching distj_p by position (previous data)
#' @param transj_p a list of transformations (infix transformations must specify transrhs_p) (previous data)
#' @param transrhs_p a list of right-hand-sides for transj_p (set to NULL if transj_p has no rhs) (previous data)
#' @param intj_p a nested list specifying an interaction between two variable.
#' The list should take the form list(int1 = list(coef = 1, v1 = "X1", v2 = "X2")) (previous data)
#' @param diste_p distribution for error term (previous data)
#' @param paramse_p parameters for the error terms distribution (previous data)
#' @param with_prior if with_prior = 1, generate data frames that contain main and previous data
#' @param frames The number of data frame to generate
#' @param mod_name A list (with length equal to frames) of model aliases
#'
#' @return A nested list of data frames (see sim_lm for more information)
#' @export
#'
#' @examples
#' five_frames <- sim_lm_dfs()
sim_lm_dfs <- function(n_m = 25,
                           b0_m=list(b0 = 0),
                           bj_m=list(b1 = 1, b2 = 1),
                           distj_m = list(rnorm, rnorm),
                           paramsj_m = list(c(0, 0), c(1,1)),
                           transj_m = list(`^`, `^`),
                           transrhs_m = list(1,1),
                           intj_m = NULL,
                           diste_m = rnorm,
                           paramse_m = c(0, 1),
                           n_p = 25,
                           b0_p=list(b0 = 0),
                           bj_p=list(b1 = 1, b2 = 1),
                           distj_p = list(rnorm, rnorm),
                           paramsj_p = list(c(0, 0), c(1,1)),
                           transj_p = list(`^`, `^`),
                           transrhs_p = list(1,1),
                           intj_p = NULL,
                           diste_p = rnorm,
                           paramse_p = c(0, 1),
                           with_prior = 1,
                           frames = 2,
                           mod_name = list("mod1", "mod2")) {
  #Initialize lists to store dfs
  all_df_mod <- vector(mode = "list", length = frames)
  all_df_info <- vector(mode = "list", length = frames)

  #Loop through and make dfs based on function parameters
  for (i in 1:frames){

    #Get mod name
    mni <- mod_name[[i]]

    #Get each df for main data
    df <- sim_lm(n = n_m,
                 b0=b0_m,
                 bj=bj_m,
                 distj = distj_m,
                 paramsj = paramsj_m,
                 transj = transj_m,
                 transrhs = transrhs_m,
                 intj = intj_m,
                 diste = diste_m,
                 paramse = paramse_m,
                 prior = 0,
                 mod_name = mni)

    #If prior data is included, get each df for prior data
    if (with_prior == 1){
      df_prior <- sim_lm(n = n_p,
                             b0=b0_p,
                             bj=bj_p,
                             distj = distj_p,
                             paramsj = paramsj_p,
                             transj = transj_p,
                             transrhs = transrhs_p,
                             intj = intj_p,
                             diste = diste_p,
                             paramse = paramse_p,
                             prior = 1,
                             mod_name = mni)

      #Combine main and prior data into one df
      df_mod <- rbind(df$df_mod, df_prior$df_mod)
      df_info <- rbind(df$df_info, df_prior$df_info) %>%
        dplyr::distinct()
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
