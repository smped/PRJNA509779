[![DOI](https://zenodo.org/badge/646152412.svg)](https://zenodo.org/badge/latestdoi/646152412)

# PRJNA509779

This repository is an execution of the [prepareChiPS](https://github.com/smped/prepareChIPs) workflow on the BioProject [PRJNA509779](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA509779&o=acc_s%3Aa).
The SraRunTable was downloaded from the given link and converted to `PRJNA509779.tsv` using the following code.
This file was then used to supply all parameters for the snakemake workflow.

```r
library(readr)
library(dplyr)
here::here("config/SraRunTable.txt") %>%
	read_csv() %>%
	mutate(
		target = gsub("([^ ]+) .+", "\\1", ChIP_antibody),
		Treatment = gsub("\\+", "", Treatment),
		input = "SRR8315192"
	) %>%
	dplyr::filter(target != "Input") %>%
	dplyr::select(
		accession = Run, target, treatment = Treatment, input, 
		Cell_Line, `Sample Name`, Experiment, source_name
	) %>%
	write_tsv(
		here::here("config/PRJNA509779.tsv")
	)
```

Before running this on a slurm HPC cluster, be sure to include a suitable size request for the temporary directory (>10G) in your config file.
If this is not set clearly, some clusters may limit the size of this directory and `macs2 callpeak` will appear to complete without throwing any errors, *despite multiple Exceptions being thrown* internally.
These will be visible in the callpeak.log files.

## Note for OSX Users

It should be noted that this workflow is currently incompatible with OSX-based systems.
There are two incompatibilities.

1. `fasterq-dump` has a bug which is specific to conda environments. This has been updated in SRA tools v3.0.3 but this patch has not yet been made available to `conda` environments for OSX.
2. An intermittent glitch appears in OSX-based R sessions, namely
```
Error in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y,  : 
  polygon edge not found
```
The fix for this is currently undefined
