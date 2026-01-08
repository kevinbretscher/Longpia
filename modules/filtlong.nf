process FILTLONG {
    tag "INSPECTOR"
    container "staphb/filtlong:latest"

    input:
    tuple val(sampleID), path(trimmed_reads)

    output:
    tuple val(sampleID), path("${sampleID}_filtered.fastq.gz")

    script:

    """
    filtlong $params.filtering_arg $trimmed_reads | gzip > ${sampleID}_filtered.fastq.gz

    """
}