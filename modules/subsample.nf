// modules/subsample.nf - placeholder module
process subsampleReads {
    tag "subsample"

    input:
    path reads

    output:
    path "subsampled.fastq"

    script:
    """
    # placeholder: subsample reads
    cp $reads subsampled.fastq
    """
}
