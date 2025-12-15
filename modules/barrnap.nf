process BARRNAP {
    tag "BARRNAP"
    container "biocontainers/barrnap:v0.9dfsg-1-deb_cv1"
    publishDir "${params.outdir}/BARRNAP", mode: 'copy'

    input:
    tuple val(sampleID), path(polished_genomes)

    output:
    path('${sampleID}.rRNA.fasta')

    script:

    """
    barrnap \
    --threads $task.cpus \
    --outseq ${sampleID}.rRNA.fasta \
    $polished_genomes

    """
}