nextflow.enable.dsl=2

include { NANOPLOT }         from './modules/nanoplot.nf'
include { GET_GENOME_SIZE }  from './modules/get_genome_size.nf'
include { SUBSAMPLE }        from './modules/subsample.nf'
include { ASSEMBLE }         from './modules/assemble.nf'
include { COMPRESS }         from './modules/compress.nf'
include { CLUSTER }          from './modules/cluster.nf'
include { RESOLVE_CLUSTERS } from './modules/resolve_cluster.nf'
include { COMBINE }          from './modules/combine.nf'
include { PORECHOP }         from './modules/porechop.nf'
include { MEDAKA }           from './modules/medaka.nf'

include { BUSCO }            from './modules/busco.nf'
include { CHECKM }           from './modules/checkm.nf'
include { CHECKM2 }          from './modules/checkm2.nf'
include { INSPECTOR }        from './modules/inspector.nf'
include { CRAQ }             from './modules/craq.nf'
include { MULTIQC }          from './modules/multiqc.nf'

workflow {

    ch_input = channel
    .fromPath('./test/samplesheet.tsv')
    .splitCsv(sep: '\t', header:true)

    ch_input.view()

    porechop_ch = PORECHOP(ch_input)

    // NANOPLOT on trimmed reads

    nanoplot_ch = NANOPLOT(porechop_ch.trimmed_reads)

    // Start autocycler workflow

    genome_size_ch = GET_GENOME_SIZE(porechop_ch.trimmed_reads)

    genome_size_ch.view { it -> println "genome_size_ch item: $it" }

    subsampled_ch = SUBSAMPLE(genome_size_ch)

    subsampled_ch.view { it -> println "subsampled_ch item: $it" }

    // Create assembly jobs

    assemblers = [
        'flye'
    ]
    samples = ["01","02","03","04"]

    assembly_jobs = channel
        .from(assemblers)
        .combine(channel.from(samples))
        .map { assembler, sample -> tuple(assembler,sample) }

    assembly_jobs.view { it -> println "assembly_jobs item: $it" }

    assembly_jobs_input = assembly_jobs.combine(subsampled_ch)

    assembly_jobs_input.view { it -> println "assembly_jobs_input item: $it" }

    assembly_out = ASSEMBLE(assembly_jobs_input)

    assembly_out.view { it -> println "assembly_out item: $it" }

    // Collect assemblies by sampleID

    collected_assemblies = assembly_out.groupTuple()

    collected_assemblies.view { it -> println "collected_assemblies item: $it" }

    // Compress assemblies into autocycler format

    compressed = COMPRESS(collected_assemblies)

    compressed.view { it -> println "compressed item: $it" }

    // Cluster assemblies

    clustered = CLUSTER(compressed)

    //cluster_dirs = channel.fromPath("${params.outdir}/clustering/qc_pass/cluster_*")

    resolved_clusters = RESOLVE_CLUSTERS(clustered)

    // Final output

    final_assembly_ch = COMBINE(resolved_clusters)

    //Longread polishing with medaka

    polished_genomes_ch = MEDAKA(porechop_ch.trimmed_reads, final_assembly_ch)

    //End of assembly and polishing workflow

    // Genome quality assessment modules

    if (params.run_CHECKM) {

    polished_genomes_collected_ch = polished_genomes_ch.collect()

    checkm_ch = CHECKM(polished_genomes_collected_ch)

    }

    if (params.run_CHECKM2) {

    polished_genomes_collected_ch = polished_genomes_ch.collect()

    checkm2_ch = CHECKM2(polished_genomes_collected_ch)

    }
    
    if (params.run_BUSCO) {

    polished_genomes_collected_ch = polished_genomes_ch.collect()

    BUSCO_ch = BUSCO(polished_genomes_collected_ch)

    }
    
    //MULTIQC()

    MULTIQC(
        porechop_ch.log.collect().ifEmpty([]),
        nanoplot_ch.nanoplot_stats.collect().ifEmpty([]),
        checkm_ch.ifEmpty([]),
        checkm2_ch.ifEmpty([]),
        BUSCO_ch.ifEmpty([])
    )

    

    if (params.run_annotation_plus_module) {

    //polished_genomes_collected_ch = polished_genomes_ch.collect()
    
    //INSPECTOR(polished_genomes_ch)

    //CRAQ(polished_genomes_ch)

    }

    // Annotation module

    if (params.run_annotation_module) {

    //polished_genomes_collected_ch = polished_genomes_ch.collect()
    // Annotation module can be added here

    }
}