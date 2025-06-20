% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aaa-shared.R
\name{shared-params}
\alias{shared-params}
\title{Parameters used in multiple functions}
\arguments{
\item{dfBounds}{\code{data.frame} Set of predicted percentages/rates and upper-
and lower-bounds across the full range of sample sizes/total exposure
values for reporting. Expected columns: \code{Threshold}, \code{Denominator},
\code{Numerator}, \code{Metric}, \code{MetricID}, \code{StudyID}, \code{SnapshotDate}.}

\item{dfInput}{\code{data.frame} Input data with one record per subject. Created
by passing Raw+ data into \code{\link[=Input_Rate]{Input_Rate()}}. Expected columns: \code{GroupID},
\code{GroupLevel}, \code{Numerator}, \code{Denominator} and/or columns specified in
\code{strCountCol} and \code{strGroupCol}.}

\item{lParamLabels}{\code{list} Labels for parameters, with the parameters as
names, and the label as value.}

\item{bDebug}{\code{logical} Print debug messages? Default: \code{FALSE}.}
}
\description{
Reused parameter definitions are gathered here for easier usage.
}
\keyword{internal}
