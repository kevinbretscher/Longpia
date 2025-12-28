process SUBSAMPLE {
    tag "subsample"
    container "longpia/autocycler_plassembler_gnu:latest"

    input:
    tuple val(sampleID), path (genome_size), path(longreads)

    output:
    tuple val(sampleID), path ("$sampleID/subsampled_reads") , path(genome_size)

    script:
    """
    read -r genome_size < $genome_size

    autocycler subsample \
        --reads $longreads \
        --out_dir $sampleID/subsampled_reads \
        --min_read_depth $params.min_read_depth \
        --genome_size "\$genome_size" \
        --count $params.n_samples
    """
}
