process MEDAKA {
    tag "${sampleID}_medaka"
    container "ontresearch/medaka:latest"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sampleID), path(autocycler_out), path(longreads)
    

    output:
    path('Polished_Assemblies/*_medaka.fa'), emit: only_genomes
    tuple val(sampleID), path('Polished_Assemblies/*_medaka.fa'), emit: medaka_polished_genomes_keyed

    script:
    """
    medaka_consensus \
        -i $longreads \
        -d $autocycler_out/consensus_assembly.fasta \
        -t $task.cpus \
        --bacteria

        mkdir Polished_Assemblies
        mv medaka/consensus.fasta Polished_Assemblies/${sampleID}_medaka.fa
    """
}


process MEDAKA_FLYE {
    tag "${sampleID}_medaka"
    container "ontresearch/medaka:latest"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sampleID), path(genome), path(longreads)
    

    output:
    path('Polished_Assemblies/*_medaka.fa'), emit: only_genomes
    tuple val(sampleID), path('Polished_Assemblies/*_medaka.fa'), emit: medaka_polished_genomes_keyed

    script:
    """
    medaka_consensus \
        -i $longreads \
        -d $genome/assembly.fasta \
        -t $task.cpus \
        --bacteria

        mkdir Polished_Assemblies
        mv medaka/consensus.fasta Polished_Assemblies/${sampleID}_medaka.fa
    """
}