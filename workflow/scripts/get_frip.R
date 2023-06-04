#' Set the .libPaths() first in case there are conflicts in a conda environment
cat("Setting .libPaths()\n")
conda_pre <- system2("echo", "$CONDA_PREFIX", stdout = TRUE)
if (conda_pre != "") {
  conda_lib_path <- file.path(conda_pre, "lib", "R", "library")
  if (!dir.exists(conda_lib_path)) conda_lib_path <- NULL
  prev_paths <- .libPaths()
  paths_to_set <- unique(c(conda_lib_path, prev_paths))
  .libPaths(paths_to_set)
}

library(Rsamtools)
library(GenomicAlignments)
library(readr)
library(tibble)
library(extraChIPs)

args <- commandArgs(TRUE)
peakFile <- here::here(args[[1]])
bamFile <- here::here(args[[2]])
outFile <- here::here(args[[3]])

stopifnot(file.exists(peakFile))
stopifnot(file.exists(bamFile))
cat("\nPeaks will be loaded from:\n", peakFile)
cat("\nAlignments will be read from:\n", bamFile)
cat("\nFRIP will be written to:\n", outFile)

cat("\nImporting peaks...\n")
peaks <- unlist(importPeaks(peakFile))
names(peaks) <- NULL
cat("\nReading Alignments...\n")
al <-  readGAlignments(bamFile, param = ScanBamParam(which = peaks))
tbl <- tibble(
	file = basename(bamFile),
	total_reads = sum(idxstatsBam(bamFile)$mapped),
	reads_in_peaks = length(al),
	frip = reads_in_peaks / total_reads
)
cat("\nWriting FRIP to ", outFile)
write_tsv(tbl, outFile)
cat("\nDone")