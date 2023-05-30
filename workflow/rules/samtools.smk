def get_mem_mb(wildcards, threads):
    return threads * 4096

rule samtools_sort:
    input:
         os.path.join(aln_path, "{accession}.bam"),
    output:
        os.path.join(aln_path, "{accession}.sorted.bam"),
    conda: "../envs/samtools.yml"
    log:
        "workflow/logs/samtools_sort/{accession}.log",
    params:
        sort = config['params']['samtools']['sort'],
        view = config['params']['samtools']['view']
    threads: 8
    resources:
        mem_mb = get_mem_mb,
        runtime = "2h"
    shell:
        """
        TEMPDIR=$(mktemp -d -t samXXXXXXXXXX)
        echo -e "Writing to $TEMPDIR" >>{log}

        samtools view {params.view} {input} |\
            samtools sort {params.sort} \
                -@ {threads} -m 4G \
                -T $TEMPDIR \
                -O BAM \
                -o {output} 2>> {log}

        echo -e "Deleting $TEMPDIR" >> {log}
        rm -rf $TEMPDIR
        """

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