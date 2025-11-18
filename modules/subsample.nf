process SUBSAMPLE {
    tag "subsample"

    input:
    path reads
    val genome_size

    output:
    path "subsampled_reads"

    script:
    """
    autocycler subsample \
        --reads $reads \
        --out_dir subsampled_reads \
        --genome_size $genome_size
    """
}
