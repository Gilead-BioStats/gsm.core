library(dplyr)
wf_mapping <- MakeWorkflowList(strPath = "testdata/mappings")
workflows <- MakeWorkflowList(strPath = "testdata/metrics")

# Don't run things we don't use.
used_params <- map(workflows, ~ map(.x$steps, "params")) %>%
  unlist() %>%
  unique()
wf_mapping$steps <- purrr::keep(
  wf_mapping$steps,
  ~ .x$output %in% used_params
)
# Source Data
lSource <- gsm.core::lSource

# Step 0 - Data Ingestion - standardize tables/columns names
lRaw <- list(
  Raw_SUBJ = lSource$Raw_SUBJ,
  Raw_AE = lSource$Raw_AE,
  Raw_PD = lSource$Raw_PD %>%
    dplyr::rename(subjid = subjectenrollmentnumber),
  Raw_LB = lSource$Raw_LB,
  Raw_STUDCOMP = lSource$Raw_STUDCOMP %>%
    dplyr::select(subjid, compyn),
  Raw_SDRGCOMP = lSource$Raw_SDRGCOMP,
  Raw_DATACHG = lSource$Raw_DATACHG %>%
    dplyr::rename(subject_nsv = subjectname),
  Raw_DATAENT = lSource$Raw_DATAENT %>%
    dplyr::rename(subject_nsv = subjectname),
  Raw_QUERY = lSource$Raw_QUERY %>%
    dplyr::rename(subject_nsv = subjectname),
  Raw_ENROLL = lSource$Raw_ENROLL,
  Raw_SITE = lSource$Raw_SITE %>%
    dplyr::rename(studyid = protocol) %>%
    dplyr::rename(invid = pi_number) %>%
    dplyr::rename(InvestigatorFirstName = pi_first_name) %>%
    dplyr::rename(InvestigatorLastName = pi_last_name) %>%
    dplyr::rename(City = city) %>%
    dplyr::rename(State = state) %>%
    dplyr::rename(Country = country) %>%
    dplyr::rename(Status = site_status),
  Raw_STUDY = lSource$Raw_STUDY %>%
    dplyr::rename(studyid = protocol_number) %>%
    dplyr::rename(Status = status)
)

# Create Mapped Data
lMapped <- quiet_RunWorkflows(lWorkflows = wf_mapping, lData = lRaw)

# Run Metrics
results <- map(
  workflows,
  ~ quiet_RunWorkflow(lWorkflow = .x, lData = lMapped, bReturnResult = FALSE, bKeepInputData = FALSE)
)

yaml_outputs <- map(
  map(workflows, ~ map_vec(.x$steps, ~ .x$output)),
  ~ .x[!grepl("lCharts", .x)]
)

test_that("RunWorkflow preserves all steps when bReturnResult = FALSE", {
  expect_no_error({
    purrr::iwalk(
      workflows,
      function(this_workflow, this_name) {
        expect_identical(
          this_workflow, results[[this_name]][names(this_workflow)]
        )
      }
    )
  })
})

test_that("RunWorkflow contains all outputs from yaml steps", {
  expect_no_error({
    purrr::iwalk(
      results,
      function(this_result, this_name) {
        expect_setequal(yaml_outputs[[this_name]], names(this_result$lData))
      }
    )
  })
})

test_that("RunWorkflow contains all outputs from yaml steps with populated fields (contains rows of data)", {
  expect_no_error({
    purrr::iwalk(
      yaml_outputs,
      function(this_output_set, this_name) {
        expect_true(
          all(map_int(results[[this_name]]$lData[this_output_set], NROW) > 0)
        )
      }
    )
  })
})
