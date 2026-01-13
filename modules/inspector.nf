process INSPECTOR {
    tag "INSPECTOR"
    container "longpia/inspector:latest"
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
