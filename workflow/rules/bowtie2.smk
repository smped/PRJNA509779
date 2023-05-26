rule bowtie2_align:
    input:
        sample = [os.path.join(trim_path, "{accession}.fastq.gz")],
        idx = multiext(
            ref_pre,
            ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2"
        )
    output:
        temp(os.path.join(aln_path, "{accession}.bam"))
    conda: "../envs/bowtie2.yml"
    log:
        "output/bowtie2/{accession}.log",
    params:
        extra = config['params']['bowtie2'],
    threads: 8  
    script:
        "../scripts/bowtie2.py"

rule get_chrom_sizes:
    input:
        idx = multiext(
            ref_pre,
            ".1.bt2", ".2.bt2", ".3.bt2", ".4.bt2", ".rev.1.bt2", ".rev.2.bt2"
        )
    output:
        chrom_sizes
    params:
        ref = ref_pre,
    log:
        "workflow/logs/bowtie2/get_chrom_sizes.log"
    threads: 1
    conda: "../envs/bowtie2.yml"
    shell:
        """
        DIR=$(dirname {output})
        if [[ ! -d $DIR ]]; then
            mkdir -p $DIR
        fi
        
        bowtie2-inspect --summary {params.ref} | \
          egrep '^Sequence' | \
          sed -r 's/ /\\t/g' | \
          cut -f2,4 > {output}
        """
