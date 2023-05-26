rule fastqc:
    input: 
        fq = os.path.join(fq_path, "{step}", "{accession}.fastq.gz"),
    output:
        html = os.path.join(fqc_path, "{step}", "{accession}_fastqc.html"),
        zip = os.path.join(fqc_path, "{step}", "{accession}_fastqc.zip"),
    params:
        extra = config['params']['fastqc']['extra'],
        outdir = os.path.join(fqc_path, "{step}")
    conda: "../envs/fastqc.yml"
    log: os.path.join("logs/fastqc", "{step}", "{accession}.log")
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
