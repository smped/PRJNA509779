# prepareChIPs

This is a simple `snakemake` workflow template for preparing single-end ChIP-Seq data.
The steps implemented are:

1. Download raw fastq files from SRA
2. Trim and Filter raw fastq files ()`AdapterRemoval`)
	+ `FastQC` and `MultiQC` will also be run on these files 
3. Align to the supplied genome ()`bowtie2`)
	+ Alignments will also be sorted
4. Deduplicate Alignments (`Picard MarkDuplicates`)
	+ These files will be indexed and sorted
5. Call Macs2 Peaks (`macs2`)

Full details for each step are given below.
Any additional parameters for tools can be specified using `config/config.yml`.

To run the workflow with default settings, simply run as follows (after editing `config/samples.tsv`)

```bash
snakemake --use-conda --cores 16
```

If running on an HPC cluster, a snakemake profile will required for submission to the queueing system and approrate resource allocation.
Please discuss this will your HPC support team.

Whilst no snakemake wrappers are explicitly used in this workflow, the underlying scripts are utilised where possible to minimise any issues with HPC clusters with restrictions on internet access.
These scripts are based on `v1.31.1` of the snakemake wrappers

## Download Raw Data

### Outline

The file `samples.tsv` is used to specify all steps for this workflow.
This file must contain the columns: `accession`, `target`, `treatment` and `input`

1. `accession` must be an SRA accession. Only single-end data is currently supported by this workflow
2. `target` defines the ChIP target. All files common to a target and treatment will be used to generate summarised coverage in bigWig Files
3. `treatment` defines the treatment group each file belongs to. If only one treatment exists, simply use the value 'control' or similar for every file
4. `input` should contain the accession for the relevant input sample. These will only be downloaded once. Valid input samples are *required* for this workflow

As some HPCs restrict internet access for submitted jobs, *it may be prudent to run the initial rules in an interactive session* if at all possible.
This can be performed using the following (with 2 cores provided as an example)

```bash
snakemake --use-conda --until get_fastq --cores 2
```

### Outputs

- Downloaded files will be gzipped and written to `data/fastq/raw`.
- `FastQC` and `MultiQC` will also be run, with output in `output/qc/raw`

## Read Filtering

### Outline

Read trimming is performed using [AdapterRemoval](https://adapterremoval.readthedocs.io/en/stable/).
Default settings are customisable using config.yml, with the defaults set to discard reads shorter than 50nt, and to trim using quality scores with a threshold of Q30.

### Outputs

- Trimmed fastq.gz files will be written to `data/fastq/trimmed`
- `FastQC` and `MultiQC` will also be run, with output in `output/qc/trimmed`
- AdapterRemoval 'settings' files will be written to `output/adapterremoval`

## Alignments

### Outline

Alignment is performed using [`bowtie2`](https://bowtie-bio.sourceforge.net/bowtie2/manual.shtml) and it is assumed that this index is available before running this workflow.
The path and prefix must be provided using config.yml

This index will also be used to produce the file `chrom.sizes` which is essential for conversion of bedGraph files to the more efficient bigWig files.

### Outputs

- Alignments will be written to `data/aligned`
- `bowtie2` log files will be written to `output/bowtie2`
- The file `chrom.sizes` will be written to `output/annotations`

Both sorted and the original unsorted alignments will be returned.
However, the unsorted alignments are marked with `temp()` and can be deleted using 

```bash
snakemake --delete-temp-output --cores 1
```

## Deduplication

### Outline

Deduplication is performed using [MarkDuplicates](https://gatk.broadinstitute.org/hc/en-us/articles/360037052812-MarkDuplicates-Picard-) from the Picard set of tools.
By default, deduplication will remove the duplicates from the set of alignments.
All resultant bam files will be sorted and indexed.

### Outputs

- Deduplicated alignments are written to `data/deduplicated` and are indexed
- DuplicationMetrics files are written to `output/markDuplicates`

## Peak Calling

### Outline

This is performed using [`macs2 callpeak`](https://pypi.org/project/MACS2/).

- Peak calling will be performed on a) each sample individually, and b) on merged samples for those sharing a common ChIP target and treatment group.
- Coverage bigWig files for each individual sample are produced using CPM values (i.e. Signal Per Million Reads, SPMR)
- For all combinations of target and treatment coverage bigWig files are also produced, along with fold-enrichment

### Outputs

- Individual outputs are written to `output/macs2/accession`
	+ Peaks are written in `narrowPeak` format along with `summits.bed`
	+ bedGraph files are automatically converted to bigWig files, and the originals are marked with `temp()` for subsequent deletion
	+ callpeak log files are also added to this directory
- Merged outputs are written to `output/macs2/target/treatment/`
	+ bedGraph Files are also converted to bigWig and marked with `temp()`
	+ Fold-Enrichment bigWig files are also created withe original bedGraph files marked with `temp()`
