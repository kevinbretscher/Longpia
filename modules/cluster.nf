process CLUSTER {
    tag "cluster"

    input:
    path outdir

    output:
    path outdir

    script:
    """
    autocycler cluster -a ${params.outdir}
    """
}
