nextflow.enable.dsl=2

include { NANOPLOT }         from './modules/nanoplot.nf'
include { NANOPLOT_RAW }     from './modules/nanoplot.nf'
include { GET_GENOME_SIZE }  from './modules/get_genome_size.nf'
include { SUBSAMPLE }        from './modules/subsample.nf'
include { ASSEMBLE }         from './modules/assemble.nf'
include { COMPRESS }         from './modules/compress.nf'
include { CLUSTER }          from './modules/cluster.nf'
include { RESOLVE_CLUSTERS } from './modules/resolve_cluster.nf'
include { COMBINE }          from './modules/combine.nf'
include { PORECHOP }         from './modules/porechop.nf'
include { MEDAKA }           from './modules/medaka.nf'
include { DORADO_POLISH }    from './modules/dorado.nf'
include { FILTLONG }         from './modules/filtlong.nf'
include { CHOPPER }          from './modules/chopper.nf'
include { DNAAPLER }         from './modules/dnaapler.nf'

include { BUSCO }            from './modules/busco.nf'
include { CHECKM }           from './modules/checkm.nf'
include { CHECKM2 }          from './modules/checkm2.nf'
include { QUAST }            from './modules/quast.nf'
include { INSPECTOR }        from './modules/inspector.nf'
include { CRAQ }             from './modules/craq.nf'

include { BAKTA }            from './modules/bakta.nf'

include { MULTIQC }          from './modules/multiqc.nf'

workflow {

    ch_input = channel
    .fromPath('./test/samplesheet.tsv')
    .splitCsv(sep: '\t', header:true)

    //ch_input.view()

    // NANOPLOT on raw reads

    nanoplot_raw_ch = NANOPLOT_RAW(ch_input)

    // Porechop trimming

    porechop_ch = PORECHOP(ch_input)

    // ──────────────────────────────────────────────
    // OPTIONAL FILTERING STEP: filtlong / chopper / none
    // ──────────────────────────────────────────────

    if (params.filtering == 'filtlong') {
        log.info "Using Filtlong filtering"
        filtered_ch = FILTLONG(porechop_ch.trimmed_reads)
    } else if (params.filtering == 'chopper') {
        log.info "Using Chopper filtering"
        filtered_ch = CHOPPER(porechop_ch.trimmed_reads)
    } else if (params.filtering == 'none') {
        log.info "No filtering applied"
        filtered_ch = porechop_ch.trimmed_reads
    } else {
        error "Unknown filtering option: ${params.filtering}. Use 'none', 'filtlong', or 'chopper'"
    }

    // Continue workflow using *filtered_ch*

    // NANOPLOT on trimmed reads

    nanoplot_ch = NANOPLOT(filtered_ch)

    // Start autocycler workflow

    genome_size_ch = GET_GENOME_SIZE(filtered_ch)

    //genome_size_ch.view { it -> println "genome_size_ch item: $it" }

    subsampled_ch = SUBSAMPLE(genome_size_ch)

    //subsampled_ch.view { it -> println "subsampled_ch item: $it" }

    // Create assembly jobs

    assemblers = params.assembler_list.split(',')*.trim()
    //samples = ["01","02","03","04"]
    samples = (1..params.n_samples).collect { num -> String.format('%02d', num)}

    println samples

    assembly_jobs = channel
        .from(assemblers)
        .combine(channel.from(samples))
        .map { assembler, sample -> tuple(assembler,sample) }

    //assembly_jobs.view { it -> println "assembly_jobs item: $it" }

    assembly_jobs_input = assembly_jobs.combine(subsampled_ch)

    //assembly_jobs_input.view { it -> println "assembly_jobs_input item: $it" }

    channel
    .fromPath(params.plassembler_DB)
    .set { plassembler_DB }

    assembly_out = ASSEMBLE(assembly_jobs_input, plassembler_DB)

    //assembly_out.view { it -> println "assembly_out item: $it" }

    // Collect assemblies by sampleID

    collected_assemblies = assembly_out.groupTuple()

    //collected_assemblies.view { it -> println "collected_assemblies item: $it" }

    // Compress assemblies into autocycler format

    compressed = COMPRESS(collected_assemblies)

    //compressed.view { it -> println "compressed item: $it" }

    // Cluster assemblies

    clustered = CLUSTER(compressed)

    //cluster_dirs = channel.fromPath("${params.outdir}/clustering/qc_pass/cluster_*")

    resolved_clusters = RESOLVE_CLUSTERS(clustered)

    // Final output

    final_assembly_ch = COMBINE(resolved_clusters)

    //Longread polishing with medaka

    polish_input_ch = final_assembly_ch.combine(filtered_ch, by: 0) // combine by sample ID otherwise reads and assemblies get mixed up

    polished_genomes_ch = MEDAKA(polish_input_ch)

    // Reorientation with DNAAPLER

    reoriented_genomes_ch = DNAAPLER(polished_genomes_ch.medaka_polished_genomes_keyed)

    //End of assembly and polishing workflow

    // Genome quality assessment modules


    if (params.run_CHECKM) {

    channel
    .fromPath(params.checkm_DB)
    .set { checkm_db }

    polished_genomes_collected_ch = reoriented_genomes_ch.only_genomes.collect()

    checkm_ch = CHECKM(polished_genomes_collected_ch, checkm_db)

    }

    if (params.run_CHECKM2) {

    channel
    .fromPath(params.checkm2_DB)
    .set { checkm2_db }

    polished_genomes_collected_ch = reoriented_genomes_ch.only_genomes.collect()

    checkm2_ch = CHECKM2(polished_genomes_collected_ch, checkm2_db)

    }
    
    if (params.run_BUSCO) {

    channel
    .fromPath(params.BUSCO_DB)
    .set { BUSCO_db }

    polished_genomes_collected_ch = reoriented_genomes_ch.only_genomes.collect()

    BUSCO_ch = BUSCO(polished_genomes_collected_ch, BUSCO_db)

    }

    if (params.run_QUAST) {

    polished_genomes_collected_ch = reoriented_genomes_ch.only_genomes.collect()

    QUAST_ch = QUAST(polished_genomes_collected_ch)

    }

    if (params.run_INSPECTOR) {

    reoriented_genomes_ch.genomes_keyed.combine(filtered_ch, by: 0).view()   

    INSPECTOR(reoriented_genomes_ch.genomes_keyed.combine(filtered_ch, by: 0))

    }

    if (params.run_CRAQ) {

    reoriented_genomes_ch.genomes_keyed.combine(filtered_ch, by: 0).view()   

    CRAQ(reoriented_genomes_ch.genomes_keyed.combine(filtered_ch, by: 0))

    }
    


     // Annotation module

    if (params.run_bakta) {

    channel
    .fromPath(params.bakta_DB)
    .set { BAKTA_db }

    bakta_ch = BAKTA(reoriented_genomes_ch.genomes_keyed,BAKTA_db)

    }


    

    MULTIQC(
        porechop_ch.log.collect().ifEmpty([]),
        nanoplot_ch.nanoplot_stats.collect().ifEmpty([]),
        nanoplot_raw_ch.nanoplot_stats.collect().ifEmpty([]),
        checkm_ch.ifEmpty([]),
        checkm2_ch.ifEmpty([]),
        BUSCO_ch.ifEmpty([]),
        QUAST_ch.ifEmpty([]),
        bakta_ch.bakta_summary.collect().ifEmpty([])
    )


}