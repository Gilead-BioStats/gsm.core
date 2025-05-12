suppressPackageStartupMessages(suppressWarnings(library(tcltk)))

quiet_RunWorkflows <- function(...) {
  suppressMessages({
    RunWorkflows(...)
  })
}

quiet_RunWorkflow <- function(...) {
  suppressMessages({
    RunWorkflow(...)
  })
}

quiet_Analyze_NormalApprox <- function(...) {
  suppressMessages({
    Analyze_NormalApprox(...)
  })
}

quiet_Analyze_NormalApprox_PredictBounds <- function(...) {
  suppressMessages({
    Analyze_NormalApprox_PredictBounds(...)
  })
}
