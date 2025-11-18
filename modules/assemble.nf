// modules/assemble.nf - placeholder module
process assembleReads {
    tag "assemble"

    input:
    path reads

    output:
    path "assembly.fasta"

    script:
    """
    # placeholder: assemble reads
    echo ">contig_1\nATGC" > assembly.fasta
    """
}
