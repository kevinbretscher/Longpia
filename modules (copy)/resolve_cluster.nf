process RESOLVE_CLUSTERS {
    tag "resolve_clusters"

    input:
    path autocycler_out

    output:
    path "$autocycler_out"

    script:
    """
    for c in $autocycler_out/clustering/qc_pass/cluster_*; do
    autocycler trim -c "\$c" -t $task.cpus
    autocycler resolve -c "\$c"
    done
    """
}
