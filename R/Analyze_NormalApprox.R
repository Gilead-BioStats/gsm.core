#' Funnel Plot Analysis with Normal Approximation for Binary and Rate Outcomes.
#'
#' @description `r lifecycle::badge("stable")`
#'
#' Creates analysis results data for percentage/rate data using funnel plot
#' method with normal approximation.
#'
#' More information can be found in [The Normal Approximation
#' Method](https://gilead-biostats.github.io/gsm.core/articles/KRI%20Method.html#the-normal-approximation-method)
#' of the KRI Method vignette.
#'
#' @section Statistical Methods: This function applies funnel plots using
#'   asymptotic limits based on the normal approximation of a binomial
#'   distribution for the binary outcome, or normal approximation of a Poisson
#'   distribution for the rate outcome with volume (the sample sizes or total
#'   exposure of the sites) to assess data quality and safety.
#'
#' @param dfTransformed `data.frame` Transformed data for analysis. Data should
#'   have one record per site with expected columns: `GroupID`, `GroupLevel`,
#'   `Numerator`, `Denominator`, and `Metric`. For more details see the
#'   [Data Model article](https://gilead-biostats.github.io/gsm.core/articles/DataModel.html).
#'   For this function, `dfTransformed` should typically be created using
#'   [Transform_Rate()].
#' @param strType `character` Statistical outcome type. Valid values:
#'   - `"binary"` (default)
#'   - `"rate"`
#'
#' @return `data.frame` with one row per site with columns: GroupID, Numerator,
#'   Denominator, Metric, OverallMetric, Factor, and Score.
#'
#' @examples
#' # Binary
#' dfTransformed <- Transform_Rate(analyticsInput)
#'
#' dfAnalyzed <- Analyze_NormalApprox(dfTransformed, strType = "binary")
#'
#' # Rate
#' dfAnalyzed <- Analyze_NormalApprox(dfTransformed, strType = "rate")
#'
#' @export

Analyze_NormalApprox <- function(
  dfTransformed,
  strType = "binary"
) {
  stop_if(cnd = !is.data.frame(dfTransformed), message = "dfTransformed is not a data.frame")
  stop_if(
    cnd = !all(c("GroupID", "GroupLevel", "Denominator", "Numerator", "Metric") %in% names(dfTransformed)),
    message = "One or more of these columns not found: GroupID, GroupLevel, Denominator, Numerator, Metric"
  )
  stop_if(cnd = !all(!is.na(dfTransformed[["GroupID"]])), message = "NA value(s) found in GroupID")
  stop_if(cnd = !strType %in% c("binary", "rate"), message = "strType is not 'binary' or 'rate'")

  # Caclulate Z-score with overdispersion --------------------------------------
  if (strType == "binary") {
    dfScore <- dfTransformed %>%
      mutate(
        vMu = sum(.data$Numerator) / sum(.data$Denominator),
        z_0 = ifelse(.data$vMu == 0 | .data$vMu == 1,
          0,
          (.data$Metric - .data$vMu) /
            sqrt(.data$vMu * (1 - .data$vMu) / .data$Denominator)
        ),
        phi = mean(.data$z_0^2),
        z_i = ifelse(.data$vMu == 0 | .data$vMu == 1 | .data$phi == 0,
          0,
          (.data$Metric - .data$vMu) /
            sqrt(.data$phi * .data$vMu * (1 - .data$vMu) / .data$Denominator)
        )
      )
  } else if (strType == "rate") {
    dfScore <- dfTransformed %>%
      mutate(
        vMu = sum(.data$Numerator) / sum(.data$Denominator),
        z_0 = ifelse(.data$vMu == 0,
          0,
          (.data$Metric - .data$vMu) /
            sqrt(.data$vMu / .data$Denominator)
        ),
        phi = mean(.data$z_0^2),
        z_i = ifelse(.data$vMu == 0 | .data$phi == 0,
          0,
          (.data$Metric - .data$vMu) /
            sqrt(.data$phi * .data$vMu / .data$Denominator)
        )
      )
  }

  # dfAnalyzed -----------------------------------------------------------------
  dfAnalyzed <- dfScore %>%
    select(
      "GroupID",
      "GroupLevel",
      "Numerator",
      "Denominator",
      "Metric",
      OverallMetric = "vMu",
      Factor = "phi",
      Score = "z_i"
    ) %>%
    arrange(.data$Score)

  LogMessage(
    level = "info",
    message = "`OverallMetric`, `Factor`, and `Score` columns created from normal approximation.",
    cli_detail = "inform"
  )


  return(dfAnalyzed)
}
