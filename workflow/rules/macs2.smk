rule macs2_callpeak:
    input:
        treatment = os.path.join(dedup_path, "{sample}.sorted.bam"),  
        control = lambda wildcards: expand(
            os.path.join(dedup_path, "{input}.sorted.bam"),
            input = set(df[df.accession == wildcards.sample]['input'])
        ),
        bai_treatment = os.path.join(dedup_path, "{sample}.sorted.bam.bai"),  
        bai_control = lambda wildcards: expand(
            os.path.join(dedup_path, "{input}.sorted.bam.bai"),
            input = set(df[df.accession == wildcards.sample]['input'])
        )
    output:
        multiext(
            os.path.join(macs2_path, "{sample}_"),
            "peaks.xls", "peaks.narrowPeak", "summits.bed", "model.r",
            "control_lambda.bdg", "treat_pileup.bdg"
        )
    log:
        "logs/macs2/{sample}_callpeak.log"
    params:
        config['params']['macs2']['callpeak']
    threads: 1
    resources:
        mem_mb = 8192,
        runtime = "2h"
    wrapper:
        "v1.31.1/bio/macs2/callpeak"
