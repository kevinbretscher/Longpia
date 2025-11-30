process FILTLONG {
    tag "INSPECTOR"
    container "https://depot.galaxyproject.org/singularity/inspector%3A1.3.1--hdfd78af_1"
    publishDir "${params.outdir}/Inspector", mode: 'copy'

    input:
    tuple val(sampleID), path(polished_genomes), path(raw_reads)

    output:
    path("${sampleID}")

    script:

    """
    inspector.py -c $polished_genomes \
    -r $raw_reads \
    -d nanopore \
    -t $task.cpus \
    -o ${sampleID}/
    """
}