process CLUSTER {
    tag "cluster"

    input:
    path outdir

    output:
    path outdir

    """
    autocycler cluster -a ${params.outdir}
    """
}
