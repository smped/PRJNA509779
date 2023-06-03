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
            {output} >> {log} 2>&1
        """

rule get_frip:
    input:
        bam = os.path.join(dedup_path, "{sample}.sorted.bam"),
        bai = os.path.join(dedup_path, "{sample}.sorted.bam.bai"),
        peaks = os.path.join(
            macs2_path, "{sample}", "{sample}_peaks.narrowPeak"
        ),
        script = "workflow/scripts/get_frip.R"
    output:
        os.path.join(macs2_path, "{sample}", "{sample}_frip.tsv")
    conda: "../envs/rmarkdown.yml"
    log: "workflow/logs/frip/{sample}.log"
    threads: 1
    resources:
        runtime = "30m",
        mem_mb = "4096"
    shell:
        """
        Rscript --vanilla \
            {input.script} \
            {input.peaks} \
            {input.bam} \
            {output} >> {log} 2>&1
        """ 
