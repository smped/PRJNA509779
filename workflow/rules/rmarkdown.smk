rule create_site_yaml:
	input: 
		config['samples']
	output: 
		"analysis/_site.yml"
	threads: 1
	log: "workflow/logs/create_site_yaml.log"
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
	log: "workflow/logs/compile_index_html"
	resources:
		runtime = "10m"
	shell:
		"""
		R -e "rmarkdown::render_site('{input.rmd}')" &>> {log}
		"""

rule compile_qc_html:
	input:
		fqc = expand(
			os.path.join("output", "qc", "{{step}}", "{f}_fastqc.{suffix}"),
			f = accessions, suffix = ['zip', 'html']
		),
		references = "analysis/references.bib",
		rmd = "analysis/{step}_qc.Rmd",
		site = "analysis/_site.yml",
		yaml = "config/config.yml"		
	output:
		html = "docs/{step}_qc.html"
	threads: 1
	conda: "../envs/rmarkdown.yml"
	log: "workflow/logs/compile_{step}_qc_ html"
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
	log: "workflow/logs/compile_align_qc_ html"
	resources:
		runtime = "5m"
	shell:
		"""
		R -e "rmarkdown::render_site('{input.rmd}')" &>> {log}
		"""		

rule create_macs2_summary:
	input:
		rmd = "analysis/_macs2_summary.Rmd"
	output:
		rmd = "analysis/{target}_macs2_summary.Rmd"
	threads: 1
	resources:
		runtime = "1m"
	shell:
		"""
		echo -e "---" >> {output.rmd}
		echo -e "title: {wildcards.target}: MACS2 Summary" >> {output.rmd}
		echo -e "date: \"`r format(SysDate(), '%d %B, %Y')`\"" >> {output.rmd}
		echo -e "bibliography: references.bib"  >> {output.rmd}
		echo -e "link-citations: true" >> {output.rmd}
		echo -e "---\\n\\n" >> {output.rmd}
		echo -e "```{{r set-target}}"
		echo -e "target <- {wildcards.target}"
		echo -e "```\\n"

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
			f = ['callpeak.log', 'peaks.narrowPeak'],
			accession = set(df[df.target == wildcards.target]['accession'])
		),
		yml = "analysis/_site.yml"
	output:
		html = "docs/{target}_macs2_summary.html"
	threads: 1
	conda: "../envs/rmarkdown.yml"
	log: "workflow/logs/compile_{target}_macs2_summary.log"
	resources:
		runtime = "20m"
	shell:
		"""
		R -e "rmarkdown::render_site('{input.rmd}')" &>> {log}
		"""		