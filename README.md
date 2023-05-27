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