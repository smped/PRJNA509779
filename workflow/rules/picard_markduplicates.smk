rule markduplicates:
    input:
        bams = os.path.join(aln_path, "{sample}.bam"),
    output:
        bam = os.path.join(dedup_path, "{sample}.bam"),
        metrics = "output/markDuplicates/{sample}.metrics.txt",
    log:
        "logs/dedup_bam/{sample}.log",
    params:
        extra = config['params']['markduplicates']['extra'],
    resources:
        mem_mb=1024,
    wrapper:
        "v1.31.1/bio/picard/markduplicates"
