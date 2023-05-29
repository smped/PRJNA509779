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
		runtime = "5m"
	shell:
		"""
		R -e "rmarkdown::render_site('{input.rmd}')" &>> {log}
		"""