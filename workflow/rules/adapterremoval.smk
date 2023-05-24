rule adapterremoval:
    input:
        sample = os.path.join(raw_path, "{accession}.fastq.gz")
    output:
        fastq = os.path.join(trim_path, "{accession}.fastq.gz"), 
        discarded = os.path.join(trim_path, "{accession}.discarded.fastq.gz"),
        settings = "output/adapterremoval/{accession}.settings" 
    log:
        "logs/adapterremoval/{accession}.log"
    params:
        adapters = config['params']['adapterremoval']['adapter1'],
        extra = config['params']['adapterremoval']['extra']
    threads: 2
    resources:
        runtime = "1h"  
    wrapper:
        "v1.31.1/bio/adapterremoval"
