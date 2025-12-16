process MULTIQC {
    tag "MultiQC"
    publishDir "${params.outdir}", mode: 'copy'
    container "multiqc/multiqc:v1.33"


    input:
    path(porechop_logs)
    path(nanoplot_stats)
    path(nanoplot_raw_stats)
    path(checkm_reports)
    path(checkm2_reports)
    path(busco_reports)
    path(quast_reports)
    path(bakta_reports)
    path(kraken2_reports)

    output:
    path("multiqc_report.html")
    path("multiqc_data")
    
    when:
    task.ext.when == null || task.ext.when

    script:
    """
    multiqc .
    """
}