# Run a set of tests to check that function throws error when inputs mismatch
test_that("sim_ln throws error if length(bj) does not match with length(distj)
and length(paramsj)", {
  expect_error(sim_lm(bj=list(b1 = 1)))
})

test_that("sim_ln throws error if length(bj) and length(distj) do not match with
length(paramsj)", {
  expect_error(sim_lm(bj=list(b1 = 1),
                      distj = list(rnorm)))
})

