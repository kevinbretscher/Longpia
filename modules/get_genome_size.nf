// modules/get_genome_size.nf - placeholder module
process getGenomeSize {
    tag "get_genome_size"

    input:
    path fasta

    output:
    stdout result

    script:
    """
    # placeholder: compute genome size
    echo "genome_size=1000"
    """
}
