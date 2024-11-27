#! /usr/bin/env Rscript

presentation_file <- Sys.getenv("IBC_PRESENTATION_FILE", unset = "")
presentation_dir <- Sys.getenv("IBC_PRESENTATION_DIR", unset = "")
host <- Sys.getenv("HOST", unset = "127.0.0.1")

if (presentation_file == "") {
  stop("`IBC_PRESENTATION_FILE` environment variable not set.")
}
if (presentation_dir == "") {
  stop("`IBC_PRESENTATION_DIR` environment variable not set.")
}

rmd_build_dir <- tempdir()

rmarkdown::run(
  presentation_file,
  shiny_args = list(
    launch.browser = FALSE,
    port = 3838,
    host = host
  ),
  auto_reload = FALSE,
  dir = presentation_dir,
  render_args = list(
    encoding = 'UTF-8',
    intermediates_dir = rmd_build_dir
  )
)
