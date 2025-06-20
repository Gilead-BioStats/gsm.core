#' Run a single step in a workflow.
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' Runs a single step of an assessment workflow. This function is called by `RunWorkflow` for each
#' step in the workflow. It prepares the parameters for the function call and then calls the function
#' specified in `lStep$name` with the prepared parameters.
#'
#' The primary utility of this function is to provide a prioritized parser for function parameterization.
#' Parameters should be specified as a named list in `lStep$params`, where each element is a key-value pair
#' that will be parsed and then passed to the specified function as a set of parameter names/values.
#' Parameter values should be specified as scalar strings. Those values are then pulled from `lMeta` or `lData`
#' when possible. When no matching `lData` or `lMeta` objects are found, parameter values are passed through as
#' strings. Note that parsing vectorized parameters is not supported at this time; they are passed directly
#' as character vectors. To pass a vector or list, we recommend saving it as an object in `lData`.
#'
#' Full prioritization for parsing parameters is below:
#'
#' 1. If a single parameter value is equal to "lMeta", the the full lMeta object is passed to the function
#' (for the given paramName).
#' 2. If a single parameter value is equal to "lData", the full lData object is passed to the function.
#' 3. If a single parameter value is equal to "lSpec", the full lSpec object is passed to the function.
#' 4. If a single parameter value is found in names(lMeta), that property is pulled from lMeta (e.g.
#' lMeta$\{paramVal\}) and passed to the function.
#' 5. If a single parameter value is found in names(lData), that property is pulled from lData (e.g.
#' lData$\{paramVal\}) and passed to the function.
#' 6. Otherwise single parameter value is passed to the function as a string.
#' 7. If the parameter value is a vector, the vector is passed to the function as a vector or strings.
#'
#' @param lStep `list` single workflow step (typically pulled from `lWorkflow$steps`). Should
#'   include the name of the function to run (`lStep$name`), name of the object where the function result should be saved (`lStep$output`) and configurable parameters (`lStep$params`) (if any)
#' @param lData `list` a named list of domain level data frames.
#' @param lSpec `list` a data specification containing required columns. See the
#'  [gsm Extensions article](https://gilead-biostats.github.io/gsm.core/articles/gsmExtensions.html).
#' @param lMeta `list` a named list of meta data.
#'
#' @examples
#' wf_mapping <- MakeWorkflowList(
#'   strNames = c("AE", "SUBJ"),
#'   strPath = "example_workflow/1_mappings",
#'   strPackage = "gsm.core",
#'   bExact = TRUE
#' )
#' lWorkflow <- MakeWorkflowList(
#'   strPath = "example_workflow/2_metrics",
#'   strNames = c("kri0001", "kri0002"),
#'   strPackage = "gsm.core"
#' )
#' lStep <- lWorkflow[["kri0001"]][["steps"]][[1]]
#' lMeta <- lWorkflow[["kri0001"]][["meta"]]
#'
#' lRaw <- list(
#'   Raw_SUBJ = gsm.core::lSource$Raw_SUBJ,
#'   Raw_AE = gsm.core::lSource$Raw_AE
#' )
#'
#' mapped <- RunWorkflows(wf_mapping, lRaw)
#' ae_step <- RunStep(lStep = lStep, lData = lMapped, lMeta = lMeta)
#'
#' @return `list` containing the results of the `lStep$name` function call should contain `.$checks`
#'   parameter with results from `is_mapping_vald` for each domain in `lStep$inputs`.
#'
#' @export

RunStep <- function(lStep, lData, lMeta, lSpec = NULL) {
  # prepare parameter list inputs
  params <- lStep$params

  # to make sure do.call can be invoked even if no params are provided in the step
  if (is.null(params)) {
    params <- list()
  }
  LogMessage(
    level = "info",
    message = "Evaluating {length(params)} parameter(s) for `{lStep$name}`",
    cli_detail = "h3"
  )

  # This loop iterates over each parameter in the 'params' object.
  for (paramName in names(params)) {
    paramVal <- params[[paramName]]
    if (length(paramVal) == 1) {
      if (paramVal == "lMeta") {
        # Pass lMeta (typically from the workflow header)
        LogMessage(
          level = "info",
          message = "{paramName} = {paramVal}:  Passing full lMeta object.",
          cli_detail = "alert_success"
        )
        params[[paramName]] <- lMeta
      } else if (paramVal == "lData") {
        # Pass lData
        LogMessage(
          level = "info",
          message = "{paramName} = {paramVal}:  Passing full lData object.",
          cli_detail = "alert_success"
        )
        params[[paramName]] <- lData
      } else if (paramVal == "lSpec") {
        # Pass lSpec
        LogMessage(
          level = "info",
          message = "{paramName} = {paramVal}:  Passing full lSpec object.",
          cli_detail = "alert_success"
        )
        params[[paramName]] <- lSpec
      } else if (paramVal %in% names(lMeta)) {
        # Use named items from lMeta
        LogMessage(
          level = "info",
          message = "{paramName} = {paramVal}: Passing lMeta${paramVal}.",
          cli_detail = "alert_success"
        )
        params[[paramName]] <- lMeta[[paramVal]]
      } else if (paramVal %in% names(lData)) {
        LogMessage(
          level = "info",
          message = "{paramName} = {paramVal}: Passing lData${paramVal}.",
          cli_detail = "alert_success"
        )
        params[[paramName]] <- lData[[paramVal]]
      } else {
        # If the parameter value is not found in 'lMeta' or 'lData', pass the parameter value as a string.
        LogMessage(
          level = "info",
          message = "{paramName} = {paramVal}: No matching data found. Passing '{paramVal}' as a string.",
          cli_detail = "alert_info"
        )
      }
    } else {
      # If the parameter value is a vector, pass the vector as is.
      LogMessage(
        level = "info",
        message = "{paramName} is of length {length(paramVal)}: Parameter is a vector. Passing as is.",
        cli_detail = "alert_info"
      )
    }
  }

  LogMessage(
    level = "info",
    message = "Calling `{lStep$name}`",
    cli_detail = "h3"
  )

  return(do.call(GetStrFunctionIfNamespaced(lStep$name), params))
}
