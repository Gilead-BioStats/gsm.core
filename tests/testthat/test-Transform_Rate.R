test_that("output is created as expected", {
  dfTransformed <- Transform_Rate(
    dfInput = analyticsInput
  ) %>% suppressWarnings()

  expect_true(is.data.frame(dfTransformed))
  expect_equal(
    names(dfTransformed),
    c("GroupID", "GroupLevel", "Numerator", "Denominator", "Metric")
  )
  expect_equal(
    sort(unique(analyticsInput$GroupID[which(analyticsInput$Denominator != 0)])),
    sort(dfTransformed$GroupID)
  )
  expect_equal(
    length(unique(analyticsInput$GroupID[which(analyticsInput$Denominator != 0)])),
    length(unique(dfTransformed$GroupID))
  )
  expect_equal(
    length(unique(analyticsInput$GroupID[which(analyticsInput$Denominator != 0)])),
    nrow(dfTransformed)
  )
})

# Count / Exposure

test_that("incorrect inputs throw errors", {
  expect_error(
    Transform_Rate(list()),
    "dfInput is not a data frame"
  )

  expect_error(
    Transform_Rate(
      dfInput = analyticsInput %>%
        dplyr::mutate(Numerator = as.character(Numerator))
    ),
    "strNumeratorColumn is not numeric"
  )

  expect_error(
    Transform_Rate(
      dfInput = analyticsInput %>%
        dplyr::mutate(Denominator = as.character(Denominator))
    ),
    "strDenominatorColumn is not numeric"
  )

  expect_error(
    Transform_Rate(
      dfInput = analyticsInput %>%
        dplyr::mutate(Numerator = ifelse(row_number() == 1, NA, Numerator))
    ),
    "NA's found in numerator"
  )

  expect_error(
    Transform_Rate(
      dfInput = analyticsInput %>%
        dplyr::mutate(Denominator = ifelse(row_number() == 1, NA, Denominator))
    ),
    "NA's found in denominator"
  )

  expect_error(
    Transform_Rate(
      dfInput = analyticsInput %>% dplyr::select(-"GroupID")
    ),
    "Required columns not found in input data"
  )
})

test_that("rows with a denominator of 0 are removed", {
  testInput <- analyticsInput %>%
    dplyr::group_by(GroupID) %>%
    dplyr::mutate(
      Denominator = ifelse(
        GroupID == analyticsInput$GroupID[[1]],
        0,
        Denominator
      ),
      Rate = ifelse(
        GroupID == analyticsInput$GroupID[[1]],
        NaN,
        Numerator / Denominator
      )
    ) %>%
    ungroup()
  expect_warning({
    row_removed <- Transform_Rate(
      dfInput = testInput
    )
  })
  expect_snapshot(row_removed)
})
