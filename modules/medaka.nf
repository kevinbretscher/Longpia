process MEDAKA {
    tag "medaka"
    container "https://depot.galaxyproject.org/singularity/medaka:2.1.1--py39h182ef57_0"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sampleID), path(longreads)
    path(autocycler_out)

    output:
    path('Polished_Assemblies/*_medaka.fa')

    script:
    """
    medaka_consensus \
        -i $longreads \
        -d $autocycler_out/consensus_assembly.fasta \
        -o . \
        -t $task.cpus \

        mkdir Polished_Assemblies
        mv consensus.fasta Polished_Assemblies/${sampleID}_medaka.fa
    """
}