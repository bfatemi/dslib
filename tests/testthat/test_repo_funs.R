library(testthat)

test_that("Testing dsr_* functions", {
  expect_gt(nrow(dsr_list()), 1)
  expect_true(dsr_pkg_exists("data.table"))
  expect_false(dsr_pkg_exists("blahblah"))
  expect_equal(dsr_get_version("data.table")[, unique(Package)], "data.table")
  expect_null(dsr_get_version("blahblah"))
})


test_that("Testing cran_* functions", {
  expect_gt(nrow(cran_list()), 1)
  expect_true(cran_pkg_exists("data.table"))
  expect_false(cran_pkg_exists("blahblah"))
  expect_equal(cran_get_version("data.table")[, unique(Package)], "data.table")
  expect_null(cran_get_version("blahblah"))
})


