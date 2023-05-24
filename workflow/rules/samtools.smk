rule samtools_sort:
    input:
         os.path.join(aln_path, "{accession}.bam"),
    output:
        os.path.join(aln_path, "{accession}.sorted.bam"),
    log:
        "logs/samtools_sort/{accession}.log",
    params:
        extra = config['params']['samtools']['sort'],
    threads: 8
    resources:
        runtime = "2h"  
    wrapper:
        "v1.31.1/bio/samtools/sort"

rule samtools_index:
    input:
        "{bam}.bam",
    output:
        "{bam}.bam.bai",
    log:
        os.path.join("logs/samtools_index", os.path.basename("{bam}.log")),
    params:
        extra = config['params']['samtools']['index'],
    threads: 6  # This value - 1 will be sent to -@
    resources:
        runtime = "30m"      
    wrapper:
        "v1.31.1/bio/samtools/index"