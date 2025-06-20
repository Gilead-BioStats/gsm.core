#' Make Summary Data Frame
#'
#' @description `r lifecycle::badge("stable")`
#'
#' Create a concise summary of assessment results that is easy to aggregate
#' across assessments
#'
#' @details
#'
#' `Summarize` supports the input data (`dfFlagged`) from the `Flag` function.
#'
#' @section Data Specification:
#'
#'   (`dfFlagged`) has the following required columns:
#' - `GroupID` - Group ID
#' - `GroupLevel` - Group Type
#' - `Flag` - Flagging value of -1, 0, or 1
#' - `Score` - Column from analysis results.
#'
#' @param dfFlagged data.frame in format produced by [Flag()].
#' @param nMinDenominator `numeric` Specifies the minimum denominator required
#'   to return a `score` and calculate a `flag`. Default: NULL
#'
#' @return Simplified finding data.frame with columns for GroupID, GroupType,
#'   Metric, Score, Flag when associated with a workflow.
#'
#' @examples
#'
#' dfTransformed <- Transform_Rate(analyticsInput)
#' dfAnalyzed <- Analyze_NormalApprox(dfTransformed)
#' dfFlagged <- Flag(dfAnalyzed)
#' dfSummary <- Summarize(dfFlagged)
#'
#' @export

Summarize <- function(
  dfFlagged,
  nMinDenominator = lifecycle::deprecated()
) {
  stop_if(cnd = !is.data.frame(dfFlagged), message = "dfFlagged is not a data frame")
  stop_if(
    cnd = !all(c("GroupID", "GroupLevel", "Flag", "Score") %in% names(dfFlagged)),
    message = "One or more of these columns: GroupID, GroupLevel, Flag, Score, not found in dfFlagged"
  )

  if (!("Numerator" %in% colnames(dfFlagged))) {
    dfFlagged$Numerator <- NA
  }

  if (!("Denominator" %in% colnames(dfFlagged))) {
    dfFlagged$Denominator <- NA
  }

  dfSummary <- dfFlagged %>%
    select(
      any_of(
        c(
          "GroupID",
          "GroupLevel",
          "Numerator",
          "Denominator",
          "Metric",
          "Score",
          "Flag"
        )
      )
    ) %>%
    arrange(desc(abs(.data$Metric))) %>%
    arrange(match(.data$Flag, c(2, -2, 1, -1, 0)))

  if (lifecycle::is_present(nMinDenominator)) {
    lifecycle::deprecate_warn(
      when = "1.0.0",
      what = "Summarize(nMinDenominator)",
      details = "Please use the `nAccrualThreshold` and `strAccrualMetric` arguments in `Flag()` instead"
    )
    dfSummary$Score[dfSummary$Denominator < nMinDenominator] <- NA
    dfSummary$Flag[dfSummary$Denominator < nMinDenominator] <- NA

    LogMessage(
      level = "info",
      message = paste0(
        sum(dfSummary$Denominator < nMinDenominator),
        " Group(s) have insufficient sample size due to KRI denominator less than {nMinDenominator}. \nThese group(s) will not have KRI score and flag summarized."
      ),
      cli_detail = "alert_info"
    )
  }

  return(dfSummary)
}
