#' Check if the data and spec are compatible
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' Check if the data and spec are compatible by comparing the data.frames and
#' columns in the spec with the data.
#'
#' @param lData A list of data.frames.
#' @param lSpec A list specifying the expected structure of the data.
#'
#' @return This function does not return any value. It either prints a message indicating
#' that all data.frames and columns in the spec are present in the data, or throws an error
#' if any data.frame or column is missing.
#'
#' @examples
#' lData <- list(
#'   reporting_bounds = gsm.core::reportingBounds,
#'   reporting_results = gsm.core::reportingResults
#' )
#' lSpec <- list(
#'   reporting_bounds = list(
#'     Metric = list(type = "numeric"),
#'     Numerator = list(type = "numeric"),
#'     LogDenominator = list(type = "numeric"),
#'     MetricID = list(type = "character")
#'   ),
#'   reporting_results = list(
#'     GroupID = list(type = "character"),
#'     GroupLevel = list(type = "character"),
#'     Numerator = list(type = "integer"),
#'     Denominator = list(type = "integer")
#'   )
#' )
#' CheckSpec(lData, lSpec) # Prints message that everything is found
#'
#' \dontrun{
#' lSpec$reporting_groups$NotACol <- list(type = "character")
#' CheckSpec(lData, lSpec) # Throws error that NotACol is missing
#' }
#' @export
#'
CheckSpec <- function(lData, lSpec) {
  # Check that all data.frames in the spec are present in the data
  lSpecDataFrames <- names(lSpec)
  lDataFrames <- names(lData)
  if (!all(lSpecDataFrames %in% lDataFrames)) {
    MissingSpecDataFrames <- lSpecDataFrames[!lSpecDataFrames %in% lDataFrames]
    LogMessage(
      level = "error",
      message = "`lData` must contain all data.frames in `lSpec`. Missing data.frames: {MissingSpecDataFrames}"
    )
  } else {
    LogMessage(
      level = "info",
      message = "All {length(lSpecDataFrames)} data.frame(s) in the spec are present in the data: {glue::glue_collapse(lSpecDataFrames, sep = ', ')}",
      cli_detail = "alert"
    )
  }

  # Check that all required columns in the spec are present in the data
  allCols <- c()
  missingCols <- c()
  # remove all lSpec entries where we are requesting `_all` columns, and no other columns are included in the df's spec
  lSpecDataFrames <- which(sapply(lSpec, function(x) (names(x)[1] != "_all") | (length(names(x)) > 1))) %>% names()
  for (strDataFrame in lSpecDataFrames) {
    chrDataFrameColnames <- colnames(lData[[strDataFrame]])
    # check classes in data
    wrongType <- purrr::reduce2(
      lSpec[[strDataFrame]],
      names(lSpec[[strDataFrame]]),
      function(so_far, x, idx) {
        if (!is.null(x$type) && idx %in% chrDataFrameColnames) {
          # update timestamp to proper class
          if (x$type == "timestamp") {
            x$type <- c("POSIXct", "POSIXt")
          }
          # check if data is the expected mode
          res <- all(x$type == class(lData[[strDataFrame]][[idx]]))
          if (!res) {
            so_far <- c(so_far, idx)
          }
          return(so_far)
        }
      },
      .init = character()
    )

    if (length(wrongType)) {
      LogMessage(
        level = "warn",
        message = "Not all columns of {strDataFrame} in the spec are in the expected format, improperly formatted columns are: {wrongType}"
      )
    } else {
      LogMessage(
        level = "info",
        message = "All specified columns in {strDataFrame} are in the expected format",
        cli_detail = "alert"
      )
    }
    # check that required exist in data, if _all required is not specified
    if (!isTRUE(lSpec[[strDataFrame]]$`_all`$required)) {
      lSpecColumns <- names(lSpec[[strDataFrame]])
      lDataColumns <- names(lData[[strDataFrame]])
      allCols <- c(allCols, paste(strDataFrame, lSpecColumns, sep = "$"))

      thisMissingCols <- lSpecColumns[!lSpecColumns %in% lDataColumns]
      if (length(thisMissingCols) > 0) {
        missingCols <- c(missingCols, paste(strDataFrame, thisMissingCols, sep = "$"))
      }
    }
  }
  if (length(missingCols) > 0) {
    LogMessage(
      level = "warn",
      message = "Not all specified columns in the spec are present in the data, missing columns are: {missingCols}"
    )
  } else if (length(allCols) > 0) {
    LogMessage(
      level = "info",
      message = "All {length(allCols)} specified column(s) in the spec are present in the data: {glue::glue_collapse(allCols, sep = ', ')}",
      cli_detail = "alert"
    )
  } else {
    LogMessage(
      level = "info",
      message = "No columns specified in the spec. All data.frames are pulling in all available columns.",
      cli_detail = "alert"
    )
  }
}
