// modules/cluster.nf - placeholder module
process clusterContigs {
    tag "cluster"

    input:
    path assembly

    output:
    path "clusters.txt"

    script:
    """
    # placeholder: cluster contigs
    echo "cluster_1 contig_1" > clusters.txt
    """
}
