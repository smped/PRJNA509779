rule adapterremoval:
    input:
        sample = os.path.join(raw_path, "{accession}.fastq.gz")
    output:
        fastq = os.path.join(trim_path, "{accession}.fastq.gz"), 
        settings = "output/adapterremoval/{accession}.settings" 
    conda: "../envs/adapterremoval.yml"
    log:
        "workflow/logs/adapterremoval/{accession}.log"
    params:
        adapters = config['params']['adapterremoval']['adapter1'],
        extra = config['params']['adapterremoval']['extra']
    threads: 2
    resources:
        runtime = "1h"  
    shell:
        """
        AdapterRemoval \
            --file1 {input.sample} \
            {params.extra} \
            {params.adapters} \
            --threads {threads} \
            --output1 {output.fastq} \
            --discarded /dev/null \
            --settings {output.settings} &> {log}
        """

