## First Submission

This is the first submission of simpriord to cran.

## R CMD check results

── R CMD check results ──────────────────────────────────── simpriord 1.0.0 ────
Duration: 41m 55s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

## devtools::check_rhub() results

There were two errors:

* checking examples ... [36s] ERROR
* checking tests ...Running 'testthat.R' [130s] [130s] ERROR

I believe that the errors are due to a known compatability issue with the 
version of rstan on cran when running R 4.2 and rtools 4.2 (https://discourse.mc-stan.org/t/error-when-running-brm-model/27951).  On my
own computer I have to use development versions of rstan to get brms to work
on R 4.2 with rtools 4.2.
