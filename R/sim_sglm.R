sim_sglm <- function(data = NULL,
                     sim_args,
                     prior = 0,
                     mod_name = "mod",
                     ...){
  #Try to simulate data with random effects (in try block) or without (if try-error)
  df_mod <- try(simglm::simulate_fixed(data = NULL, sim_args) %>%
                  simglm::simulate_randomeffect(sim_args) %>%
                  simglm::simulate_error(sim_args) %>%
                  simglm::generate_response(sim_args),
                silent = TRUE)

  if(class (df_mod) == "try-error"){
    df_mod <- simglm::simulate_fixed(data = NULL, sim_args) %>%
      simglm::simulate_error(sim_args) %>%
      simglm::generate_response(sim_args)
  }

  #Add prior indicator
  df_mod <- df_mod %>%
    dplyr::mutate(prior = prior)

  #Collect model info
  df_info <- list("sim_args" = sim_args,
                  "prior" = prior,
                  "mod_name" = mod_name)

  #Collect output
  Output <- list("df_mod" = df_mod,
                 "df_info" = df_info)

  #Return df
  return(Output)
}
