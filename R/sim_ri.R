#sim_lm <- function(n = 25,
#                   b0=list(b0 = 0),
#                   bj=list(b1 = 1, b2 = 1),
#                   distj = list(rnorm, rnorm),
#                   paramsj = list(c(0, 0), c(1,1)),
#                   transj = list(`^`, `^`),
#                   transrhs = list(1,1),
#                   intj = NULL,
#                   diste = rnorm,
#                   paramse = c(0, 1),
#                   gk = list(g1 = 1:n),
#                   repk = list(reps1 = 10),
#                   distk = list(rnorm),
#                   paramsk = list(c(0,1)),
#                   prior = 0,
#                   mod_name = "mod"){
#  #Bind local vaiables to function
#  Y <- NULL
#  `df_mod$prior` <- NULL
#  `.` <- NULL
#
#  #Get helper function for building distributions
#  #Source: https://stackoverflow.com/questions/56691580/how-to-make-probability-distribution-an-argument-of-a-function-in-r
#  f <- function(k,g,...){g(k,...)}
#
#  #Check inputs for mistmatched lengths
#  l_bj <- length(bj)
#  l_distj <- length(distj)
#  l_paramsj <- length(paramsj)
#
#
#  if (l_bj != l_distj){
#    stop("bj and distj must be the same length", call. = TRUE)
#  }
#
#  if (l_bj != l_paramsj){
#    stop("bj and paramsj must be the same length", call. = TRUE)
#  }
#
#  if (l_distj != l_paramsj){
#    stop("distj and paramsj must be the same length", call. = TRUE)
#  }
#
#  #Turn coefficients and IDs into dfs
#  b0 <- data.frame(b0)
#  bj <- data.frame(bj)
#  ID <- data.frame(ID = 1:n)
#  mod_name <- data.frame(mod_name = mod_name)
#
#  #Initialize data df
#  xj <- data.frame(matrix(vector(), n, length(bj)))
#
#  #Build data df from distribution and parameter
#  for (i in seq_along(bj)){
#    xj[[i]] <- f(n, distj[[i]], paramsj[[i]])
#
#    #Transform variables
#    if (is.null(transrhs[[i]])){
#      xj[[i]] <- do.call(transj[[i]], list(xj[[i]]))
#    } else {
#      xj[[i]] <- do.call(transj[[i]], list(xj[[i]], transrhs[[i]]))
#    }
#  }
#
#  #Build data df to help construct interactions
#  if (!is.null(intj)){
#    length_int <- length(intj)
#    intj <- data.frame(intj)
#  }
#
#  #Build error vector data frame
#  eps <- data.frame(eps = f(n, diste, paramse))
#
#  #Build random effects data frame
#  rk <- data.frame(matrix(vector(), max(gk[[1]])*repk[[1]], length(gk)))
#
#  #Combine dfs into one df
#  if (is.null(intj)){
#    df_mod <- cbind(ID, b0, bj, xj, eps)
#  } else {
#    df_mod <- cbind(ID, b0, bj, xj, intj, eps)
#  }
#
#  #Initialize dependent variable column of df
#  df_mod$Y <- NA
#
#  #Generate outcomes using loop
#  for (i in 1:n){
#    if (is.null(intj)){
#      df_mod$Y[[i]] <- df_mod$b0[[i]] +
#        sum(df_mod[i,paste0("b", 1:length(bj))] *
#              df_mod[i,paste0("X", 1:length(xj))]) +
#        df_mod$eps[[i]]
#    } else {
#      df_mod$Y[[i]] <- df_mod$b0[[i]] +
#        sum(df_mod[i,paste0("b", 1:length(bj))] *
#              df_mod[i,paste0("X", 1:length(xj))]) +
#        sum(df_mod[i,paste0("int", 1:length_int, ".coef")]*
#              df_mod[i,df_mod[,paste0("int", 1:length_int, ".v1")][[i]]]*
#              df_mod[i,df_mod[,paste0("int", 1:length_int, ".v2")][[i]]]) +
#        df_mod$eps[[i]]
#    }
#  }
#
#  #Select ID, dependent variable, and independent variables
#  if (is.null(intj)){
#    df_mod <- df_mod %>% dplyr::select(ID, Y, tidyselect::starts_with("X")) %>%
#      dplyr::mutate(prior = prior)
#  } else {
#    for (i in 1:length_int){
#      #Create 1 row data frame with the two interaction vars
#      temp_int <- df_mod %>% dplyr::select(tidyselect::starts_with(paste0("int", i, ".v"))) %>%
#        utils::head(., 1)
#
#      #Extrace names of both vars and get their cat
#      temp1 <- temp_int[[1]]
#      temp2 <- temp_int[[2]]
#      tempx <- paste0(temp1, temp2)
#
#      #Initialize new col for interaction value
#      df_mod$new <- NA
#
#      #Update name of new variable
#      colnames(df_mod)[which(names(df_mod) == "new")] <- tempx
#
#      #Fill in interaction values
#      for (j in 1:nrow(df_mod)){
#        df_mod[j, tempx] <- df_mod[j, temp1]*df_mod[j,temp2]
#      }
#    }
#    df_mod <- df_mod %>% dplyr::select(ID, Y, tidyselect::starts_with("X"),
#                                       tidyselect::starts_with("X")) %>%
#      dplyr::mutate(prior = prior)
#  }
#
#  #Collect model and parameter information
#  if (is.null(intj)){
#    df_info <- cbind(b0, bj, df_mod$prior, mod_name) %>%
#      dplyr::rename(prior = `df_mod$prior`) %>%
#      dplyr::distinct()
#  } else {
#    df_info <- cbind(b0, bj, intj, df_mod$prior, mod_name) %>%
#      dplyr::select(-tidyselect::contains(".v")) %>%
#      dplyr::rename(prior = `df_mod$prior`) %>%
#      dplyr::distinct()
#  }
#
#
#
#  #Collect output
#  Output <- list("df_mod" = df_mod,
#                 "df_info" = df_info)
#
#  #Return df
#  return(Output)
#}
