library(gsm.core)
library(gsm.mapping)
library(gsm.kri)
library(gsm.reporting)
library(dplyr)

#### 3.1 - Create a KRI Report using 13 standard metrics in a step-by-step workflow

core_mappings <- c("AE", "COUNTRY", "DATACHG", "DATAENT", "ENROLL", "LB", "PK", "VISIT",
                   "PD", "QUERY", "STUDY", "STUDCOMP", "SDRGCOMP", "SITE", "SUBJ")

# Step 0 - Create Raw Data from Source Data
lRaw <- list(
  Raw_SUBJ = gsm.core::lSource$Raw_SUBJ,
  Raw_AE = gsm.core::lSource$Raw_AE,
  Raw_PD = gsm.core::lSource$Raw_PD %>%
    rename(subjid = subjectenrollmentnumber),
  Raw_PK = gsm.core::lSource$Raw_PK %>%
    rename(visit = foldername),
  Raw_LB = gsm.core::lSource$Raw_LB,
  Raw_STUDCOMP = gsm.core::lSource$Raw_STUDCOMP %>%
    select(subjid, compyn),
  Raw_SDRGCOMP = gsm.core::lSource$Raw_SDRGCOMP,
  Raw_DATACHG = gsm.core::lSource$Raw_DATACHG %>%
    rename(subject_nsv = subjectname),
  Raw_DATAENT = gsm.core::lSource$Raw_DATAENT %>%
    rename(subject_nsv = subjectname),
  Raw_QUERY = gsm.core::lSource$Raw_QUERY %>%
    rename(subject_nsv = subjectname),
  Raw_ENROLL = gsm.core::lSource$Raw_ENROLL,
  Raw_SITE = gsm.core::lSource$Raw_SITE %>%
    rename(studyid = protocol) %>%
    rename(invid = pi_number) %>%
    rename(InvestigatorFirstName = pi_first_name) %>%
    rename(InvestigatorLastName = pi_last_name) %>%
    rename(City = city) %>%
    rename(State = state) %>%
    rename(Country = country) %>%
    rename(Status = site_status),
  Raw_STUDY = gsm.core::lSource$Raw_STUDY %>%
    rename(studyid = protocol_number) %>%
    rename(Status = status),
  Raw_VISIT = gsm.core::lSource$Raw_VISIT %>%
    mutate(visit_folder = foldername) %>%
    rename(visit = foldername)
)

# Step 1 - Create Mapped Data Layer - filter, aggregate and join raw data to create mapped data layer
mappings_wf <- gsm.core::MakeWorkflowList(strNames = core_mappings, strPath = "workflow/1_mappings", strPackage = "gsm.mapping")
mapped <- gsm.core::RunWorkflows(mappings_wf, lRaw)

# Step 2 - Create Metrics - calculate metrics using mapped data
metrics_wf <- gsm.core::MakeWorkflowList(strPath = "workflow/2_metrics", strPackage = "gsm.kri")
analyzed <- gsm.core::RunWorkflows(metrics_wf, mapped)

# Step 3 - Create Reporting Layer - create reports using metrics data
reporting_wf <- gsm.core::MakeWorkflowList(strPath = "workflow/3_reporting", strPackage = "gsm.reporting")
reporting <- gsm.core::RunWorkflows(reporting_wf, c(mapped, list(lAnalyzed = analyzed, lWorkflows = metrics_wf)))

# Step 4 - Create KRI Reports - create KRI report using reporting data
module_wf <- gsm.core::MakeWorkflowList(strPath = "workflow/4_modules", strPackage = "gsm.kri")
lReports <- gsm.core::RunWorkflows(module_wf, reporting)

#### 3.2 - Automate data ingestion using Ingest() and CombineSpecs()
# Step 0 - Data Ingestion - standardize tables/columns names
mappings_wf <- gsm.core::MakeWorkflowList(strNames = core_mappings, strPath = "workflow/1_mappings", strPackage = "gsm.mapping")
mappings_spec <- gsm.mapping::CombineSpecs(mappings_wf)
lRaw <- gsm.mapping::Ingest(gsm.core::lSource, mappings_spec)

# Step 1 - Create Mapped Data Layer - filter, aggregate and join raw data to create mapped data layer
mapped <- gsm.core::RunWorkflows(mappings_wf, lRaw)

# Step 2 - Create Metrics - calculate metrics using mapped data
metrics_wf <- gsm.core::MakeWorkflowList(strPath = "workflow/2_metrics", strPackage = "gsm.kri")
analyzed <- gsm.core::RunWorkflows(metrics_wf, mapped)

# Step 3 - Create Reporting Layer - create reports using metrics data
reporting_wf <- gsm.core::MakeWorkflowList(strPath = "workflow/3_reporting", strPackage = "gsm.reporting")
reporting <- gsm.core::RunWorkflows(reporting_wf, c(mapped, list(lAnalyzed = analyzed, lWorkflows = metrics_wf)))

# Step 4 - Create KRI Report - create KRI report using reporting data
module_wf <- gsm.core::MakeWorkflowList(strPath = "workflow/4_modules", strPackage = "gsm.kri")
lReports <- gsm.core::RunWorkflows(module_wf, reporting)


#### 3.3 Site-Level KRI Report with multiple SnapshotDate
# Below relies on the clindata stuff, do we need to rerun/rewrite reporting datasets?
lCharts <- gsm.kri::MakeCharts(
  dfResults = gsm.core::reportingResults,
  dfGroups = gsm.core::reportingGroups,
  dfMetrics = gsm.core::reportingMetrics,
  dfBounds = gsm.core::reportingBounds
)

kri_report_path <- gsm.kri::Report_KRI(
  lCharts = lCharts,
  dfResults =  gsm.kri::FilterByLatestSnapshotDate(reportingResults),
  dfGroups =  gsm.core::reportingGroups,
  dfMetrics = gsm.core::reportingMetrics
)

#### 3.4 Reporting Results with Changes from previous snapshot

# Prepare historical data
historical <- gsm.core::reportingResults %>% filter(SnapshotDate == "2025-03-01")

# Re-run reporting model and KRI report with historical data
reporting_long <- gsm.core::RunWorkflows(reporting_wf, c(mapped, list(lAnalyzed = analyzed, Reporting_Results_Longitudinal = historical, lWorkflows = metrics_wf)))
lReports_long <- gsm.core::RunWorkflows(module_wf, reporting_long)
