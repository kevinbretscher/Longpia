process GET_GENOME_SIZE {
    tag "genome_size"

    input:
    tuple val(sampleID), path(longreads)

    output:
    tuple val(sampleID), path ("$sampleID/genome_size.txt"), path(longreads)

    script:
    """
    mkdir -p /localscratch/users/tmp
    mkdir -p $sampleID

    autocycler helper genome_size \
        --reads $longreads \
        --threads $task.cpus \
        > $sampleID/genome_size.txt
    """

}
