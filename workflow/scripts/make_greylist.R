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
bam <- args[[1]]
chrom_sizes <- args[[2]]
genome <- args[[3]]
bed <- args[[4]]

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