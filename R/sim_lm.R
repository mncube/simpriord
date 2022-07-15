#' Simulate from a Linear Model
#'
#' @param n number of units
#' @param b0 intercept
#' @param bj a list of coefficients
#' @param distj a list of distributions matching bj by position
#' @param paramsj a list of parameter vectors matching distj by position
#' @param transj a list of transformations (infix transformations must specify transrhs)
#' @param transrhs a list of right-hand-sides for transj (set to NULL if transj has no rhs)
#' @param intj a nested list specifying an interaction between two variable.
#' The list should take the form list(int1 = list(coef = 1, v1 = "X1", v2 = "X2"))
#' to specify an interaction between X1 and X2 with a regression coefficient of 1.
#' @param diste distribution for error term
#' @param paramse parameters for the error terms distribution
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
#' #Build df using default parameters
#' main_lm_data <- sim_lm()
#'
#' #Build df with an interaction
#' main_lm_data_in <- sim_lm(intj = list(int1 = list(coef = 5, v1 = "X1", v2 = "X2")))
sim_lm <- function(n = 25,
                   b0=list(b0 = 0),
                   bj=list(b1 = 1, b2 = 1),
                   distj = list(rnorm, rnorm),
                   paramsj = list(c(0, 0), c(1,1)),
                   transj = list(`^`, `^`),
                   transrhs = list(1,1),
                   intj = NULL,
                   diste = rnorm,
                   paramse = c(0, 1),
                   prior = 0){
  #Bind local vaiables to function
  Y <- NULL

  #Get helper function for building distributions
  #Source: https://stackoverflow.com/questions/56691580/how-to-make-probability-distribution-an-argument-of-a-function-in-r
  f <- function(k,g,...){g(k,...)}

  #Check inputs for mistmatched lengths
  l_bj <- length(bj)
  l_distj <- length(distj)
  l_paramsj <- length(paramsj)

  if (l_bj != l_distj){
    stop("bj and distj must be the same length", call. = TRUE)
  }

  if (l_bj != l_paramsj){
    stop("bj and paramsj must be the same length", call. = TRUE)
  }

  if (l_distj != l_paramsj){
    stop("distj and paramsj must be the same length", call. = TRUE)
  }

  #Turn coefficients and IDs into dfs
  b0 <- data.frame(b0)
  bj <- data.frame(bj)
  ID <- data.frame(ID = 1:n)

  #Initialize data df
  xj <- data.frame(matrix(vector(), n, length(bj)))

  #Build data df from distribution and parameter
  for (i in seq_along(bj)){
    xj[[i]] <- f(n, distj[[i]], paramsj[[i]])

    #Transform variables
    if (is.null(transrhs[[i]])){
      xj[[i]] <- do.call(transj[[i]], list(xj[[i]]))
    } else {
      xj[[i]] <- do.call(transj[[i]], list(xj[[i]], transrhs[[i]]))
    }
  }

  #Build data df to help construct interactions
  if (!is.null(intj)){
    length_int <- length(intj)
    intj <- data.frame(intj)
  }

  #Build error vector data frame
  eps <- data.frame(eps = f(n, diste, paramse))

  #Combine dfs into one df
  if (is.null(intj)){
    df_mod <- cbind(ID, b0, bj, xj, eps)
  } else {
    df_mod <- cbind(ID, b0, bj, xj, intj, eps)
  }

  #Initialize dependent variable column of df
  df_mod$Y <- NA

  #Generate outcomes using loop
  for (i in 1:n){
    if (is.null(intj)){
      df_mod$Y[[i]] <- df_mod$b0[[i]] +
        sum(df_mod[i,paste0("b", 1:length(bj))] *
              df_mod[i,paste0("X", 1:length(xj))]) +
        df_mod$eps[[i]]
    } else {
      df_mod$Y[[i]] <- df_mod$b0[[i]] +
        sum(df_mod[i,paste0("b", 1:length(bj))] *
              df_mod[i,paste0("X", 1:length(xj))]) +
        sum(df_mod[i,paste0("int", 1:length_int, ".coef")]*
              df_mod[i,df_mod[,paste0("int", 1:length_int, ".v1")][[i]]]*
              df_mod[i,df_mod[,paste0("int", 1:length_int, ".v2")][[i]]]) +
        df_mod$eps[[i]]
    }
  }

  #Select ID, dependent variable, and independent variables
  df_mod <- df_mod %>% dplyr::select(ID, Y, tidyselect::starts_with("X")) %>%
    dplyr::mutate(prior = prior)

  #Return df
  return(df_mod)
  }
