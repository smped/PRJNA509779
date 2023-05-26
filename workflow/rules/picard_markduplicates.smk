rule picard_markduplicates:
    input:
        bams = os.path.join(aln_path, "{accession}.sorted.bam"),
    output:
        bam = os.path.join(dedup_path, "{accession}.sorted.bam"),
        metrics = "output/markDuplicates/{accession}.metrics.txt",
    log:
        "logs/dedup_bam/{accession}.log",
    params:
        extra = config['params']['markduplicates'],
    resources:
        mem_mb=1024,
    wrapper:
        "v1.31.1/bio/picard/markduplicates"
