
rule all:
    input:
        metaphlan="results/Metaphlan/{sample}_profile.txt",
        resistome="results/Resistome/{sample}_resistome.txt",
        mobilome="results/Mobilome/{sample}_mobilome.txt",
    output:
        "results/{sample}_finallog.txt",
    shell:
        """
        echo "metaphlan run" >> {output}
        echo "resistome run" >> {output}
        echo "mobilome run" >> {output}
        """

##### workflow starts here

rule concat:
    input:
        f1="input/{sample}_1.fastq.gz",
        f2="input/{sample}_2.fastq.gz",
    params:
        gunZ="input/{sample}_concat.fastq.gz",
    output:
        "input/{sample}_concat.fastq",
    shell:
        """
        cat {input.f1} {input.f2} >> {params.gunZ}
        gunzip {params.gunZ}
        """

rule Metaphlan:
    input:
        concat="input/{sample}_concat.fastq",
    params:
        outdir="results/Metaphlan",
        database="databases",
        index="mpa_vOct22_CHOCOPhlAnSGB_202212",
        bowtieOut="results/Metaphlan/{sample}_bowtie.txt",
    output:
        "results/Metaphlan/{sample}_profile.txt",
    conda:
        "envs/metaphlan4.yml",
    shell:
        """
        metaphlan {input.concat} --input_type fastq -o {output} --bowtie2db {params.database} -x {params.index} --offline --bowtie2out {params.bowtieOut} -t rel_ab_w_read_stats --unclassified_estimation 
        """


rule Resistome:
    input:
        concat="input/{sample}_concat.fastq",
    params:
        outdir="results/Resistome",
        database="databases/CARD_V.3.2.7_markers.faa",
        temp="results/{sample}_temp/shortbred_resistome",
    output:
        "results/Resistome/{sample}_resistome.txt",
    conda:
        "envs/shortbred.yml",
    shell:
        """
        mkdir -p {params.temp}

        export PATH="$PWD/bin":$PATH

        shortbred_quantify.py --markers {params.database} --id .95 --pctlength .95 --threads 5 --wgs {input.concat} --results {output} --tmp {params.temp}
        rm -r {params.temp}
        """


rule Mobilome:
    input:
        concat="input/{sample}_concat.fastq",
    params:
        outdir="results/Mobilome",
        database="databases/mobile_OG_V.1.6_markers.faa",
        temp="results/{sample}_temp/shortbred_mobilome",
    output:
        "results/Mobilome/{sample}_mobilome.txt",
    conda:
        "envs/shortbred.yml",
    shell:
        """
        mkdir -p {params.temp}
        export PATH="$PWD/bin":$PATH

        shortbred_quantify.py --markers {params.database} --id .95 --pctlength .95 --threads 5 --wgs {input.concat} --results {output} --tmp {params.temp}
        rm -r {params.temp}
        """


