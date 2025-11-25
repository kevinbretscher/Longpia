process ASSEMBLE {
    tag "${assembler}_${sample}"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(assembler), val(sample), val(sampleID), path(subsampled), path(genome_size)

    output:
    tuple val(sampleID), path("$sampleID/assemblies/${assembler}_${sample}.fasta")

    script:
    """
    ##mkdir -p /localscratch/users/tmp
    mkdir -p $sampleID/assemblies

    read -r genome_size < $genome_size

    autocycler helper $assembler \
        --reads $subsampled/sample_${sample}.fastq \
        --out_prefix $sampleID/assemblies/${assembler}_${sample} \
        --threads $task.cpus \
        --genome_size "\$genome_size"
    """
}
