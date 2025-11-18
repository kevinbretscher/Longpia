process COMPRESS {
    tag "compress"

    input:
    path assemblies

    output:
    path "${params.outdir}"

    """
    autocycler compress \
        -i assemblies \
        -a ${params.outdir}
    """
}
