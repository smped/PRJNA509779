rule samtools_sort:
    input:
         os.path.join(aln_path, "{accession}.bam"),
    output:
        os.path.join(aln_path, "{accession}.sorted.bam"),
    conda: "../envs/samtools.yml"
    log:
        "workflow/logs/samtools_sort/{accession}.log",
    params:
        extra = config['params']['samtools']['sort'],
    threads: 8
    resources:
        runtime = "2h"
    script: "../scripts/samtools_sort.py"

rule samtools_index:
    input:
        "{bam}.bam",
    output:
        "{bam}.bam.bai",
    conda: "../envs/samtools.yml"
    params:
        extra = config['params']['samtools']['index'],
    threads: 6  
    resources:
        runtime = "30m"      
    shell:
        """
        samtools index -@ {threads} {input} {output}
        """