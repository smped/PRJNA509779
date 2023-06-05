rule make_greylist:
  input:
    bam = os.path.join(dedup_path, "{accession}.sorted.bam"),
    bai = os.path.join(dedup_path, "{accession}.sorted.bam.bai"),
    chrom_sizes = os.path.join("output", "annotations", chrom.sizes),
    script = "workflow/scripts/make_greylist.R"
  output:
    greylist = os.path.join(macs2_path, "{accession}", "{accession}_greylist.bed")
  params:
    genome = config['reference']['name']
  conda: "../envs/greylist.yml"
  threads: 1
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
      {output.greylist}
    """

