% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Transform_Count.R
\name{Transform_Count}
\alias{Transform_Count}
\title{Transform Count}
\usage{
Transform_Count(dfInput, strCountCol, strGroupCol = "GroupID")
}
\arguments{
\item{dfInput}{\code{data.frame} Input data with one record per subject. Created
by passing Raw+ data into \code{\link[=Input_Rate]{Input_Rate()}}. Expected columns: \code{GroupID},
\code{GroupLevel}, \code{Numerator}, \code{Denominator} and/or columns specified in
\code{strCountCol} and \code{strGroupCol}.}

\item{strCountCol}{Required. Numerical or logical. Column to be counted.}

\item{strGroupCol}{\code{character} Name of column for grouping variable. Default: \code{"GroupID"}}
}
\value{
\code{data.frame} with one row per site with columns \code{GroupID}, \code{TotalCount}, and \code{Metric.}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}

Convert from input data format to needed input format to derive KRI for an Assessment. Calculate site-level count.
}
\details{
This function transforms data to prepare it for the analysis step. It is currently only sourced for the Consent and IE Assessments.
}
\section{Data Specification}{


(\code{dfInput}) must include the columns specified by \code{strCountCol} and \code{strGroupCol}.
Required columns include:
\itemize{
\item \code{GroupID} - Group ID
\item \code{GroupLevel} - Group Type
\item \code{Numerator} - Number of events of interest; the actual name of this column is specified by the parameter \code{strNumeratorCol}
\item \code{Denominator} - Number of days on treatment; the actual name of this column is specified by the parameter \code{strDenominatorCol}
}

The input data has one or more rows per site. \code{Transform_Count()} sums \code{strCountCol} for a \code{TotalCount} for each site. \code{Metric} is set to \code{TotalCount} to be used downstream in the workflow.
}

\examples{
dfTransformed <- Transform_Count(analyticsInput, strCountCol = "Numerator")

}
