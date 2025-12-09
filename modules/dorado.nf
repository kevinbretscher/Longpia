process DORADO_POLISH {
    tag "DORADO_POLISH"
    container "ontresearch/dorado:latest"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sampleID), path(autocycler_out), path(longreads)
    

    output:
    path('Polished_Assemblies/*_medaka.fa'), emit: only_genomes
    tuple val(sampleID), path('Polished_Assemblies/*_dorado.fa'), emit: medaka_polished_genomes_keyed

    script:
    """
    dorado aligner $autocycler_out/consensus_assembly.fasta $longreads | samtools sort --threads $task.cpus > aligned_reads.bam
    
    samtools index aligned_reads.bam

    mkdir Polished_Assemblies

    dorado polish aligned_reads.bam $autocycler_out/consensus_assembly.fasta --bacteria > Polished_Assemblies/${sampleID}_dorado.fa
    """
}