process GET_GENOME_SIZE {
    tag "genome_size"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path reads

    output:
    val genome_size

    """
    genome_size=\$(autocycler helper genome_size \
        --reads $reads \
        --threads ${params.threads})

    echo \$genome_size > genome_size.txt
    """
    genome_size = file("genome_size.txt").text.trim()
}
