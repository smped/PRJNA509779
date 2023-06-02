rule get_cross_correlations:
    input:
        bam = os.path.join(dedup_path, "{sample}.sorted.bam"),
        bai = os.path.join(dedup_path, "{sample}.sorted.bam.bai"),
        script = "workflow/scripts/cross_correlations.R"
    output:
        os.path.join(
            macs2_path, "{sample}", "{sample}_cross_correlations.tsv"
        )
    conda: "../envs/rmarkdown.yml"
    log: "workflow/logs/cross_correlations/{sample}.log"
    threads: 1
    resources:
        runtime = "30m",
        mem_mb = "4096"
    shell:
        """
        Rscript --vanilla \
            {input.script} \
            {input.bam} \
            {output} &>> {log}
        """