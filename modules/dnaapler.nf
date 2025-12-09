process DNAAPLER {
    tag "DNAAPLER"
    container "staphb/dnaapler:latest"
    publishDir "${params.outdir}/Final_Reoriented", mode: 'copy'

    input:
    tuple val(sampleID), path(polished_genomes)
    

    output:
    path('*_reoriented.fasta'), emit: only_genomes
    tuple val(sampleID), path('*_reoriented.fasta'), emit: genomes_keyed

    script:
    """

    dnaapler all \
        -i $polished_genomes \
        -o . \
        -t $task.cpus \
        --prefix ${sampleID} \
        -a nearest
    """
}