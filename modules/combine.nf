process COMBINE {
    tag "combine"

    input:
    path outdir
    path resolved

    output:
    path "${params.outdir}/final_assembly.gfa"

    """
    autocycler combine \
        -a ${params.outdir} \
        -i ${params.outdir}/clustering/qc_pass/cluster_*/5_final.gfa
    """
}
