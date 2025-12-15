process KRAKEN2 {
    tag "KRAKEN_${sampleID}"
    container "staphb/kraken2:latest"

    input:
    tuple val(sampleID), path(longreads)
    each path (DBPATH)

    output:
    path("${sampleID}_report")

    script:
    """
    kraken2 \
    --db $DBPATH \
    --gzip-compressed \
    --threads $task.cpus \
    --report ${sampleID}_report \
    $longreads

    """

}
