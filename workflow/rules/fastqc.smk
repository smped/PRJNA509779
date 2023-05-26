rule fastqc:
    input: 
        fq = os.path.join(fq_path, "{step}", "{accession}.fastq.gz"),
    output:
        html = os.path.join(qc_path, "{step}", "{accession}_fastqc.html"),
        zip = os.path.join(qc_path, "{step}", "{accession}_fastqc.zip"),
    params:
        extra = config['params']['fastqc'],
        outdir = os.path.join(qc_path, "{step}")
    conda: "../envs/fastqc.yml"
    log: "workflow/logs/fastqc/{step}/{accession}.log"
    threads: 4
    resources:
        runtime="2h"
    shell:
        """
        fastqc \
          {params.extra} \
          -t {threads} \
          --outdir {params.outdir} \
          {input.fq} &> {log}
        """
