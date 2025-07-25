% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/Analyze_Identity.R
\name{Analyze_Identity}
\alias{Analyze_Identity}
\title{Identity Analysis.}
\usage{
Analyze_Identity(dfTransformed, strValueCol = "Metric")
}
\arguments{
\item{dfTransformed}{\code{data.frame} Transformed data for analysis. Data should
have one record per site with expected columns: \code{GroupID}, \code{GroupLevel},
\code{Numerator}, \code{Denominator}, and \code{Metric}. For more details see the
\href{https://gilead-biostats.github.io/gsm.core/articles/DataModel.html}{Data Model article}.
For this function, \code{dfTransformed} should typically be created using
\code{\link[=Transform_Count]{Transform_Count()}}.}

\item{strValueCol}{\code{character} Name of column that will be copied as \code{Score}}
}
\value{
\code{data.frame} with one row per site with columns: GroupID, TotalCount,
Metric, and Score.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}

Used in the data pipeline between \code{Transform} and \code{Flag} to rename KRI and
Score columns.

More information can be found in \href{https://gilead-biostats.github.io/gsm.core/articles/KRI\%20Method.html#the-identity-method}{The Identity Method}
of the KRI Method vignette.
}
\examples{
dfTransformed <- Transform_Count(analyticsInput, strCountCol = "Numerator")
dfAnalyzed <- Analyze_Identity(dfTransformed)

}
