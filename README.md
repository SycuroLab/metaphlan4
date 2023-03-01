# metaphlan

Snakemake pipeline for profiling composition of microbial communities from metagenomic shotgun sequencing data using [MetaPhlAn4](https://www.nature.com/articles/s41587-023-01688-w).

## Overview

Input: 

* Cleaned and filtered reads from shotgun metagenome sequencing (specify whether reads are paired or unpaired in the config file

Output: 

* Table of microbial taxa and their **raw** abundance for each sample, `merged_abundance_table.txt, merged_abundance_table_relab.txt, merged_abundance_table_GTDB.txt,merged_abundance_table_GTDB.txt`
* Abundance table at species level, `merged_abundance_table_species.txt, merged_abundance_table_species_relab.txt, merged_abundance_table_species_GTDB.txt, merged_abundance_table_species_GTDB_relab.txt`

## Pipeline summary

### Steps

1) Profile microbial clades and their abundances using MetaPhlAn4. This step generates a profile of species abundances present in each sample.

2) Merge profiles. This step combines all the output files from MetaPhlAn4 into one table.

3) Individual sample profile has both raw and relative abundance values so if needed relative abundances can be merged also.

## Installation

To use this pipeline, navigate to your project directory and clone this repository into that directory using the following command:

```
git clone git@github.com:SycuroLab/metaphlan4.git
```

Note: you need to have **conda** and **snakemake** installed in order to run this.  

To install snakemake using conda, run the following line:

```
conda create --name snakemake
conda activate snakemake
conda install -c conda-forge mamba
conda install -c bioconda snakemake
```

See the snakemake installation [webpage](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html) for further details.

## Config file

All the parameters required to run this pipeline are specified in a config file, written in yaml. See/modify the provided example file with your custom parameters, called `config.yaml`. This is the only file that should be modified before running the pipeline. Make sure to follow the syntax in the example file in terms of when to use quotations around parameters.

## Data and list of files

Specify the full path to the directory that contains your data files in the config file. You also need to have a list of sample names which contains the names of the samples to run the pipeline on, one sample per line. You can run this pipeline on any number or subset of your samples. Sample names should include everything up to the R1/R2 (or 1/2) part of the file names of the raw fastq files. Specify the path and name of your list in the config file.

## Description of parameters
| Parameter | Description | Example |
| -------------- | --------------- | ------------ |
| list_files | Full path and name of your sample list. | `"/home/aschick/project/list_files.txt"` |
| path | Location of input files. | `"/home/aschick/project/data/filtered/"` |
| output_dir | Location of output files. | `"/home/aschick/project/metaphlan"` |
| metaphlan_database | Location of the Metaphlan bowtie2 database. | `"/bulk/IMCshared_bulk/shared/dbs/metaphlan3"` |
| threads | Number of threads for Metaphlan | `8` |
| paired | Are reads paired? Set to `TRUE` if the reads are paired. | `FALSE` |
| for | If paired, suffix of forward reads. | `"_R1_filtered.fastq"` |
| rev | If paired, suffix of reverse reads. | `"_R2_filtered.fastq"` |
| suff | If unpaired, suffix of reads. | `"_merged_trimmed_filtered.fastq"` |

## Running the pipeline on ARC (SLURM cluster)

Test the pipeline by running `snakemake -np`. This command prints out the commands to be run without actually running them. 

To run the pipeline on the ARC compute cluster, enter the following command from the project directory:

```
sbatch < metaphlan_sbatch.sh
```

The above command submits jobs to ARC, one for each sample and step of the metaphlan snakemake pipeline.

Note: the file `cluster.json` contains the parameters for the SLURM job submission system that ARC uses. In most cases, this file should not be modified. Use the `cluster.json` file in the `cluster_files/slurm_files/` folder. 

The ARC Cluster Guide can be found here:
https://rcs.ucalgary.ca/index.php/ARC_Cluster_Guide

The General Guidelines and Policies can be found here:
https://rcs.ucalgary.ca/index.php/General_Cluster_Guidelines_and_Policies

## Results and log files

Snakemake will create a directory for the results of the pipeline as well as a directory for log files. Log files of each step of the pipeline will be written to the `logs` directory.

## Metphlan Database

The Metaphlan Database was downloaded and installed previously for ease of use.

Location: 
`arc.ucalgary.ca`

Directory Path: 
`/bulk/IMCshared_bulk/shared/dbs/metaphlan3`

If there is a newer version of the database that you want to use for your project you can download the newer version;

1. Install the metaphlan 3 conda environment. Requires conda please see conda installation instructions above.
```
conda env create --file metaphlan3_env.yaml 
```
2. Activate the metaphlan3 conda environment.
```
conda activate metaphlan3
```
3. Download and install metaphlan database.
```
metaphlan --install
```

After installation the database should be located in the following directory.
```
/home/<username>/miniconda3/envs/metaphlan3/lib/python3.7/site-packages/metaphlan/metaphlan_databases
```

Place this path in the `metaphlan_database` parameter in the `config.yaml` file.


## Known Issues

1) Sometimes the pipeline fails with the every first metaphlan command exiting. A possible problem can be with the execute permissions not set in the conda envirnoment bin forlder for metaphlan. You can check this by 
 ``` ls -l .snakemake/conda/<ENV_name>/bin/metaphlan ```. 
 Once in the bin folder, you can change the permissions by ```chmod u+x *``` to change the permissions for all executables in the bin folder.
2) The location of the downloaded chocophlan database that metaphlan needs is ```.snakemake/conda/<ENV_name>/lib/python3.7/site-packages/metaphlan/metaphlan_databases/```. It has happened in the past that some files are missing so this would be the place to check
