# LONGpia
## A simple & modular nextflow pipeline for assembly and assesment of long-read only bacterial genomes.

### Introduction
LONGpia was developed as a simple and modular nextflow pipeline that can work on HPCs. Longpia aims to provide a best-practice workflow for assembling bacterial genomes from Nanopore R10.4.1 longread data.

## Pipeline overview and steps

### Reads QC and filtering

Porechop is used to remove barcodes from the start, middle or end of the reads. While this is usually already done when basecalling some barcodes can be left behind.

LONGpia offers several optional filtering tools. Including Filtlong, Nanofilt(tba) and fastplong(tba). These are run after porechop.

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

TBA

### MultiQC report

A multiqc report is generated with the results of Nanoplot, Kraken2, Quast, CheckM, Checkm2 and BUSCO.


## Best-practice recomendations

If time is not an issue and you know you have sufficient coverage use Autocycler with several assemblers (with polishing). This should yield the highest quality genomes. To have unfragmented assemblies you often need reads long enough

If you need quicker results I recommend running only flye with polishing

If you are not sure if your read length and coverage is enough to assemble unfragmented genomes I recommend running flye without polishing and assess the results. You should see one big contig and potentially some plasmids. Bacterial genomes that are unfragmented can be rerun with Autocycler. 

I recommend running all QC tools as they run in parrallel and take little time. However BUSCO might be problematic when working with unknown isolates (see below).