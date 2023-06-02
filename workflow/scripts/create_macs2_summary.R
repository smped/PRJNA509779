#' Set the .libPaths() first in case there are conflicts in a conda environment
conda_pre <- system2("echo", "$CONDA_PREFIX", stdout = TRUE)
if (conda_pre != ""){
  conda_lib_path <- file.path(conda_pre, "lib", "R", "library")
  if (!dir.exists(conda_lib_path)) conda_lib_path <- NULL
  prev_paths <- .libPaths()
  paths_to_set <- unique(c(conda_lib_path, prev_paths))
  .libPaths(paths_to_set)
}
library(readr)
library(glue)

args <- commandArgs(TRUE)
target <- args[[1]]
rmd <- args[[2]]

txt <- glue(
	"
	---
	title: '{{target}}: MACS2 Summary'
	date: \"`r format(Sys.Date(), '%d %B, %Y')`\"
	bibliography: references.bib
	link-citations: true
	params:
	  target: \"{{target}}\"
	---

	",
	.open = "{{",
	.close = "}}"
)
write_lines(txt, rmd)