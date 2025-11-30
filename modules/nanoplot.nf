process NANOPLOT {
    tag "NANOPLOT"
    publishDir "${params.outdir}/Nanoplot", mode: 'copy'
    container "https://depot.galaxyproject.org/singularity/nanoplot%3A1.46.1--pyhdfd78af_0"

    input:
    tuple val(sampleID), path(longreads)

    output:
    path("*.txt"), emit: nanoplot_stats

    script:
    """
    NanoPlot \
        --fastq ${longreads} \
        -t $task.cpus 

    mv NanoStats.txt ${sampleID}.txt
    """
}