nextflow.enable.dsl=2

include { GET_GENOME_SIZE }  from './modules/get_genome_size.nf'
include { SUBSAMPLE }        from './modules/subsample.nf'
include { ASSEMBLE }         from './modules/assemble.nf'
include { COMPRESS }         from './modules/compress.nf'
include { CLUSTER }          from './modules/cluster.nf'
include { RESOLVE_CLUSTERS } from './modules/resolve_cluster.nf'
include { COMBINE }          from './modules/combine.nf'

workflow {

    reads_ch = channel.fromPath(params.reads)
    reads_ch.view { it -> println "reads_ch item: $it" }

    genome_size_ch = GET_GENOME_SIZE(reads_ch).map { f -> f.text.trim() }

    subsampled_ch = SUBSAMPLE(reads_ch, genome_size_ch)

    assemblers = [
        'canu','flye','metamdbg','miniasm',
        'necat','nextdenovo','plassembler','raven'
    ]
    samples = ["01","02","03","04"]

    assembly_jobs = channel
        .from(assemblers)
        .combine(channel.from(samples))
        .map { assembler, sample -> tuple(assembler,sample) }

    assembly_out = ASSEMBLE(assembly_jobs, subsampled_ch, genome_size_ch)

    compressed = COMPRESS(assembly_out)

    clustered = CLUSTER(compressed)

    cluster_dirs = channel.fromPath("${params.outdir}/clustering/qc_pass/cluster_*")

    resolved_clusters = RESOLVE_CLUSTERS(cluster_dirs)

    COMBINE(clustered, resolved_clusters)
}