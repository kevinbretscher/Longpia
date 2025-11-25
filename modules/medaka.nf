process MEDAKA {
    tag "medaka"

    input:
    tuple val(sampleID), path(subsampled_reads), path(genome_size)

    output:
    path('*_medaka.fa')

    script:
    """
    medaka_consensus \
        -i \
        -d  \
        -o . \
        -t $task.cpus \

        mv medaka/* . && rm -r medaka/
        mv consensus.fasta ${sampleID}_medaka.fa
    """
}