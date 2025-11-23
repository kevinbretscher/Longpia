process GET_GENOME_SIZE {
    tag "genome_size"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path reads

    output:
    path 'genome_size.txt'  

    script:
    """
    autocycler helper genome_size \
        --reads $reads \
        --threads $task.cpus \
        > genome_size.txt
    """

}
