process QUAST {
    tag "QUAST"
    container "staphb/quast:latest"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(polished_genomes)

    output:
    path('QUAST_output')

    script:

    """
    quast.py $polished_genomes \
               --threads $task.cpus \
               -o QUAST_output
    """
}