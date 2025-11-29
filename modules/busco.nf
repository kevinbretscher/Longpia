process BUSCO {
    tag "BUSCO"
    container "https://depot.galaxyproject.org/singularity/busco%3A6.0.0--pyhdfd78af_1"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(polished_genomes)

    output:
    path('BUSCO')

    script:

    """
    mkdir -p Polished_Assemblies
    mv $polished_genomes/*_medaka.fa Polished_Assemblies/

    busco Polished_Assemblies \
    --offline \ 
    --download_path $params.BUSCO_DB \
     -o BUSCO \
     -m genome \
     -c $task.cpus \
     -l $params.busco_lineage

    busco --plot BUSCO
    """
}