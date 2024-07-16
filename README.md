# ARG and Mobilome annotation - read-based pipeline
Read-based pipeline for the annotation of Antibiotic resistance and mobilome genes.

**Authors**: Ahmed Bargheet, Alise Ponsero, Hanna Noordzij, Ching Jian, Katri Korpela, Mireia Valles-Colomer, Justine Debelius, Alexander Kurilshikov, Veronika K. Pettersen

## Installation and requirements
This pipeline requires the use of Snakemake  and usearch v11. 
If not previously installed run the following code: 

```
git clone https://github.com/aponsero/Resistome_ReadBased_Snakemake.git
cd Resistome_ReadBased_Snakemake

## Snakemake installation in a conda environment
conda env create snakemake_env --file envs/env_snakemake.yml
# Alternatively you can create the environment manually:
conda env create -n snakemake_env
conda activate snakemake_env
conda install snakemake

## Installation of usearch v11
mkdir bin
cd bin
wget https://drive5.com/downloads/usearch11.0.667_i86linux32.gz
chmod +x usearch11.0.667_i86linux32.gz
gunzip usearch11.0.667_i86linux32.gz
mv usearch11.0.667_i86linux32 usearch
```

Additionally, custom shortbred databases should be downloaded from [Zenodo](https://zenodo.org/records/11491353) and from Metaphlan4.
```
mkdir databases
cd databases
wget https://zenodo.org/records/11491353/files/CARD_V.3.2.7_markers.faa
wget https://zenodo.org/records/11491353/files/mobile_OG_V.1.6_markers.faa
wget http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/bowtie2_indexes/mpa_vOct22_CHOCOPhlAnSGB_202212_bt2.tar
tar -xvf mpa_vOct22_CHOCOPhlAnSGB_202212_bt2.tar
wget http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202212.tar
tar -xvf mpa_vOct22_CHOCOPhlAnSGB_202212.tar
wget http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202212_marker_info.txt.bz2
wget http://cmprod1.cibio.unitn.it/biobakery4/metaphlan_databases/mpa_vOct22_CHOCOPhlAnSGB_202212_species.txt.bz2
```

## Overview of the pipeline

Below is the overview of the steps included in the pipeline. The pipeline requires reads after quality control and trimming.
The pipeline include 3 steps :
* Taxonomic profiling of the microbial community using Metaphlan4 v4.0.6
* ARG profiling using Shortbred v0.9.5 against the CARD database v.3.2.7
* Mobilome profiling using Shortbred v0.9.5 against the MobileOG database v1.6

```mermaid
graph LR
    reads[(QC reads)] --> concat_reads ;
    concat_reads --> Metaphlan4 ;
    concat_reads --> Shortbred_ARG ;
    concat_reads --> Shortbred_MobileOG;
    Metaphlan4 --> Taxonomic_profiles ;
    Shortbred_ARG --> Resistome_profiles ;
    Shortbred_MobileOG --> Mobilome_profiles ;
    subgraph Rule Concat
        concat_reads ;
    end
    subgraph Rule Metaphlan
        Metaphlan4 ;
        Taxonomic_profiles;
    end
    subgraph Rule Resistome
        Shortbred_ARG ;
        Resistome_profiles ;
    end
    subgraph Rule Mobilome
        Shortbred_MobileOG ;
        Mobilome_profiles ;
    end
```

## How to run the pipeline
The pipeline expects the inputs to be provided in the "input" folder as paired files ({sample_id}_1.fastq.gz and {sample_id}_2.fastq.gz) and can be run in its entirety by providing the expected final output : {sample_id}__finallog.txt 

As an example, to run the pipeline on the test file (TestPipeline_1.fastq.gz and TestPipeline_2.fastq.gz):

```
# run snakemake
snakemake --cores 8 --use-conda results/TestPipeline_finallog.txt
```

### Expected outputs

The pipeline will generate 3 main output files in the results folder:
* Taxonomic profile for each sample : results/Metaphlan/${sample_id}_profile.txt
* Resistome profile for each sample : results/Resistome/{sample}_resistome.txt
* Mobilome profile for each sample : results/Mobilome/{sample}_mobilome.txt


