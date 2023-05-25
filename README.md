# prepareChIPs

This is a simple `snakemake` workflow for preparing ChIP-Seq data.
The steps implemented are:

1. Download raw fastq files from SRA
2. Trim and Filter raw fastq files
3. Align to the supplied genome
4. Deduplicate Alignments
5. Call Macs2 Peaks

Full details for each step are given below.

## Download Raw Data

The file `samples.tsv` is used to specify all steps for this workflow.
This file must contain the columns: `accession`, `target`, `treatment` and `input`

1. `accession` must be an SRA accession. Only single-end data is currently supported by this workflow
2. `target` defines the ChIP target. All files common to a target and treatment will be used to generate summarised coverage in bigWig Files
3. `treatment` defines the treatment group each file belongs to. If only one treatment exists, simply use the value 'control' or similar for every file
4. `input` should contain the accession for the relevant input sample. These will only be downloaded once. Valid input samples are required for this workflow

The example files provided are from the European Nucleotide Archive dataset [PRJNA509779](https://www.omicsdi.org/dataset/omics_ena_project/PRJNA509779).
These data files were generated in ZR-75-1 cells under Vehicle (E2) and DHT (E2+DHT) with antibodies targeting the Androgen Receptor (AR), the Estrogen Receptor (ER) and the histone mark H3K27ac.
All fastq files are 1x75bp

## Trim and Filter Reads

Read trimming is performed using [AdapterRemoval](https://adapterremoval.readthedocs.io/en/stable/).
Default settings are customisable using config.yml, with the defaults set to discard reads shorter than 50nt, and to trim using quality scores with a threshold of Q30.

## Align Reads

Alignment is performed using [`bowtie2`](https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml) and it is assumed that this index is available before running this workflow.
The path and prefix must be provided using config.yml

This index will also be used to produce the file `chrom.sizes` which is essential for conversion of bedGraph files to the more efficient bigWig files.

## Deduplicate Reads

Deduplication is performed using [MarkDuplicates](https://gatk.broadinstitute.org/hc/en-us/articles/360037052812-MarkDuplicates-Picard-) from the Picard set of tools.
By default, deduplication will remove the duplicates from the set of alignments.
All resultant bam files will be sorted and indexed.

## Peak Calling

This is performed using [`macs2 callpeak`](https://pypi.org/project/MACS2/).
