process CHECKM2 {
    tag "CheckM2"
    container "Containers/checkm2.sif"
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