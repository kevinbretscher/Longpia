process DNAAPLER {
    tag "DNAAPLER"
    container "staphb/dnaapler:latest"
    publishDir "${params.outdir}/Final_Reoriented", mode: 'copy'

    input:
    tuple val(sampleID), path(polished_genomes)
    

    output:
    path('dnaapler_output/*_reoriented.fasta'), emit: only_genomes
    tuple val(sampleID), path('dnaapler_output/*_reoriented.fasta'), emit: genomes_keyed

    script:
    """
    dnaapler all \
        -i $polished_genomes \
        -o dnaapler_output \
        -t $task.cpus \
        --prefix ${sampleID} \
        -a none
    
    sleep 100
    """
}