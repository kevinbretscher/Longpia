process CRAQ {
    tag "CRAQ"
    container "https://depot.galaxyproject.org/singularity/craq%3A1.10--hdfd78af_0"
    publishDir "${params.outdir}/CRAQ", mode: 'copy'

    input:
    tuple val(sampleID), path(polished_genomes), path(raw_reads)

    output:
    path("${sampleID}")

    script:

    """
    craq -g $polished_genomes \ 
    -sms $raw_reads \
    -t $task.cpus \
    -D ${sampleID}
    """
}