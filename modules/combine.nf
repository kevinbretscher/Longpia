// modules/combine.nf - placeholder module
process combineResults {
    tag "combine"

    input:
    path results

    output:
    path "combined.txt"

    script:
    """
    # placeholder: combine results
    echo "combined" > combined.txt
    """
}
