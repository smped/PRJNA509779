#' Set the .libPaths() first in case there are conflicts in a conda environment
conda_pre <- system2("echo", "$CONDA_PREFIX", stdout = TRUE)
if (conda_pre != "") {
  conda_lib_path <- file.path(conda_pre, "lib", "R", "library")
  if (!dir.exists(conda_lib_path)) conda_lib_path <- NULL
  prev_paths <- .libPaths()
  paths_to_set <- unique(c(conda_lib_path, prev_paths))
  .libPaths(paths_to_set)
}

library(readr)
library(tibble)
library(csaw)
library(Rsamtools)

args <- commandArgs(TRUE)
bamPath <- args[[1]]
outFile <- args[[2]]

message("Working on: ", bamPath)
message("output will be written to: ", outFile)
message("Checking BamFile")
bamFile <- BamFile(here::here(bamPath))
stopifnot(file.exists(path(bamFile)))
message("Getting seqinfo and readParam")
sq <- seqinfo(bamFile)
sq <- GenomeInfoDb::sortSeqlevels(sq)
rp <- readParam(pe = "none", restrict = seqnames(sq)[1:5])
message("Calculating correlatiions")
read_corrs <- correlateReads(path(bamFile), param = rp)
message("Writing to ", outFile)
write_tsv(
	tibble(correlation = read_corrs, fl = seq_along(read_corrs)),
	outFile
)
message("Done")
