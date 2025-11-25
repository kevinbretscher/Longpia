process CLUSTER {
    tag "cluster"

    input:
    tuple val(sampleID), path(autocycler_out)
    

    output:
    tuple val(sampleID), path("$sampleID")

    script:
    """
    autocycler cluster -a $sampleID/autocycler_out
    """
}
