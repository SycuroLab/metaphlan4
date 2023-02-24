# ************************************
# * Snakefile for metaphlan pipeline *
# ************************************

# **** Variables ****

configfile: "config.yaml"

# **** Imports ****

import pandas as pd
SAMPLES = pd.read_csv(config["list_files"], header = None)
SAMPLES = SAMPLES[0].tolist()

# **** Rules ****

rule all:
    input:
        config["output_dir"] + "/merged_abundance_table_species.txt",
        config["output_dir"] + "/merged_abundance_table_species_relab.txt",
        config["output_dir"] + "/merged_abundance_table_species_GTDB.txt",
        config["output_dir"] + "/merged_abundance_table_species_GTDB_relab.txt"

rule merge_reads:
    input:
        r11 = config["path"]+"{sample}"+config["for"],
        r12 = config["path"]+"{sample}"+config["rev"],
    output:
        config["output_dir"] + "/merged_data/{sample}.fastq"
    shell:
        "cat {input.r11} {input.r12} > {output}"

rule metaphlan:
    input:
        reads = config["output_dir"] + "/merged_data/{sample}.fastq" if config["paired"] else config["path"]+"{sample}"+config["suff"]
    output:
        bt = config["output_dir"] + "/metaphlan/{sample}_bowtie2.bz2",
        pr = config["output_dir"] + "/metaphlan/{sample}_profile.txt"
    params: 
        metaphlan_database = config["metaphlan_database"],
	threads = config["threads"]	
    conda: "utils/envs/metaphlan4.yaml"
    shell:
            "metaphlan -t rel_ab_w_read_stats --unclassified_estimation {input.reads} --input_type fastq "
            "--bowtie2db {params.metaphlan_database} --bowtie2out {output.bt} --nproc {params.threads} -o {output.pr}"


rule sgb_to_GTDB:
    input:
         sg=config["output_dir"] + "/metaphlan/{sample}_profile.txt"
    output:
         gtdb=config["output_dir"] + "/metaphlan/GTDB/{sample}_profile.txt"
    conda: "utils/envs/metaphlan4.yaml"
    shell:
            "sgb_to_gtdb_profile.py  -i {input.sg} -o {output.gtdb}"




rule mergeprofiles:
    input: expand(config["output_dir"] + "/metaphlan/{sample}_profile.txt", sample=SAMPLES)
    output: o1=config["output_dir"] + "/merged_abundance_table.txt",
            o2=config["output_dir"] + "/merged_abundance_table_species.txt"
    params: profiles=config["output_dir"]+"/metaphlan/*_profile.txt"
    conda: "utils/envs/metaphlan4.yaml"
    shell: """
           python utils/merge_metaphlan_tables.py {params.profiles} > {output.o1}
           grep -E "(s__)|(^ID)|(clade_name)|(UNKNOWN)|(UNCLASSIFIED)" {output.o1} | grep -v "t__"  > {output.o2}
           """
rule mergeprofiles_relab:
    input: rules.mergeprofiles.input
    output: o1=config["output_dir"] + "/merged_abundance_table_relab.txt",
            o2=config["output_dir"] + "/merged_abundance_table_species_relab.txt"
    params: profiles=config["output_dir"]+"/metaphlan/*_profile.txt"
    conda: "utils/envs/metaphlan4.yaml"
    shell: """
           python utils/merge_metaphlan_tables_relab.py {params.profiles} > {output.o1}
           grep -E "(s__)|(^ID)|(clade_name)|(UNKNOWN)|(UNCLASSIFIED)" {output.o1} | grep -v "t__"  > {output.o2}
           """


use rule mergeprofiles as mergeprofiles_GTDB with:
    input: expand(config["output_dir"] + "/metaphlan/GTDB/{sample}_profile.txt", sample=SAMPLES)
    output: o1=config["output_dir"] + "/merged_abundance_table_GTDB.txt",
            o2=config["output_dir"] + "/merged_abundance_table_species_GTDB.txt"

use rule mergeprofiles_relab as mergeprofiles_relab_GTDB with:
    input: expand(config["output_dir"] + "/metaphlan/GTDB/{sample}_profile.txt", sample=SAMPLES)
    output: o1=config["output_dir"] + "/merged_abundance_table_GTDB_relab.txt",
            o2=config["output_dir"] + "/merged_abundance_table_species_GTDB_relab.txt"
