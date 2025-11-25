process CLUSTER {
    tag "cluster"

    input:
    path autocycler_out

    output:
    path "$autocycler_out"

    script:
    """
    autocycler cluster -a $autocycler_out
    """
}
