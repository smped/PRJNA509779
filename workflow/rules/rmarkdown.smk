rule create_site_yaml:
    input: 
        config['samples']
    output: 
        "analysis/_site.yml"
    threads: 1
    log: "workflow/logs/rmd/create_site_yaml.log"
    conda: "../envs/rmarkdown.yml"
    resources:
        runtime = "5m"
    script:
        "../scripts/create_site_yaml.R"

rule compile_index_html:
    input:
        macs2_html = expand(
            "docs/{target}_macs2_summary.html", target = targets
        ),
        qc_html = expand("docs/{f}_qc.html", f = ['raw', 'trimmed', 'align']),
        references = "analysis/references.bib",
        rmd = "analysis/index.Rmd",
        samples = config['samples'],
        site = "analysis/_site.yml",
        yaml = "config/config.yml"
    output:
        html = "docs/index.html"
    threads: 1
    conda: "../envs/rmarkdown.yml"
    log: "workflow/logs/rmd/compile_index_html.log"
    resources:
        runtime = "10m"
    shell:
        """
        R -e "rmarkdown::render_site('{input.rmd}')" &>> {log}
        """

rule compile_qc_html:
    input:
        fqc = expand(
            os.path.join(qc_path, "{{step}}", "{f}_fastqc.{suffix}"),
            f = accessions, suffix = ['zip', 'html']
        ),
        multiqc = os.path.join(qc_path, "{step}", "multiqc.html"),
        references = "analysis/references.bib",
        rmd = "analysis/{step}_qc.Rmd",
        site = "analysis/_site.yml",
        yaml = "config/config.yml"		
    output:
        html = "docs/{step}_qc.html"
    threads: 1
    conda: "../envs/rmarkdown.yml"
    log: "workflow/logs/rmd/compile_{step}_qc_html.log"
    resources:
        runtime = "10m"
    shell:
        """
        R -e "rmarkdown::render_site('{input.rmd}')" &>> {log}
        """

rule compile_alignment_qc_html:
    input:
        bwt2_logs = expand(
            os.path.join("output", "bowtie2", "{f}.log"), f = accessions
        ),
        dup_logs = expand(
            os.path.join("output", "markDuplicates", "{f}.metrics.txt"),
            f = accessions
        ),
        references = "analysis/references.bib",
        rmd = "analysis/align_qc.Rmd",
        site = "analysis/_site.yml",
        yaml = "config/config.yml"
    output:
        html = "docs/align_qc.html"
    conda: "../envs/rmarkdown.yml"
    log: "workflow/logs/rmd/compile_align_qc_html.log"
    resources:
        runtime = "5m"
    shell:
        """
        R -e "rmarkdown::render_site('{input.rmd}')" &>> {log}
        """		

rule create_macs2_summary:
    input:
        r = "workflow/scripts/create_macs2_summary.R",
        rmd = "analysis/_macs2_summary.Rmd"
    output:
        rmd = "analysis/{target}_macs2_summary.Rmd"
    threads: 1
    resources:
        runtime = "1m"
    conda: "../envs/rmarkdown.yml"
    log: "workflow/logs/rmd/create_{target}_macs2_summary.log"
    shell:
        """
        ## Create the generic markdown
        Rscript --vanilla \
            {input.r} \
            {wildcards.target} \
            {output.rmd} &>> {log}

        ## Add the module directly as literal code
        cat {input.rmd} >> {output.rmd}
        """

rule compile_macs2_summary:
    input:
        chrom_sizes = chrom_sizes,
        rmd = "analysis/{target}_macs2_summary.Rmd",
        merged = lambda wildcards: expand(
            os.path.join(macs2_path, "{{target}}", "{treat}_merged_{f}"),
            f = ['callpeak.log', 'peaks.narrowPeak'],
            treat = set(df[df.target == wildcards.target]['treatment'])
        ),
        individual = lambda wildcards: expand(
            os.path.join(macs2_path, "{accession}", "{accession}_{f}"),
            f = [
                'callpeak.log', 'peaks.narrowPeak', 'cross_correlations.tsv',
                'frip.tsv'
            ],
            accession = set(df[df.target == wildcards.target]['accession'])
        ),
        yml = "analysis/_site.yml"
    output:
        html = "docs/{target}_macs2_summary.html"
    threads: 1
    conda: "../envs/rmarkdown.yml"
    log: "workflow/logs/rmd/compile_{target}_macs2_summary.log"
    resources:
        runtime = "20m"
    shell:
        """
        R -e "rmarkdown::render_site('{input.rmd}')" &>> {log}
        """
