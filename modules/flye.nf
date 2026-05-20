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
    def extra_args = task.attempt == 3 ? "--meta" : ""
    """
    mkdir -p $sampleID
    flye \
        --nano-hq $filtered_reads \
        --out-dir $sampleID \
        --threads $task.cpus \
        ${params.flye_options} \
        ${extra_args}

    sleep 300

    """
}