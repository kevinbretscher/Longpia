process MEDAKA {
    tag "medaka"
    container "ontresearch/medaka:latest"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sampleID), path(longreads)
    path(autocycler_out)

    output:
    path('Polished_Assemblies/*_medaka.fa'), emit: only_genomes
    tuple val(sampleID), path('Polished_Assemblies/*_medaka.fa'), emit: medaka_polished_genomes_keyed

    script:
    """
    medaka_consensus \
        -i $longreads \
        -d $autocycler_out/consensus_assembly.fasta \
        -o . \
        -t $task.cpus \
        --bacteria

        mkdir Polished_Assemblies
        mv consensus.fasta Polished_Assemblies/${sampleID}_medaka.fa
    """
}