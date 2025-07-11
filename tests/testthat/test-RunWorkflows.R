test_wfs <- MakeWorkflowList(strPath = "testdata/misc")

test_that("Basic flow works", {
  logger <- logger("ERROR", appenders = console_appender(layout = cli_fmt))
  SetLogger(logger)
  expect_snapshot(RunWorkflows(test_wfs, lData = list(iris = iris)))
})

logger <- logger("DEBUG", appenders = console_appender(layout = cli_fmt))
SetLogger(logger)
