process FLYE {
    tag "${sampleID}_flye"
    container "nanozoo/flye:2.9.6--8f3dad7"
    publishDir "${params.outdir}/flye", mode: 'copy'
    errorStrategy 'retry'
    maxRetries 3

    input:
    tuple val(sampleID), path(filtered_reads)

    output:
    tuple val(sampleID), path("$sampleID/assembly.fasta"), emit: genomes_keyed

    script:
    """
    mkdir -p $sampleID
    flye \
        --nano-hq $filtered_reads \
        --out-dir $sampleID \
        --threads $task.cpus \
        ${params.flye_options}

    sleep 300

    """
}