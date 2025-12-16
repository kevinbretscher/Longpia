# LONGpia
## A simple & modular nextflow pipeline for assembly and assesment of long-read only bacterial genomes.

### Introduction
LONGpia was developed as a simple and modular nextflow pipeline that can work on HPCs. Longpia aims to provide a best-practice workflow for assembling bacterial genomes.

## Pipeline overview and step

### Reads QC and filtering

Porechop is used to remove barcodes from the start, middle or end of the reads. While this is usually already done when basecalling some barcodes can be left behind.

LONGpia offers several optional filtering tools. Including Filtlong, Nanofilt(tba) and fastplong(tba). These are run after porechop.

Kraken2 is used to classify reads. In case of contamininated assembles this can be used to troubleshoot.

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



