process CHECKM {
    tag "CheckM"
    container "Containers/checkm"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(polished_genomes)

    output:
    path('checkm')

    script:

    """
    mkdir -p Polished_Assemblies
    mv $polished_genomes/*_medaka.fa Polished_Assemblies/

    checkm data setRoot $params.checkm_DB

    checkm lineage_wf -x .fa Polished_Assemblies CheckM -t $task.cpus
    
    checkm qa CheckM/lineage.ms CheckM -o 1 --tab_table -q > CheckM/checkm_overview.tsv

    """
}