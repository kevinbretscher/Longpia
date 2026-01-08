# LONGpia
## A simple & modular nextflow pipeline for assembly and assesment of long-read only bacterial genomes.

### Introduction
LONGpia was developed as a simple and modular nextflow pipeline that works on HPCs. Longpia aims to provide a (i.m.o.) best-practice workflow for assembling bacterial genomes from Nanopore R10.4.1 longread data. It is build around Ryan wick's autocycler.

It is currently in early development

## Requirements and installation

You will need to install:

- Nextflow 24+
- Singularity / apptainer / docker

Depending on the tools you are gonna use you might need to download databases.

The main nextflow script need to be run on a server or node with internet so that containers can be pulled. 

If you are using a (slurm) HPC you will also need to set up a configuration or profile for you system, it is best to consult your server administrator for this. Also make sure to set the resources.config to appropriate values.

## Pipeline overview and steps

### Reads QC and filtering

Porechop is used to remove barcodes from the start, middle or end of the reads. While this is usually already done when basecalling some barcodes can be left behind.

LONGpia offers several optional filtering tools. Including Filtlong, Nanofilt (tba) and fastplong(tba). These are run after porechop. There are no default parameters so settings for filtering need to be configured

Kraken2 is used to classify reads. In case of contamininated assembles this can be used to troubleshoot. (Optionally)

Before and after filtering quality stats are done with Nanoplot

### Assembly

For assembly two options are available:

- Autocycler (The following assemblers are available:)
- Flye

For Autocycler a suite of assemblers can be chosen. The assemblies are run in parrallel. Generally Autocycler should give you better final assemblies. However it does require the majority of assemblies to be complete. Therefore if you have shorter reads and/or lower coverage I reccomend try Flye first to see of complete assemblies can be made. (see: )

### Polishing

Optional polishing can be done with Medaka. 

I intend to replace this with Dorado polish as it seems Nanopore is moving towards that, however currently there are some issues with the size of the docker+models.

Short-read polishing is currently not supported. 

### Reorientation

Genomes and plasmids are reoriented with DNAAPLER the start at dnaA or oriC (if possible)

### Assembly evaluation

Several optional tools are provided to assess quality:

- CheckM*
- CheckM2* (Useful for rare lineages)
- BUSCO*
- QUAST
- Inspector
- CRAQ

*Requires external database

### Annotation

- BAKTA*: Genomes can be annotated using BAKTA. Additionally the BAKTA summary can be useful for quality assesment. Also generates a circular genome plot.
- BARRNAP is used to extract 5S, 16S and 23S fragments.

*Requires external database

### Taxonomy

Longpia uses skani to assign taxonomy to whole genomes by searching against a Pre-sketched GTDB-R226 database provided by the skani team. This is faster then gtdb-tk and uses less computing power. However this might not give results for novel genomes (< 80% ANI to a reference). The taxanomic classification is therefore meant as a quick check and for proper taxanomic placement of strains I still recommend to try GTDB-tk especially when working with novel isolates. See https://github.com/bluenote-1577/skani/wiki for more info.

That said, isolates that have less then 80% ANI to a reference are generally a rare phenoma when bacteria from well-defined enviroments. 

### MultiQC & Longpia report

A multiqc report is generated with the results of Nanoplot, Kraken2, Quast, CheckM, Checkm2, BUSCO and BAKTA.

Longpia report TBA
Longpia reports combines output of CRAQ, Inspector, CheckM and other tool into a single TSV. Which can be useful for quality assesment and visualization. 


## Best-practice recomendations

If time is not an issue and you know you have sufficient coverage use Autocycler with several assemblers (with polishing). This should yield the highest quality genomes. To have unfragmented assemblies you often need reads long enough. see autocycler wiki ...

If you need quicker results I recommend running only flye with polishing.

If you are not sure if your read length and coverage is enough to assemble unfragmented genomes I recommend running flye without polishing and assess the results. For an unfragmented genome you should see one big contig and potentially some plasmids. Bacterial genomes that are unfragmented can be rerun with Autocycler. 

I recommend running all QC tools as they run in parrallel and take little time. However BUSCO might be problematic when working with unknown isolates (see below).

## Known issues

- Plassembler only assembles plasmids, which means that if your bacteria does not have a plasmid it fails. When resuming the pipeline it will attempt again to assemble with plassembler and therefore also rerun avery step after it. I'm working on a way to prevent this but for now it is best to not use plassembler when asssembling genomes without plasmid. 
- Other assembler might also randomly fail. Again when rerunning they will be run again.
- Bakta sometimes fails at the tRNA annoation step. I am not sure what causes this. 
- Currently nextflow reports cannot be generated as some containers are missing essential tools.