process RESOLVE_CLUSTERS {
    tag "${cluster}"

    input:
    path cluster

    output:
    path cluster

    script:
    """
    autocycler trim -c $cluster -t $task.cpus
    autocycler resolve -c $cluster
    """
}
