process CHECKM2 {
    tag "CheckM2"
    container "https://depot.galaxyproject.org/singularity/checkm2%3A1.1.0--pyh7e72e81_1"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(polished_genomes)

    output:
    path('checkm')

    script:

    """
    mkdir -p Polished_Assemblies
    mv $polished_genomes/*_medaka.fa Polished_Assemblies/

    checkm2 predict --input Polished_Assemblies --output-directory CheckM2  \
     --threads $task.cpus \
     --database_path $params.checkm2_DB

    """
}