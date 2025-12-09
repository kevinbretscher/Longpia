process NANOPLOT {
    tag "NANOPLOT"
    publishDir "${params.outdir}/Nanoplot", mode: 'copy'
    container "https://depot.galaxyproject.org/singularity/nanoplot%3A1.46.2--pyhdfd78af_0"

    input:
    tuple val(sampleID), path(longreads)

    output:
    path("${sampleID}.txt"), emit: nanoplot_stats

    script:
    """
    NanoPlot \
        --fastq ${longreads} \
        -t $task.cpus \
        --only-report 

    mv NanoStats.txt ${sampleID}_after_trimming.txt
    """
}

process NANOPLOT_RAW {
    tag "NANOPLOT_RAW"
    publishDir "${params.outdir}/Nanoplot", mode: 'copy'
    container "https://depot.galaxyproject.org/singularity/nanoplot%3A1.46.2--pyhdfd78af_0"

    input:
    tuple val(sampleID), path(longreads)

    output:
    path("${sampleID}.txt"), emit: nanoplot_stats

    script:
    """
    NanoPlot \
        --fastq ${longreads} \
        -t $task.cpus \
        --only-report

    mv NanoStats.txt ${sampleID}_raw.txt
    """
}