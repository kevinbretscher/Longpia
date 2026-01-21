nextflow.enable.dsl=2

include { RHIZOSMASH }         from './modules/rhizosmash.nf'

workflow {

    channel
        .fromPath("${params.fasta_dir}/*.{fa,fasta,fna}")
        .set { fasta_ch }


    RHIZOSMASH(fasta_ch)
}