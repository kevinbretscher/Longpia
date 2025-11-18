process COMPRESS {
    tag "compress"

    input:
    path assemblies

    output:
    path "${params.outdir}"

    script:
    """
    autocycler compress \
        -i assemblies \
        -a ${params.outdir}
    """
}
