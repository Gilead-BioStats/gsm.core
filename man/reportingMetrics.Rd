% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data-specs.R
\docType{data}
\name{reportingMetrics}
\alias{reportingMetrics}
\title{reportingMetrics Dataset}
\format{
A data frame with 13 rows and 16 columns:
\describe{
\item{MetricID}{unique metric identifier}
\item{GroupLevel}{level of grouping variable}
\item{Abbreviation}{abbreviation for the metric}
\item{Metric}{name of the metric}
\item{Numerator}{data source for the numerator}
\item{Denominator}{data source for the denominator}
\item{Model}{model used to calculate metric}
\item{Score}{type of score reported}
\item{Type}{statistical outcome type}
\item{Threshold}{thresholds to be used for bounds and flags}
\item{AccrualThreshold}{minimum numerator required to return a score and calculate a flag}
\item{AccrualMetric}{metric used to apply threshold to}
\item{ID}{ID}
\item{Priority}{Priority in workflow}
\item{AnalysisType}{analysis type}
\item{Flag}{thresholds to be used for vFlags argument}
}
}
\source{
Generated from \code{reportingMetrics.csv} dataset in the \code{gsm.core} package.
}
\usage{
reportingMetrics
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}
}
\keyword{datasets}
