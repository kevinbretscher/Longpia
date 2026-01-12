process KRAKEN2 {
    tag "KRAKEN_${sampleID}"
    publishDir "${params.outdir}/Kraken2", mode: 'copy'
    container "staphb/kraken2:latest"

    input:
    tuple val(sampleID), path(longreads)
    each path (DBPATH)

    output:
    path("${sampleID}_kraken_report")

    script:
    """
    kraken2 \
    --db $DBPATH \
    --gzip-compressed \
    --threads $task.cpus \
    --report ${sampleID}_kraken_report \
    $longreads

    """

}
