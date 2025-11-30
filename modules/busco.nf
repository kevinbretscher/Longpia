process BUSCO {
    tag "BUSCO"
    container "https://depot.galaxyproject.org/singularity/busco%3A6.0.0--pyhdfd78af_1"
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
     --auto-lineage \
     --force

    busco --plot BUSCO_output
    """
}