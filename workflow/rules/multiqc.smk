rule multiqc:
    input:
        expand(
            os.path.join(fqc_path, "{{step}}", "{accession}_fastqc.zip"),
            accession = accessions
        )
    output:
        os.path.join(fqc_path, "{step}", "multiqc.html")
    threads: 1
    params:
        extra = ""
    log:
        "logs/{step}_multiqc.log"
    wrapper:
        "v1.31.1/bio/multiqc"
    