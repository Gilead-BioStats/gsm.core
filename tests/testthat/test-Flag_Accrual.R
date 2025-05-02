test_that("Function correctly applies accrual threshold", {
  dfFlagged <- data.frame(
    GroupID = c(1:7),
    Score = c(-3.5, -2.5, -1.5, 0, 1.5, 2.5, 3.5),
    Denominator = c(10, 20, 5, 30, 15, 8, 25),
    Numerator = c(5, 15, 2, 25, 10, 4, 20),
    Flag = c(-2, -1, 0, 0, 0, 1, 2)
  )

  result_d <- Flag_Accrual(dfFlagged, nAccrualThreshold = 10, strAccrualMetric = "Denominator")
  expect_true(all(is.na(result_d$Flag[which(result_d$Denominator < 10)])))

  result_n <- Flag_Accrual(dfFlagged, nAccrualThreshold = 5, strAccrualMetric = "Numerator")
  expect_true(all(is.na(result_n$Flag[which(result_n$Numerator < 5)])))

  result_diff <- Flag_Accrual(dfFlagged, nAccrualThreshold = 4, strAccrualMetric = "Difference")
  expect_true(all(is.na(result_diff$Flag[which((result_diff$Denominator - result_diff$Numerator) < 4)])))
})
