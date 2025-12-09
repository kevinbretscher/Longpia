process MULTIQC {
    tag "MultiQC"
    publishDir "${params.outdir}", mode: 'copy'
    container "https://depot.galaxyproject.org/singularity/multiqc%3A1.32--pyhdfd78af_1"


    input:
    path(porechop_logs)
    path(nanoplot_stats)
    path(nanoplot_raw_stats)
    path(checkm_reports)
    path(checkm2_reports)
    path(busco_reports)
    path(quast_reports)
    path(bakta_reports)

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