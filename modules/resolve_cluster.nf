process RESOLVE_CLUSTERS {
    tag { cluster }

    input:
    path cluster

    output:
    path cluster

    """
    autocycler trim -c $cluster
    autocycler resolve -c $cluster
    """
}
