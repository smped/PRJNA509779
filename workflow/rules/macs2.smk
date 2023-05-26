def get_treat_bam(wildcards):
    ind = (df.treatment == wildcards.treat) & (df.target == wildcards.target)
    samples = set(df[ind]['accession'])
    bam = expand(
        os.path.join(dedup_path, "{f}.sorted.bam"),
        f = samples
    )
    return(bam)

def get_treat_bai(wildcards):
    ind = (df.treatment == wildcards.treat) & (df.target == wildcards.target)
    samples = set(df[ind]['accession'])
    bai = expand(
        os.path.join(dedup_path, "{f}.sorted.bam.bai"),
        f = samples
    )
    return(bai)

def get_treat_input(wildcards):
    ind = (df.treatment == wildcards.treat) & (df.target == wildcards.target)
    samples = set(df[ind]['input'])
    bam = expand(
        os.path.join(dedup_path, "{f}.sorted.bam"),
        f = samples
    )
    return(bam)

def get_treat_input_bai(wildcards):
    ind = (df.treatment == wildcards.treat) & (df.target == wildcards.target)
    samples = set(df[ind]['input'])
    bai = expand(
        os.path.join(dedup_path, "{f}.sorted.bam.bai"),
        f = samples
    )
    return(bai)

rule macs2_callpeak:
    input:
        bam = os.path.join(dedup_path, "{sample}.sorted.bam"),  
        bai = os.path.join(dedup_path, "{sample}.sorted.bam.bai"),  
        control = lambda wildcards: expand(
            os.path.join(dedup_path, "{input}.sorted.bam"),
            input = df[df.accession == wildcards.sample]['input']
        ),
        control_bai = lambda wildcards: expand(
            os.path.join(dedup_path, "{input}.sorted.bam.bai"),
            input = df[df.accession == wildcards.sample]['input']
        )
    output:
        files = multiext(
            os.path.join(macs2_path, "{sample}_"),
            "peaks.xls", "peaks.narrowPeak", "summits.bed", "model.r"
        ),
        bdg = temp(
            multiext(
                os.path.join(macs2_path, "{sample}_"),
                "control_lambda.bdg", "treat_pileup.bdg"
            )      
        ),
        log = os.path.join(macs2_path, "{sample}_callpeak.log")
    conda: "../envs/macs2.yml"
    log: 
        "logs/macs2_callpeak/{sample}_callpeak.log"
    params:
        extra = config['params']['macs2']['callpeak'],
        prefix = "{sample}",
        outdir = macs2_path
    threads: 1
    resources:
        mem_mb = 8192,
        runtime = "2h",
    shell:
        """
        echo -e "Running macs2 call peak on:\n{input.bam}" >> {log}
        echo -e "The specified control sample is:\n{input.control}" >> {log}
        macs2 callpeak \
            -t {input.bam}\
            -c {input.control} \
            -f BAM --bdg --SPMR \
            {params.extra} \
            -n {params.prefix} \
            --outdir {params.outdir} 2> {output.log}
        """

rule macs2_call_peak_merged:
    input:
        bam = get_treat_bam,
        bai = get_treat_bai,
        control = get_treat_input,
        control_bai = get_treat_input_bai
    output:
        files = multiext(
            os.path.join(macs2_path, "{target}_{treat}_merged_"),
            "peaks.xls", "peaks.narrowPeak", "summits.bed", "model.r"
        ),
        bdg = temp(
            multiext(
                os.path.join(macs2_path, "{target}_{treat}_merged_"),
                "control_lambda.bdg", "treat_pileup.bdg"
            )
        ),
        log = os.path.join(macs2_path, "{target}_{treat}_merged_callpeak.log")
    conda: "../envs/macs2.yml"        
    log:
        "logs/macs2_callpeak/{target}/{treat}_merged_callpeak.log"
    params:
        extra = config['params']['macs2']['callpeak'],
        prefix = "{target}_{treat}",
        outdir = macs2_path
    threads: 1
    resources:
        mem_mb = 8192,
        runtime = "2h"
    shell:
        """
        echo -e "Running macs2 call peak on:\n{input.bam}" >> {log}
        echo -e "The specified control sample is:\n{input.control}" >> {log}
        macs2 callpeak \
            -t {input.bam}\
            -c {input.control} \
            -f BAM --bdg --SPMR \
            {params.extra} \
            -n {params.prefix} \
            --outdir {params.outdir} 2> {output.log}
        """

rule macs2_bdgcmp_merged:
    input:
        treatment = os.path.join(
            macs2_path, "{target}_{treat}_merged_treat_pileup.bdg"
        ),
        control = os.path.join(
            macs2_path, "{target}_{treat}_merged_control_lambda.bdg"
        )
    output:
        temp(
            expand(
                os.path.join(macs2_path, "{{target}}_{{treat}}_{type}.bdg"),
                type = bdgcmp_type
            )
        )
    params:
        config['params']['macs2']['bdgcmp']
    log:
        "logs/macs2_bdgcmp/{target}/{treat}_bdgcmp.log"
    conda: "../envs/macs2.yml"
    threads: 1
    resources:
        mem_mb = 8192,
        runtime = "1h"
    shell:
        """
        macs2 bdgcmp \
            -t {input.treatment} \
            -c {input.control} \
            {params} \
            -o {output} 2> {log}
        """


rule bedgraph_to_bigwig:
    input:
        bedgraph = "{file}.bdg",
        chrom_sizes = chrom_sizes
    output:
        bigwig = "{file}.bw"
    conda: "../envs/bedgraph_to_bigwig.yml"
    log: "logs/bedgraph_to_bigwig/{file}.log"
    threads: 1
    resources:
        runtime = "2h",
        mem_mb = 8192
    shell:
        """
        echo -e "\nConverting {input.bedgraph} to BigWig\n" >> {log}
        TEMPDIR=$(mktemp -d -t bdgXXXXXXXXXX)
        SORTED_BDG=$TEMPDIR/temp.bdg

        ## Sort the file
        echo -e "\nSorting as $SORTED_BDG..." >> {log}
        sort -k1,1 -k2,2n {input.bedgraph} | egrep $'^chr[0-9XY]+\t' > $SORTED_BDG

        ## Convert the file
        echo -e "Done\nConverting..." >> {log}
        bedGraphToBigWig $SORTED_BDG {input.chrom_sizes} {output.bigwig}
        echo -e "Done" >> {log}

        ## Remove the temp sorted file
        rm -rf $TEMPDIR
        """
