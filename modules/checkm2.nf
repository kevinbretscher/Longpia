process CHECKM2 {
    tag "CheckM2"
    container "staphb/checkm2:latest"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(polished_genomes)
    path(checkm2_DB)

    output:
    path('CheckM2')

    script:

    """
    mkdir -p Polished_Assemblies
    cp $polished_genomes Polished_Assemblies/

    checkm2 predict --input Polished_Assemblies --output-directory CheckM2  \
     --threads $task.cpus \
     --database_path $checkm2_DB \
     -x .fasta

    """
}