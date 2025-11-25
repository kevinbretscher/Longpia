process COMPRESS {
    tag "compress"

    input:
    path assemblies

    output:
    path "autocycler_out"
//to add remove empty assemblies
    script:
    """
    mkdir -p "Assemblies"
    cp $assemblies Assemblies/


    autocycler compress \
        -i Assemblies \
        -a autocycler_out \
        --threads $task.cpus
    """
}
