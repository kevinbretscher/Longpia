process BUSCO {
    tag "BUSCO"
    container "ezlabgva/busco:v6.0.0_cv1"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(polished_genomes)
    path(BUSCO_DB)

    output:
    path('BUSCO_output')

    script:

    """
    mkdir -p Polished_Assemblies
    cp $polished_genomes Polished_Assemblies/

    busco -i Polished_Assemblies \
    --offline \
    --download_path $BUSCO_DB \
     -o BUSCO_output \
     -m genome \
     -c $task.cpus \
     -l $params.busco_lineage \
     --force

    busco --plot BUSCO_output
    """
}