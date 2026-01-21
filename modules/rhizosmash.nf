process RHIZOSMASH {
    tag "Rhizosmash_${fasta}"
    container "rhizosmashdev/rhizosmash-standalone"
    publishDir "rhizosmash", mode: 'copy'

    input:
    path(fasta)

    output:
    path(fasta.baseName)


    script:
    """
    mkdir -p /tmp

    export TMPDIR="/tmp"
    export MPLCONFIGDIR="/tmp"
    
    rhizosmash --output-dir ${fasta.baseName} --cb-knownclusters $fasta
    """
}