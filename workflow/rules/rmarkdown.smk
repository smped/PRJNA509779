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
	