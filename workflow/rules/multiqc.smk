rule multiqc:
    input:
        expand(
            os.path.join(qc_path, "{{step}}", "{accession}_fastqc.zip"),
            accession = accessions
        )
    output:
        os.path.join(qc_path, "{step}", "multiqc.html")
    conda: "../envs/multiqc.yml"
    threads: 1
    params:
        extra = config['params']['multiqc'],
        outdir = os.path.join(qc_path, "{step}")
    log: "workflow/logs/multiqc/{step}_multiqc.log"
    shell:
        """
        multiqc \
          {params.extra} \
          --force \
          -o {params.outdir} \
          -n multiqc.html \
          {input} 2> {log}
        """
    