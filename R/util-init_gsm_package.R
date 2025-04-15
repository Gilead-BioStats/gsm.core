init_gsm_package <- function(package_dir,
                             description_fields = list(),
                             include_workflow_dir = TRUE) {
  usethis::create_package(package_dir,
                          open = F,
                          fields = description_fields)
  setwd(package_dir)
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
}

gsm_styler <- function() {
  double_indent_style <- styler::tidyverse_style()
  double_indent_style$indention$unindent_fun_dec <- NULL
  double_indent_style$indention$update_indention_ref_fun_dec <- NULL
  double_indent_style$line_break$remove_line_breaks_in_fun_dec <- NULL
  styler::style_dir('R', transformers = double_indent_style)
  styler::style_dir('tests', recursive = TRUE, transformers = double_indent_style)
}
