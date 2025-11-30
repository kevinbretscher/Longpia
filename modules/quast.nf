process QUAST {
    tag "QUAST"
    container "https://depot.galaxyproject.org/singularity/quast%3A5.3.0--py39pl5321heaaa4ec_0"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(polished_genomes)

    output:
    path('QUAST_output')

    script:

    """
    ./quast.py $polished_genomes \
               --threads $task.cpus \
               --output-dir QUAST_output \
               --space-efficient
    """
}