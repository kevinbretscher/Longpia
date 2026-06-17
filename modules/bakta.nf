process BAKTA {
    tag "Bakta_${sampleID}"
    container "oschwengers/bakta:v1.11.3"
    publishDir "${params.outdir}/BAKTA", mode: 'copy'
    errorStrategy 'retry'
    maxRetries 5

    input:
    tuple val(sampleID), path(polished_genomes)
    each path(DB)

    output:
    path("${sampleID}"), emit: bakta_output
    path("${sampleID}/*.txt"), emit: bakta_summary
    path("${sampleID}/*.faa"), emit: faa

    script:
    """
    mkdir -p /tmp

    export TMPDIR="/tmp"
    export MPLCONFIGDIR="/tmp"
    
    bakta \
    --db $DB \
    --threads $task.cpus \
    --output ./${sampleID} \
    --prefix ${sampleID}_Bakta \
    --strain $sampleID \
    --locus-tag $sampleID \
    --verbose \
    $polished_genomes
    """
}
