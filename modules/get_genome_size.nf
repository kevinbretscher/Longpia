process GET_GENOME_SIZE {
    tag "genome_size"
    container "longpia/autocycler_plassembler_gnu:latest"

    input:
    tuple val(sampleID), path(longreads)

    output:
    tuple val(sampleID), path ("$sampleID/genome_size.txt"), path(longreads)

    script:
    """
    mkdir -p $sampleID

    mkdir -p /tmp
    export TMPDIR="/tmp"

    autocycler helper genome_size \
        --reads $longreads \
        --threads $task.cpus \
        > $sampleID/genome_size.txt
    """

}