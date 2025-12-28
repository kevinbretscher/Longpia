process FILTLONG {
    tag "INSPECTOR"
    container "staphb/filtlong:latest"

    input:
    tuple val(sampleID), path(trimmed_reads)

    output:
    path("${sampleID}_filtered.fastq.gz")

    script:

    """
    filtlong $params.filtlong_args $trimmed_reads > gzip ${sampleID}_filtered.fastq.gz

    """
}