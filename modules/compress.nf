process COMPRESS {
    tag "compress"

    input:
    tuple val(sampleID), path(assemblies)

    output:
    tuple val(sampleID), path("$sampleID")

    script:
    """
    mkdir -p "$sampleID/Assemblies"
    cp $assemblies $sampleID/Assemblies/

    find $sampleID/Assemblies/ -name '*.fasta' -size 0 -delete

    autocycler compress \
        -i $sampleID/Assemblies \
        -a $sampleID/autocycler_out \
        --threads $task.cpus
    """
}
