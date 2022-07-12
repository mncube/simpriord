#' Simulate from a Linear Model
#'
#' @param n number of units
#' @param each number of observation per unit
#' @param b0 intercept
#' @param bj a list of coefficients
#' @param distj a list of distributions matching bj by position
#' @param paramsj a list of parameter vectors matching distj by position
#' @param m_error mean of error terms
#' @param v_error variance of error terms
#' @param prior indicates whether df will serve as main data (0) or prior data (1)
#'
#' @return a data set with an ID for each unit, Y as the dependent variable and X1:Xj
#' independent variables
#'
#' @importFrom stats rnorm
#'
#' @export
#'
#' @examples
#' main_lm_data <- sim_lm()
sim_lm <- function(n = 25,
                   each = 1,
                   b0=list(b0 = 0),
                   bj=list(b1 = 0, b2 = 0),
                   distj = list(rnorm, rnorm),
                   paramsj = list(c(0, 0), c(1,1)),
                   m_error = 0,
                   v_error = 1,
                   prior = 0){
  #Bind local vaiables to function
  Y <- NULL

  #Get helper function for building distributions
  #Source: https://stackoverflow.com/questions/56691580/how-to-make-probability-distribution-an-argument-of-a-function-in-r
  f <- function(k,g,...){g(k,...)}

  #Turn coefficients and IDs into dfs
  b0 <- data.frame(b0)
  bj <- data.frame(bj)
  ID <- data.frame(ID = 1:n)

  #Initialize data df
  xj <- data.frame(matrix(vector(), n, length(bj)))

  #Build data df from distribution and parameter
  for (i in seq_along(bj)){
    xj[[i]] <- rep(f(n, distj[[i]], paramsj[[i]]), each)

  }

  #Build error vector data frame
  eps <- data.frame(eps = rep(stats::rnorm(n, m_error, sqrt(v_error)), each))

  #Combine dfs into one df
  df_mod <- cbind(ID, b0, bj, xj, eps)

  #Initialize dependent variable column of df
  df_mod$Y <- NA

  #Generate outcomes using loop
  for (i in 1:n){
    df_mod$Y[[i]] <- df_mod$b0[[i]] +
      sum(df_mod[i,paste0("b", 1:length(bj))] *
            df_mod[i,paste0("X", 1:length(xj))]) +
      df_mod$eps[[i]]
  }

  #Select ID, dependent variable, and independent variables
  df_mod <- df_mod %>% dplyr::select(ID, Y, tidyselect::starts_with("X")) %>%
    dplyr::mutate(prior = prior)

  #Return df
  return(df_mod)
  }
