process ASSEMBLE {
    tag "${assembler}_${sample}"

    input:
    tuple val(assembler), val(sample)
    path subsampled
    val genome_size

    output:
    path "assemblies"

    script:
    """
    mkdir -p assemblies
    autocycler helper $assembler \
        --reads subsampled_reads/sample_${sample}.fastq \
        --out_prefix assemblies/${assembler}_${sample} \
        --threads $task.cpus \
        --genome_size $genome_size
    """
}
