process COMPRESS {
    tag "compress"

    input:
    tuple val(sampleID), path(assemblies)

    output:
    tuple val(sampleID), path("$sampleID")
//to add remove empty assemblies
    script:
    """
    mkdir -p "$sampleID/Assemblies"
    cp $assemblies $sampleID/Assemblies/


    autocycler compress \
        -i $sampleID/Assemblies \
        -a $sampleID/autocycler_out \
        --threads $task.cpus
    """
}
