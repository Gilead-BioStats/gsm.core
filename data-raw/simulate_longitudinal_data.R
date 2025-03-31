library(gsm.core)
library(gsm.mapping)
library(gsm.datasim)
library(gsm.kri)
library(dplyr)
set.seed(1)

core_mappings <- c("AE", "COUNTRY", "DATACHG", "DATAENT", "ENROLL", "LB",
                   "PD", "PK", "QUERY", "STUDY", "STUDCOMP", "SDRGCOMP", "SITE", "SUBJ")

basic_sim <- gsm.datasim::generate_rawdata_for_single_study(
  SnapshotCount = 12,
  SnapshotWidth = "months",
  ParticipantCount = 1000,
  SiteCount = 150,
  StudyID = "AA-AA-000-0000",
  workflow_path = "workflow/1_mappings",
  mappings = core_mappings,
  package = "gsm.mapping",
  desired_specs = NULL
)

lSource <- basic_sim[[12]]
rm(basic_sim)

mappings_wf <- gsm.core::MakeWorkflowList(strNames = core_mappings, strPath = "workflow/1_mappings", strPackage = "gsm.mapping")
mappings_spec <- gsm.mapping::CombineSpecs(mappings_wf)
lRaw <- gsm.mapping::Ingest(lSource, mappings_spec)

# Step 1 - Create Mapped Data Layer - filter, aggregate and join raw data to create mapped data layer
mapped <- gsm.core::RunWorkflows(mappings_wf, lRaw)

# Step 2 - Create Metrics - calculate metrics using mapped data
metrics_wf <- gsm.core::MakeWorkflowList(strPath = "workflow/2_metrics", strPackage = "gsm.kri")
analyzed <- gsm.core::RunWorkflows(metrics_wf, mapped)

# Step 3 - Create Reporting Layer - create reports using metrics data
reporting_wf <- gsm.core::MakeWorkflowList(strPath = "workflow/3_reporting", strPackage = "gsm.reporting")
reporting <- gsm.core::RunWorkflows(reporting_wf, c(mapped, list(lAnalyzed = analyzed,
                                                                 lWorkflows = metrics_wf)))

# Step 4 - Create KRI Report - create KRI report using reporting data
module_wf <- gsm.core::MakeWorkflowList(strPath = "workflow/4_modules", strPackage = "gsm.kri")
lReports <- gsm.core::RunWorkflows(module_wf, reporting)

#save site and country data separately
lReporting_site <- list()
lReporting_country <- list()

lReporting_site$Reporting_Results <- reporting$Reporting_Results %>%
  filter(stringr::str_detect(MetricID, "Analysis_kri"))
lReporting_site$Reporting_Groups <- reporting$Reporting_Groups %>%
  filter(GroupLevel %in% c("Study","Site"))
lReporting_site$Reporting_Bounds <- reporting$Reporting_Bounds %>%
  filter(stringr::str_detect(MetricID, "Analysis_kri"))
lReporting_site$Reporting_Metrics <- reporting$Reporting_Metrics %>%
  filter(stringr::str_detect(MetricID, "Analysis_kri"))

lReporting_country$Reporting_Results <- reporting$Reporting_Results %>%
  filter(stringr::str_detect(MetricID, "Analysis_cou"))
lReporting_country$Reporting_Groups <- reporting$Reporting_Groups %>%
  filter(GroupLevel%in% c("Study","Country"))
lReporting_country$Reporting_Bounds <- reporting$Reporting_Bounds %>%
  filter(stringr::str_detect(MetricID, "Analysis_cou"))
lReporting_country$Reporting_Metrics <- reporting$Reporting_Metrics %>%
  filter(stringr::str_detect(MetricID, "Analysis_cou"))

## test out the data on a report
wf_report_site <- MakeWorkflowList(strNames = "report_kri_site", strPackage = "gsm.kri")
lReports_site <- RunWorkflows(wf_report_site, lReporting_site)
# wf_report_country <- MakeWorkflowList(strNames = "report_kri_country")
# lReports_country <- RunWorkflows(wf_report_country, lReporting_country)

# write CSVs

# analysis data
## site
write.csv(file = "data-raw/analyticsSummary.csv",
          x = analyzed$Analysis_kri0001$Analysis_Summary,
          row.names = F)
write.csv(file = "data-raw/analyticsInput.csv",
          x = analyzed$Analysis_kri0001$Analysis_Input,
          row.names = F)

## country
write.csv(file = "data-raw/analyticsSummary_country.csv",
          x = analyzed$Analysis_cou0001$Analysis_Summary,
          row.names = F)
write.csv(file = "data-raw/analyticsInput_country.csv",
          x = analyzed$Analysis_cou0001$Analysis_Input,
          row.names = F)


# reporting data
## site
write.csv(file = "data-raw/reportingGroups.csv",
          x = lReporting_site$Reporting_Groups,
          row.names = F)
write.csv(file = "data-raw/reportingBounds.csv",
          x = lReporting_site$Reporting_Bounds,
          row.names = F)
write.csv(file = "data-raw/reportingMetrics.csv",
          x = lReporting_site$Reporting_Metrics,
          row.names = F)
write.csv(file = "data-raw/reportingResults.csv",
          x = lReporting_site$Reporting_Results,
          row.names = F)

##country
write.csv(file = "data-raw/reportingGroups_country.csv",
          x = lReporting_country$Reporting_Groups,
          row.names = F)
write.csv(file = "data-raw/reportingBounds_country.csv",
          x = lReporting_country$Reporting_Bounds,
          row.names = F)
write.csv(file = "data-raw/reportingMetrics_country.csv",
          x = lReporting_country$Reporting_Metrics,
          row.names = F)
write.csv(file = "data-raw/reportingResults_country.csv",
          x = lReporting_country$Reporting_Results,
          row.names = F)
