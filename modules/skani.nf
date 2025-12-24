process SKANI_CLASSIFICATION {
    tag "SKANI_CLASSIFICATION"
    container "staphb/skani:0.3.1"
    publishDir "${params.outdir}/skani_taxonomy", mode: 'copy'

    input:
    path(polished_genomes)

    output:
    path('skani_taxonomy.tsv')

    script:

    """
    quast.py $polished_genomes \
               --threads $task.cpus \
               -o QUAST_output

    skani search $polished_genomes -d skani_gtdb_r226-v0.3 -t $task.cpus -o skani_taxonomy.tsv

    """
}