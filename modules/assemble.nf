process ASSEMBLE {
    tag "${assembler}_${sample}"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(assembler), val(sample)
    each path(subsampled)
    each genome_size

    output:
    path "assemblies/${assembler}_${sample}.fasta"

    script:
    """
    mkdir -p /localscratch/users/tmp
    mkdir -p assemblies
    autocycler helper $assembler \
        --reads subsampled_reads/sample_${sample}.fastq \
        --out_prefix assemblies/${assembler}_${sample} \
        --threads $task.cpus \
        --genome_size $genome_size
    """
}
