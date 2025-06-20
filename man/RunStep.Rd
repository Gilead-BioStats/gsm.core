% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RunStep.R
\name{RunStep}
\alias{RunStep}
\title{Run a single step in a workflow.}
\usage{
RunStep(lStep, lData, lMeta, lSpec = NULL)
}
\arguments{
\item{lStep}{\code{list} single workflow step (typically pulled from \code{lWorkflow$steps}). Should
include the name of the function to run (\code{lStep$name}), name of the object where the function result should be saved (\code{lStep$output}) and configurable parameters (\code{lStep$params}) (if any)}

\item{lData}{\code{list} a named list of domain level data frames.}

\item{lMeta}{\code{list} a named list of meta data.}

\item{lSpec}{\code{list} a data specification containing required columns. See the
\href{https://gilead-biostats.github.io/gsm.core/articles/gsmExtensions.html}{gsm Extensions article}.}
}
\value{
\code{list} containing the results of the \code{lStep$name} function call should contain \code{.$checks}
parameter with results from \code{is_mapping_vald} for each domain in \code{lStep$inputs}.
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#stable}{\figure{lifecycle-stable.svg}{options: alt='[Stable]'}}}{\strong{[Stable]}}

Runs a single step of an assessment workflow. This function is called by \code{RunWorkflow} for each
step in the workflow. It prepares the parameters for the function call and then calls the function
specified in \code{lStep$name} with the prepared parameters.

The primary utility of this function is to provide a prioritized parser for function parameterization.
Parameters should be specified as a named list in \code{lStep$params}, where each element is a key-value pair
that will be parsed and then passed to the specified function as a set of parameter names/values.
Parameter values should be specified as scalar strings. Those values are then pulled from \code{lMeta} or \code{lData}
when possible. When no matching \code{lData} or \code{lMeta} objects are found, parameter values are passed through as
strings. Note that parsing vectorized parameters is not supported at this time; they are passed directly
as character vectors. To pass a vector or list, we recommend saving it as an object in \code{lData}.

Full prioritization for parsing parameters is below:
\enumerate{
\item If a single parameter value is equal to "lMeta", the the full lMeta object is passed to the function
(for the given paramName).
\item If a single parameter value is equal to "lData", the full lData object is passed to the function.
\item If a single parameter value is equal to "lSpec", the full lSpec object is passed to the function.
\item If a single parameter value is found in names(lMeta), that property is pulled from lMeta (e.g.
lMeta$\{paramVal\}) and passed to the function.
\item If a single parameter value is found in names(lData), that property is pulled from lData (e.g.
lData$\{paramVal\}) and passed to the function.
\item Otherwise single parameter value is passed to the function as a string.
\item If the parameter value is a vector, the vector is passed to the function as a vector or strings.
}
}
\examples{
wf_mapping <- MakeWorkflowList(
  strNames = c("AE", "SUBJ"),
  strPath = "example_workflow/1_mappings",
  strPackage = "gsm.core",
  bExact = TRUE
)
lWorkflow <- MakeWorkflowList(
  strPath = "example_workflow/2_metrics",
  strNames = c("kri0001", "kri0002"),
  strPackage = "gsm.core"
)
lStep <- lWorkflow[["kri0001"]][["steps"]][[1]]
lMeta <- lWorkflow[["kri0001"]][["meta"]]

lRaw <- list(
  Raw_SUBJ = gsm.core::lSource$Raw_SUBJ,
  Raw_AE = gsm.core::lSource$Raw_AE
)

mapped <- RunWorkflows(wf_mapping, lRaw)
ae_step <- RunStep(lStep = lStep, lData = lMapped, lMeta = lMeta)

}
