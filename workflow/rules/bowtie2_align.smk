rule bowtie2_align:
    input:
        sample = os.path.join(trim_path, "{accession}.fastq.gz"),
        idx = multiext(
            os.path.join(
				config['reference']['path'], config['reference']['index']
			),
            ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2",
            ".rev.1.bt2", ".rev.2.bt2"
        )
    output:
        temp(os.path.join(aln_path, "{accession}.bam"))
    log:
        "logs/bowtie2/{accession}.log",
    params:
        extra = config['params']['bowtie2']['extra'],
    threads: 8  
    wrapper:
        "v1.31.1/bio/bowtie2/align"