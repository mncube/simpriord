## First Submission

This is the first submission of simpriord to cran.

## R CMD check results

── R CMD check results ──────────────────────────────────── simpriord 1.0.0 ────
Duration: 35m 27.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


## Package uses brms rstan backend

simpriord uses brms with the default rstan backend.  To get brms and simpriord
working with R 4.2 and Rtools 4.2, users may need to use the preview of the
next rstan version since the current version of rstan which is on CRAN seems
to have compatability issues.  The issue is described further here:
https://discourse.mc-stan.org/t/error-when-running-brm-model/27951
