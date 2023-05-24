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

The example files provided are from the European Nucleotide Archive dataset [PRJNA509779](https://www.omicsdi.org/dataset/omics_ena_project/PRJNA509779).
These data files were generated in ZR-75-1 cells under Vehicle (E2) and DHT (E2+DHT) with antibodies targeting the Androgen Receptor (AR), the Estrogen Receptor (ER) and the histone mark H3K27ac.
All fastq files are 1x75bp

## Trim and Filter Reads

## Align Reads

## Deduplicate Reads

## Peak Calling