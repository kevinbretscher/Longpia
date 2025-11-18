// modules/resolve_cluster.nf - placeholder module
process resolveCluster {
    tag "resolve_cluster"

    input:
    path clusters

    output:
    path "resolved.fasta"

    script:
    """
    # placeholder: resolve clusters
    echo ">resolved_1\nATGC" > resolved.fasta
    """
}
