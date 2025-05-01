test_that("Analyze_NormalApprox_PredictBounds handles missing nStep correctly", {
  expect_warning(
    {dfTransformed <- Transform_Rate(analyticsInput)},
    "value of 0 removed"
  )
  expect_message(
    {
      dfBounds <- Analyze_NormalApprox_PredictBounds(dfTransformed)
    },
    regexp = "Setting default step"
  )
})

test_that("Analyze_NormalApprox_PredictBounds handles missing nStep for weird range", {
  expect_warning(
    {dfTransformed <- Transform_Rate(analyticsInput)},
    "value of 0 removed"
  )
  dfTransformed <- dfTransformed %>%
    dplyr::mutate(
      Denominator = .data$Denominator[[1]],
      Numerator = round(.data$Metric * .data$Denominator)
    )
  expect_message(
    {
      dfBounds <- Analyze_NormalApprox_PredictBounds(dfTransformed)
    },
    regexp = "step to 1\\.[^0-9]*"
  )
})

test_that("Analyze_NormalApprox_PredictBounds handles missing vThreshold correctly", {
  expect_warning(
    {dfTransformed <- Transform_Rate(analyticsInput)},
    "value of 0 removed"
  )

  expect_message(
    {
      dfBounds <- quiet_Analyze_NormalApprox_PredictBounds(
        dfTransformed,
        vThreshold = NULL,
      )
    },
    "vThreshold was not provided"
  )

  expect_equal(sort(unique(dfBounds$Threshold)), sort(c(-3, -2, 0, 2, 3)))
})

test_that("Analyze_NormalApprox_PredictBounds processes data correctly", {
  expect_warning(
    {dfTransformed <- Transform_Rate(analyticsInput)},
    "value of 0 removed"
  )

  dfBounds <- quiet_Analyze_NormalApprox_PredictBounds(dfTransformed)

  expect_true(all(c("Threshold", "LogDenominator", "Denominator", "Numerator") %in% names(dfBounds)))
  expect_equal(dfBounds$Threshold[1], -3)
})

test_that("Analyze_NormalApprox_PredictBounds handles edge cases for vThreshold", {
  expect_warning(
    {dfTransformed <- Transform_Rate(analyticsInput)},
    "value of 0 removed"
  )

  dfBounds <- quiet_Analyze_NormalApprox_PredictBounds(
    dfTransformed,
    vThreshold = c(0)
  )

  expect_equal(unique(dfBounds$Threshold), 0)
})
