process MULTIQC {
    tag "MultiQC"
    publishDir "${params.outdir}", mode: 'copy'
    container "https://depot.galaxyproject.org/singularity/multiqc%3A1.32--pyhdfd78af_1"


    input:
    path(porechop_logs)
    path(nanoplot_stats)
    path(checkm_reports)
    path(checkm2_reports)
    path(busco_reports)

    output:
    path("multiqc_report.html")
    path("multiqc_data")
    
    when:
    task.ext.when == null || task.ext.when

    script:
    """
    mkdir -p ./collected_reports
    cp $porechop_logs ./collected_reports/
    cp $nanoplot_stats ./collected_reports/
    cp $checkm_reports/* ./collected_reports/
    cp $checkm2_reports/* ./collected_reports/
    cp $busco_reports/* ./collected_reports/

 
    MultiQC ./collected_reports
    """
}