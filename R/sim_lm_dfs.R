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
                           frames = 2) {
  #Initialize list to store dfs
  all_dfs <- vector(mode = "list", length = frames)

  #Loop through and make dfs based on function parameters
  for (i in 1:frames){

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
                 prior = 0)

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
                             prior = 1)

      #Combine main and prior data into one df
      df <- rbind(df, df_prior)
    }

    #Collect dfs in a list
    all_dfs[[i]] <- df
  }

  #Return dfs
  return(all_dfs)
  }
