process SKANI_CLASSIFICATION {
    tag "SKANI_CLASSIFICATION"
    container "staphb/skani:0.3.1"
    publishDir "${params.outdir}/skani_taxonomy", mode: 'copy'

    input:
    path(polished_genomes)
    path(db)

    output:
    path('skani_taxonomy.txt')

    script:

    """
    echo "Running SKANI classification on polished genomes"
    skani search $polished_genomes -d $db -t $task.cpus -o skani_taxonomy.txt --debug
    """

}