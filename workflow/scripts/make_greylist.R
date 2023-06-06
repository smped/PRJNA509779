conda_pre <- system2("echo", "$CONDA_PREFIX", stdout = TRUE)
if (conda_pre != "") {
  conda_lib_path <- file.path(conda_pre, "lib", "R", "library")
  if (!dir.exists(conda_lib_path)) conda_lib_path <- NULL
  prev_paths <- .libPaths()
  paths_to_set <- unique(c(conda_lib_path, prev_paths))
  .libPaths(paths_to_set)
}

library(GreyListChIP)

args <- commandArgs(TRUE)
bam <- here::here(args[[1]])
chrom_sizes <- here::here(args[[2]])
genome <- args[[3]]
bed <- here::here(args[[4]])

## Example code for running interactively
# bam <- here::here("data/deduplicated/SRR8315192.sorted.bam")
# chrom_sizes <- here::here("output/annotations.chrom.sizes")
# genome <- "GRCh37"
# bed <- here::here("output/macs2/SRR8315192/SRR8315192_greylist.bed")

df <- read.table(chrom_sizes)
colnames(df) <- c("seqnames", "seqlengths")
df$isCircular <- FALSE
df$genome <- genome
sq <- as(df, "Seqinfo")

## This is set for only a single input file
gl <- new("GreyList", karyotype = sq)
cat("Counting reads in ", bam, "...\n")
gl <- countReads(gl, bam)
cat("Calculating thresholds...\n")
set.seed(100)
gl <- calcThreshold(gl)
cat("Making greylist...\n")
gl <- makeGreyList(gl)
cat("Writing to ", bed, "\n")
export(gl, bed)
cat("done\n")
