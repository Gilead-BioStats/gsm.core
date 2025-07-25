#' Run a SQL query on a data frame or DuckDB table
#'
#' @description
#' `r lifecycle::badge("stable")`
#'
#' `RunQuery` executes a SQL query on a data frame or a DuckDB lazy table, allowing dynamic use of local or database-backed data.
#' If a DuckDB connection is passed in as `df`, it operates on the existing connection. Otherwise, it creates a temporary DuckDB
#' table from the provided data frame for SQL processing.
#'
#' The SQL query should include the placeholder `FROM df` to indicate where the primary data source (`df`) should be referenced.
#'
#' @param strQuery `character` SQL query to run, containing placeholders `"FROM df"`.
#' @param df `data.frame` or `tbl_dbi` A data frame or DuckDB lazy table to use in the SQL query.
#' @param bUseSchema `boolean` should we use a schema to enforce data types. Defaults to `FALSE`.
#' @param lColumnMapping `list` a namesd list of column specifications for a single data.frame.
#' Required if `bUseSchema` is `TRUE`.
#'
#' @return `data.frame` containing the results of the SQL query.
#'
#' @examplesIf rlang::is_installed(c("DBI", "dbplyr", "duckdb"))
#' df <- data.frame(
#'   Name = c("John", "Jane", "Bob"),
#'   Age = c(25, 30, 35),
#'   Salary = c(50000, 60000, 70000)
#' )
#' query <- "SELECT * FROM df WHERE AGE > 30"
#'
#' result <- RunQuery(query, df)
#'
#' @export
RunQuery <- function(strQuery, df, bUseSchema = FALSE, lColumnMapping = NULL) {
  stop_if(cnd = !is.character(strQuery), message = "strQuery must be a query")

  # Check that strQuery contains "FROM df"
  stop_if(cnd = !grepl("FROM df", strQuery), message = "strQuery must contain 'FROM df'")

  # Check that columnMapping exists if use_schema == TRUE

  stop_if(
    cnd = (bUseSchema && is.null(lColumnMapping)),
    message = "if use_schema = TRUE, you must provide lColumnMapping spec"
  )

  # Enforce data structure of schema.
  if (bUseSchema) {
    lColumnMapping <- lColumnMapping %>%
      imap(function(spec, name) {
        mapping <- list(target = name)

        # use `source_col` for `source` if using mapping and it hasn't gone
        # through ApplySpec()
        mapping$source <- spec[["source"]] %||% spec[["source_col"]] %||% name

        # NULL type breaks things below, so use existing type from if not specified
        mapping$type <- spec[["type"]] %||% class(df[[mapping$source]])[1]

        return(mapping)
      })
  }

  # Set up the connection and table names if passing in duckdb lazy table
  if (inherits(df, "tbl_dbi")) {
    LogMessage(
      level = "info",
      message = "Using provided DuckDB connection.",
      cli_detail = "text"
    )
    con <- dbplyr::remote_con(df)
    table_name <- dbplyr::remote_name(df)
  } else {
    if (ncol(df) == 0) {
      LogMessage(
        level = "warn",
        message = "df has no columns. Query not run. Returning empty data frame."
      )
      return(df)
    }
    LogMessage(
      level = "info",
      message = "Creating a new temporary DuckDB connection.",
      cli_detail = "text"
    )
    con <- DBI::dbConnect(duckdb::duckdb())
    temp_table_name <- paste0("temp_table_", format(Sys.time(), "%Y%m%d_%H%M%S"))
    append_tab <- FALSE
    if (bUseSchema) {
      create_tab_query <- lColumnMapping %>%
        map_chr(function(mapping) {
          type <- switch(mapping$type,
            Date = "DATE",
            numeric = "DOUBLE",
            integer = "INTEGER",
            character = "VARCHAR",
            timestamp = "DATETIME",
            logical = "BOOLEAN",
            POSIXct = "DATETIME",
            NULL
          )
          if (is.null(type)) {
            LogMessage(
              level = "error",
              message = glue("Unsupported type '{mapping$type}' for column '{mapping$source}'.")
            )
          }
          glue("{mapping$source} {type}") %>%
            trimws()
        }) %>%
        paste(collapse = ", ")
      create_tab_query <- glue("CREATE TABLE {temp_table_name} ({create_tab_query})")
      DBI::dbExecute(con, create_tab_query)
      # set up arguments for dbWriteTable
      append_tab <- TRUE
      df <- select(
        df,
        # need this to be an unnamed vector to avoid using target colnames here
        map_chr(lColumnMapping, function(x) x$source) %>% unname()
      )

      # Sanitize Date and timestamp columns
      for (mapping in lColumnMapping) {
        if (mapping$type %in% c("Date", "timestamp") && mapping$source %in% names(df)) {
          raw_vals <- df[[mapping$source]]

          if ((mapping$type == "timestamp" && !inherits(raw_vals, c("POSIXct", "POSIXt"))) ||
            (mapping$type != "timestamp" && !inherits(raw_vals, mapping$type))) {
            parsed <- map(raw_vals, ~ tryCatch(
              as.POSIXct(.x, tz = "UTC"),
              error = function(e) NA_real_
            ))

            parsed <- flatten_dbl(parsed) %>% as.POSIXct(origin = "1970-01-01", tz = "UTC")

            if (mapping$type == "Date") {
              parsed <- as.Date(parsed)
            }

            n_bad <- sum(!is.na(raw_vals) & is.na(parsed))
            if (n_bad > 0) {
              LogMessage(
                level = "warn",
                message = glue("Field `{mapping$source}`: {n_bad} unparsable {mapping$type}(s) set to NA")
              )
            }

            df[[mapping$source]] <- parsed
          }
        }
      }
    }
    DBI::dbWriteTable(con, temp_table_name, df, append = append_tab)
    table_name <- temp_table_name
  }

  strQuery <- gsub("FROM df", paste0("FROM ", table_name), strQuery)

  result <- tryCatch({
    result <- DBI::dbGetQuery(con, strQuery)
    LogMessage(
      level = "info",
      message = "SQL Query complete: {nrow(result)} rows returned.",
      cli_detail = "alert_success"
    )
    result
  }, error = function(e) {
    LogMessage(
      level = "fatal",
      message = "Error executing query: {e$message}"
    )
  }, finally = {
    if (!inherits(df, "tbl_dbi")) {
      DBI::dbDisconnect(con, shutdown = TRUE)
      LogMessage(
        level = "info",
        message = "Disconnected from temporary DuckDB connection.",
        cli_detail = "text"
      )
    }
  })

  return(result)
}
