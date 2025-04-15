#' Initialize gsm Extension package
#'
#' @param package_dir path to package directory
#' @param description_fields list of description fields, passed to [usethis::create_package()]. Default is `list()`.
#' @param include_workflow_dir boolean argument declaring whether or not to include the `inst/workflow` directory in the root of the package. Default is `TRUE`.
#'
#' @export
init_gsm_package <- function(package_dir,
                             description_fields = list(),
                             include_workflow_dir = TRUE) {
  if(!dir.exists(package_dir)) {
    dir.create(package_dir)
    init_git = TRUE
  }
  usethis::create_package(package_dir,
                          open = F,
                          fields = description_fields)
  withr::with_dir(package_dir, {
  usethis::use_pkgdown_github_pages()
  usethis::use_testthat()
  usethis::use_github_action("check-standard")
  dir.create("inst")

  #add gsm-specific GHA content
  file.copy(system.file("gha_templates", package = "gsm.core"),
            ".github",
            recursive = T)
  if(include_workflow_dir) {
    dir.create("inst/workflow")
    dir.create("inst/workflow/1_mappings")
    dir.create("inst/workflow/2_metrics")
    dir.create("inst/workflow/3_reporting")
    dir.create("inst/workflow/4_modules")
  }
  })
}
