process PORECHOP {
    tag "porechop"
    container "biocontainers/porechop:v0.2.4dfsg-1-deb_cv1"


    input:
    tuple val(sampleID), path(reads)

    output:
    tuple val(sampleID), path("*.fastq.gz"), emit: trimmed_reads
    path("*.log")     , emit: log

    script:
    """
    porechop \
        -i $reads \
        -t $task.cpus \
        -o ${sampleID}_porechop.fastq.gz \
        > ${sampleID}_porechop.log
    """
}
