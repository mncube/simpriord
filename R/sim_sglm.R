#' sim_sglm
#'
#' Simulate data using simglm's sim_args parameter
#'
#' @references
#' LeBeau B (2022). _simglm: Simulate Models Based on the Generalized Linear
#' Model_. R package version 0.8.9, <https://CRAN.R-project.org/package=simglm>.
#'
#' @param data this parameter was taken from simglm:
#' https://github.com/lebebr01/simglm/blob/main/R/fixef_sim.r
#' "Data simulated from other functions to pass to this function.
#' Can pass NULL if first in simulation string."
#' @param sim_args Define model using simglm's sim_args parameter
#' @param prior indicates whether df will serve as main data (0) or
#' prior data (1)
#' @param mod_name model alias
#' @param ... Other arguments to pass to simglm's simulate_fixed,
#' simulate_randomeffect, simulate_error, or generate_response
#'
#' @return A list with the dataframe produced by the model specification
#' (as an object named df_mod) and the model specification information
#' (as an object named df_infor)
#' @export
sim_sglm <- function(data = NULL,
                     sim_args,
                     prior = 0,
                     mod_name = "mod",
                     ...){
  #Try to simulate data with random effects (in try block)
  #or without (if try-error)
  df_mod <- try(simglm::simulate_fixed(data = NULL, sim_args) %>%
                  simglm::simulate_randomeffect(sim_args) %>%
                  simglm::simulate_error(sim_args) %>%
                  simglm::generate_response(sim_args),
                silent = TRUE)

  if(inherits(df_mod, "try-error")){
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
