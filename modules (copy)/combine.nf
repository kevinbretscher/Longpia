process COMBINE {
    tag "combine"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path autocycler_out

    output:
    path autocycler_out

    script:
    """
    autocycler combine \
        -a $autocycler_out \
        -i $autocycler_out/clustering/qc_pass/cluster_*/5_final.gfa
    """
}
