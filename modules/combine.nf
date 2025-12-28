process COMBINE {
    tag "combine"
    container "longpia/autocycler_plassembler_gnu:latest"
    publishDir "${params.outdir}/autocycler_intermediate", mode: 'copy'

    input:
    tuple val(sampleID), path(autocycler_out)

    output:
    tuple val(sampleID), path ("$sampleID/autocycler_out"), emit: autocycler_folder
    tuple val(sampleID), path ("$sampleID/autocycler_out/consensus_assembly.fasta"), emit: genomes_keyed

    script:
    """
    autocycler combine \
        -a $sampleID/autocycler_out \
        -i $sampleID/autocycler_out/clustering/qc_pass/cluster_*/5_final.gfa
    """
}
