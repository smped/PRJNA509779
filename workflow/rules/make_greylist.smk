rule make_greylist:
  input:
    bam = os.path.join(dedup_path, "{accession}.sorted.bam"),
    bai = os.path.join(dedup_path, "{accession}.sorted.bam.bai"),
    chrom_sizes = chrom_sizes,
    script = "workflow/scripts/make_greylist.R"
  output:
    greylist = os.path.join("output", "annotations", "{accession}_greylist.bed")
  params:
    genome = config['reference']['name']
  conda: "../envs/greylist.yml"
  threads: 1
  log: "workflow/logs/make_greylist/{accession}.log"
  resources:
    runtime = "40m",
    mem_mb = "8192"
  shell:
    """
    Rscript --vanilla \
      {input.script} \
      {input.bam} \
      {input.chrom_sizes} \
      {params.genome} \
      {output.greylist} >> {log} 2>&1
    """

