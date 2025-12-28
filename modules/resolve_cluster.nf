process RESOLVE_CLUSTERS {
    tag "resolve_clusters"
    container "longpia/autocycler_plassembler_gnu:latest"

    input:
    tuple val(sampleID), path(autocycler_out)

    output:
    tuple val(sampleID), path("$sampleID")

    script:
    """
    for c in $sampleID/autocycler_out/clustering/qc_pass/cluster_*; do
    autocycler trim -c "\$c" -t $task.cpus
    autocycler resolve -c "\$c"
    done
    """
}
