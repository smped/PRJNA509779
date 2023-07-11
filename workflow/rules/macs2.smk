def get_treat_bam(wildcards):
    ind = (df.treatment == wildcards.treat) & (df.target == wildcards.target)
    samples = set(df[ind]['accession'])
    bam = expand(
        os.path.join(dedup_path, "{f}.bam"),
        f = samples
    )
    return(bam)

def get_treat_bai(wildcards):
    ind = (df.treatment == wildcards.treat) & (df.target == wildcards.target)
    samples = set(df[ind]['accession'])
    bai = expand(
        os.path.join(dedup_path, "{f}.bam.bai"),
        f = samples
    )
    return(bai)

def get_treat_input(wildcards):
    ind = (df.treatment == wildcards.treat) & (df.target == wildcards.target)
    samples = set(df[ind]['input'])
    bam = expand(
        os.path.join(dedup_path, "{f}.bam"),
        f = samples
    )
    return(bam)

def get_treat_input_bai(wildcards):
    ind = (df.treatment == wildcards.treat) & (df.target == wildcards.target)
    samples = set(df[ind]['input'])
    bai = expand(
        os.path.join(dedup_path, "{f}.bam.bai"),
        f = samples
    )
    return(bai)

rule macs2_callpeak:
    input:
        bam = os.path.join(dedup_path, "{sample}.bam"),  
        bai = os.path.join(dedup_path, "{sample}.bam.bai"),  
        control = lambda wildcards: expand(
            os.path.join(dedup_path, "{input}.bam"),
            input = df[df.accession == wildcards.sample]['input']
        ),
        control_bai = lambda wildcards: expand(
            os.path.join(dedup_path, "{input}.bam.bai"),
            input = df[df.accession == wildcards.sample]['input']
        )
    output:
        files = multiext(
            os.path.join(macs2_path, "{sample}", "{sample}_"),
            "peaks.xls", "peaks.narrowPeak", "summits.bed", "model.r"
        ),
        bdg = temp(
            multiext(
                os.path.join(macs2_path, "{sample}", "{sample}_"),
                "control_lambda.bdg", "treat_pileup.bdg"
            )      
        ),
        log = os.path.join(macs2_path, "{sample}", "{sample}_callpeak.log")
    conda: "../envs/macs2.yml"
    params:
        extra = config['params']['macs2']['callpeak'],
        prefix = "{sample}",
        outdir = os.path.join(macs2_path, "{sample}")
    log:
        "workflow/logs/macs2_callpeak/{sample}_callpeak.log"
    threads: 1
    resources:
        mem_mb = 16384,
        runtime = "1h",
    shell:
        """
        macs2 callpeak \
            -t {input.bam}\
            -c {input.control} \
            -f BAM --bdg --SPMR \
            {params.extra} \
            -n {params.prefix} \
            --outdir {params.outdir} 2> {log}
        cp {log} {output.log}
        """

rule macs2_callpeak_merged:
    input:
        bam = get_treat_bam,
        bai = get_treat_bai,
        control = get_treat_input,
        control_bai = get_treat_input_bai
    output:
        files = multiext(
            os.path.join(macs2_path, "{target}", "{treat}_merged_"),
            "peaks.xls", "peaks.narrowPeak", "summits.bed", "model.r"
        ),
        bdg = temp(
            multiext(
                os.path.join(macs2_path, "{target}", "{treat}_merged_"),
                "control_lambda.bdg", "treat_pileup.bdg"
            )
        ),
        log = os.path.join(macs2_path, "{target}", "{treat}_merged_callpeak.log")
    conda: "../envs/macs2.yml"        
    log:
        "workflow/logs/macs2_callpeak/{target}_{treat}_merged_callpeak.log"
    params:
        extra = config['params']['macs2']['callpeak'],
        prefix = "{treat}_merged",
        outdir = os.path.join(macs2_path, "{target}")
    threads: 1
    resources:
        mem_mb = 8192,
        runtime = "1h"
    shell:
        """
        macs2 callpeak \
            -t {input.bam}\
            -c {input.control} \
            -f BAM --bdg --SPMR \
            {params.extra} \
            -n {params.prefix} \
            --outdir {params.outdir} 2> {log}
        cp {log} {output.log}
        """

rule macs2_bdgcmp_merged:
    input:
        treatment = os.path.join(
            macs2_path, "{target}/{treat}_merged_treat_pileup.bdg"
        ),
        control = os.path.join(
            macs2_path, "{target}/{treat}_merged_control_lambda.bdg"
        )
    output:
        temp(
            expand(
                os.path.join(macs2_path, "{{target}}/{{treat}}_{type}.bdg"),
                type = bdgcmp_type
            )
        )
    params:
        config['params']['macs2']['bdgcmp']
    log:
        "workflow/logs/macs2_bdgcmp/{target}_{treat}_bdgcmp.log"
    conda: "../envs/macs2.yml"
    threads: 1
    resources:
        mem_mb = 16384,
        runtime = "3h"
    shell:
        """
        macs2 bdgcmp \
            -t {input.treatment} \
            -c {input.control} \
            {params} \
            -o {output} 2> {log}
        """

rule check_callpeak_logs:
    input: 
        log = "{file}_callpeak.log",
        script = "workflow/scripts/check_callpeak_logs.R"
    output: temp("{file}_callpeak.chk")
    threads: 1
    log: "workflow/logs/check_callpeak_logs/{file}.log"
    conda: "../envs/rmarkdown.yml"
    resources:
        mem_mb = 1024,
        runtime = "5m"
    shell:
        """
        Rscript --vanilla {input.script} {input.log} {output}  >> {log} 2>&1
        """