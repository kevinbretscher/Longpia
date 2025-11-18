// modules/compress.nf - placeholder module
process compressOutputs {
    tag "compress"

    input:
    path file_to_compress

    output:
    path "${file_to_compress}.gz"

    script:
    """
    gzip -c $file_to_compress > ${file_to_compress}.gz
    """
}
