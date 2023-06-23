rule sort_bedgraph:
    input:
        bdg = "{file}.bdg",
    output:
        bdg = temp("{file}.sorted.bdg")
    log: "workflow/logs/sort_bedgraph/{file}.log"
    threads: 1
    resources:
        runtime = "1h",
        mem_mb = lambda wildcards, input, attempt: (input.size//1000000) * attempt * 8,
        disk_mb = lambda wildcards, input, attempt: (input.size//1000000) * attempt * 4,
    shell:
        """
        ## Sort the file
        echo -e "Started sorting at $(date)" >> {log}
        sort \
          -k1,1 -k2,2n \
          -S {resources.mem_mb}M \
          {input.bdg} | \
          egrep $'^chr[0-9XY]+\t' > {output.bdg}
        echo -e "Finished sorting at $(date)" >> {log}
        """	
    

rule bedgraph_to_bigwig:
    input:
        bedgraph = "{file}.sorted.bdg",
        chrom_sizes = chrom_sizes
    output:
        bigwig = "{file}.bw"
    conda: "../envs/bedgraph_to_bigwig.yml"
    log: "workflow/logs/bedgraph_to_bigwig/{file}.log"
    threads: 1
    resources:
        runtime = "3h",
        mem_mb = lambda wildcards, input, attempt: (input.size//1000000) * attempt * 8,
        disk_mb = lambda wildcards, input, attempt: (input.size//1000000) * attempt * 4,
    shell:
        """
        echo -e "Started conversion at $(date)" >> {log}
        bedGraphToBigWig {input.bedgraph} {input.chrom_sizes} {output.bigwig}
        echo -e "Finished conversion at $(date)" >> {log}
        """
