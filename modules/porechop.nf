process PORECHOP {
    tag "porechop"
    container "https://depot.galaxyproject.org/singularity/porechop:0.2.4--py39h7cff6ad_2"


    input:
    tuple val(sampleID), path(reads)

    output:
    tuple val(sampleID), path("*.fastq.gz"), emit: trimmed_reads
    tuple val(sampleID), path("*.log")     , emit: log

    script:
    """
    porechop \\
        -i $reads \\
        -t $task.cpus \\
        $args \\
        -o ${sampleID}_porechop.fastq.gz \\
        > ${sampleID}_porechop.log
    """
}
