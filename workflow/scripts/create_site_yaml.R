#' @title Update the Navigation Bar
#'
#' @description Update the navigation bar in the _site.yml file
#'
#' @details
#' Uses the information provided in the config file to update the navigation
#' bar
library(tidyverse)
library(yaml)
library(glue)
library(magrittr)

config <- read_yaml(here::here("config", "config.yml"))
samples <- read_tsv(here::here(config$samples))
targets <- sort(unique(samples$target))
dir <- basename(getwd())

site_yaml <- list(
  name = dir,
  output_dir = "../docs",
  navbar = list(
    title = dir,
    left = list(
      list(text = "Home", href = "index.html"),
      list(
        text = "QC", menu = list(
          list(text = "Raw Data", href = "raw_qc.html"),
          list(text = "Trimmed Data", href = "trim_qc.html"),
          list(text = "Alignments", href = "align_qc.html")
        )
      ),
      list(
        text = "Results", menu = list()
      )
    ),
    right = list(
      list(icon = "fa-github", href = "https://github.com/smped/prepareChIPs")
    )
  ),
  output = list(
    html_document = list(
      code_folding = "hide",
      toc = TRUE, toc_float = TRUE,
      theme = "sandstone", highlight = "textmate",
      includes = list(after_body = "footer.html")
    )
  )
)


## Create the output directory, if it doesn't exist
if (!is.null(site_yaml$output_dir)) {
  out_dir <- here::here("docs")
  message("Checking for directory: ", out_dir)
  if (!dir.exists(out_dir)) {
    message("Creating: ", out_dir)
    stopifnot(dir.create(out_dir))
  }
  message(out_dir, " exists")
}


site_yaml$navbar$left[[3]]$menu <- lapply(
  targets,
  function(x) {
    list(text = x, href = glue("{str_to_lower(x)}_macs2_summary.html"))
  }
)

## Create the analysis directory if it doesn't exist
analysis_dir <- here::here("analysis")
if  (!dir.exists(analysis_dir)) dir.create(analysis_dir)
write_yaml(site_yaml, file.path(analysis_dir, "_site.yml"))



