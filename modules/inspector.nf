process INSPECTOR {
    tag "INSPECTOR"
    container "Containers/inspector"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(polished_genomes)

    output:
    path('INSPECTOR')

    script:

    """
    mkdir -p Polished_Assemblies
    mv $polished_genomes/*_medaka.fa Polished_Assemblies/

    inspector.py [-h] -c contig.fa -r raw_reads.fa -o output_dict/
    """
}