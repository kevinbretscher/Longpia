process GTDBTK {
    tag "GTDBTK"
    container "ecogenomic/gtdbtk:latest"
    publishDir "${params.outdir}/gtdbtk", mode: 'copy'

    input:
    path(polished_genomes)

    output:
    path('gtdbtk')

    script:

    """

    """
}