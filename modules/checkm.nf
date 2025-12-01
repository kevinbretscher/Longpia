process CHECKM {
    tag "CheckM"
    container "https://depot.galaxyproject.org/singularity/checkm-genome%3A1.2.4--pyhdfd78af_2"
    publishDir "${params.outdir}", mode: 'copy'
    errorStrategy 'retry'
    maxRetries 2

    input:
    path(polished_genomes)
    path(checkm_DB)

    output:
    path('CheckM')

    script:

    """
    mkdir -p Polished_Assemblies
    cp $polished_genomes Polished_Assemblies/

    export CHECKM_DATA_PATH=$checkm_DB
    checkm data setRoot $checkm_DB

    checkm lineage_wf -x .fa Polished_Assemblies CheckM -t $task.cpus
    
    checkm qa CheckM/lineage.ms CheckM -o 1 --tab_table -q > CheckM/checkm_overview.tsv

    """
}