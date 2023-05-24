rule get_fastq:
    output:
        os.path.join(raw_path, "{accession}.fastq.gz")
    log:
        "logs/fasterq-dump/{accession}.fastq.gz.log"
    params:
        extra="--skip-technical"
    threads: 2
    resources:
        runtime = "2h"    
    wrapper:
        "v1.31.1/bio/sra-tools/fasterq-dump"


