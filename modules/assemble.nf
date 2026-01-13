process ASSEMBLE {
    tag "${sampleID}_${assembler}_${sample}"
    container "longpia/autocycler_plassembler_gnu:latest"
    publishDir "${params.outdir}/autocycler_intermediate", mode: 'copy'
    errorStrategy 'ignore'

    input:
    tuple val(assembler), val(sample), val(sampleID), path(subsampled), path(genome_size)
    each path(plassembler_DB)

    output:
    tuple val(sampleID), path("$sampleID/assemblies/${sampleID}_${assembler}_${sample}.fasta")

    script:
    """
    mkdir -p $sampleID/assemblies

    read -r genome_size < $genome_size

    mkdir -p /tmp
    export TMPDIR="/tmp"

    if [[ "$assembler" == "plassembler" ]]; then
        export PLASSEMBLER_DB="${plassembler_DB}"
        export TERM=xterm-256color
        
        autocycler helper $assembler \
            --reads $subsampled/sample_${sample}.fastq \
            --out_prefix $sampleID/assemblies/${sampleID}_${assembler}_${sample} \
            --threads $task.cpus \
            --genome_size "\$genome_size" 

    else
        autocycler helper $assembler \
            --reads $subsampled/sample_${sample}.fastq \
            --out_prefix $sampleID/assemblies/${sampleID}_${assembler}_${sample} \
            --threads $task.cpus \
            --genome_size "\$genome_size"
    fi
    """
}