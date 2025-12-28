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
include { MEDAKA_FLYE }      from './modules/medaka.nf'
include { DORADO_POLISH }    from './modules/dorado.nf'
include { FILTLONG }         from './modules/filtlong.nf'
include { CHOPPER }          from './modules/chopper.nf'
include { DNAAPLER }         from './modules/dnaapler.nf'

include { FLYE }             from './modules/flye.nf'
include { BARRNAP }          from './modules/barrnap.nf'

include { BUSCO }            from './modules/busco.nf'
include { CHECKM }           from './modules/checkm.nf'
include { CHECKM2 }          from './modules/checkm2.nf'
include { QUAST }            from './modules/quast.nf'
include { INSPECTOR }        from './modules/inspector.nf'
include { CRAQ }             from './modules/craq.nf'

include { BAKTA }            from './modules/bakta.nf'

include { MULTIQC }          from './modules/multiqc.nf'

include { KRAKEN2 }          from './modules/kraken2.nf'

include { SKANI_CLASSIFICATION } from './modules/skani.nf'

workflow {

    ch_input = channel
    .fromPath('./test/samplesheet.tsv')
    .splitCsv(sep: '\t', header:true)

    //ch_input.view()

    //Create empty channels for optional modules

    kraken2_ch = channel.empty()
    checkm_ch = channel.empty()
    checkm2_ch = channel.empty()
    BUSCO_ch = channel.empty()
    QUAST_ch = channel.empty()
    bakta_ch = channel.empty() 

    // NANOPLOT on raw reads

    nanoplot_raw_ch = NANOPLOT_RAW(ch_input)

    // Porechop trimming

    porechop_ch = PORECHOP(ch_input)

    // OPTIONAL FILTERING STEP: filtlong / chopper / none

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

    // Continue workflow using filtered_ch*

    // NANOPLOT on filtered reads

    nanoplot_ch = NANOPLOT(filtered_ch)

    // Kraken2 for contamination check

    if (params.run_kraken2) {

    channel
    .fromPath(params.kraken2_DB)
    .set { kraken2_db }    

    kraken2_ch = KRAKEN2(filtered_ch, kraken2_db)

    }

    // Assembly workflow

    if (params.assembler == 'autocycler') {

    log.info "Using Autocycler assembler"

    // Start autocycler workflow

    genome_size_ch = GET_GENOME_SIZE(filtered_ch)

    subsampled_ch = SUBSAMPLE(genome_size_ch)

    // Create assembly jobs

    assemblers = params.assembler_list.split(',')*.trim()

    samples = (1..params.n_samples).collect { num -> String.format('%02d', num)}

    println samples

    assembly_jobs = channel
        .from(assemblers)
        .combine(channel.from(samples))
        .map { assembler, sample -> tuple(assembler,sample) }

    assembly_jobs_input = assembly_jobs.combine(subsampled_ch)

    channel
    .fromPath(params.plassembler_DB)
    .set { plassembler_DB }

    assembly_out = ASSEMBLE(assembly_jobs_input, plassembler_DB)

    // Collect assemblies by sampleID

    collected_assemblies = assembly_out.groupTuple()

    // Compress assemblies into autocycler format

    compressed = COMPRESS(collected_assemblies)

    // Cluster assemblies

    clustered = CLUSTER(compressed)

    // Resolve clusters

    resolved_clusters = RESOLVE_CLUSTERS(clustered)

    // Final output

    final_assembly_ch = COMBINE(resolved_clusters)

    } else if (params.assembler == 'flye') {

        log.info "Using Flye assembler only"
        final_assembly_ch = FLYE(filtered_ch)

    } else {
        error "Unknown assembler option: ${params.assembler}. Use 'autocycler' or 'flye'"
    }

    // Optional longread polishing with medaka

   if (params.polishing_tool == 'medaka' && params.assembler == 'autocycler') {
        log.info "Medaka polishing selected"
        polish_input_ch = final_assembly_ch.autocycler_folder.combine(filtered_ch, by: 0) // combine by sample ID otherwise reads and assemblies get mixed up
        final_genomes_ch = MEDAKA(polish_input_ch)

    }  else if (params.polishing_tool == 'medaka' && params.assembler == 'flye') {
        log.info "Medaka polishing selected"
        polish_input_ch = final_assembly_ch.combine(filtered_ch, by: 0) // combine by sample ID otherwise reads and assemblies get mixed up
        final_genomes_ch = MEDAKA_FLYE(polish_input_ch)

    } else if (params.polishing_tool == 'none') {
        log.info "No polishing applied"
        final_genomes_ch = final_assembly_ch

    } else {
        error "Unknown polishing option: ${params.polishing_tool}. Use 'medaka' or 'none'"
    }

    // Reorientation with DNAAPLER

    reoriented_genomes_ch = DNAAPLER(final_genomes_ch.genomes_keyed)

    // End of assembly and polishing workflow

    // Genome quality assessment modules


    if (params.run_CHECKM) {

    channel
    .fromPath(params.checkm_DB)
    .set { checkm_db }

    reoriented_genomes_collected_ch = reoriented_genomes_ch.only_genomes.collect()

    checkm_ch = CHECKM(reoriented_genomes_collected_ch, checkm_db)

    }

    if (params.run_CHECKM2) {

    channel
    .fromPath(params.checkm2_DB)
    .set { checkm2_db }

    reoriented_genomes_collected_ch = reoriented_genomes_ch.only_genomes.collect()

    checkm2_ch = CHECKM2(reoriented_genomes_collected_ch, checkm2_db)

    }
    
    if (params.run_BUSCO) {

    channel
    .fromPath(params.BUSCO_DB)
    .set { BUSCO_db }

    reoriented_genomes_collected_ch = reoriented_genomes_ch.only_genomes.collect()

    BUSCO_ch = BUSCO(reoriented_genomes_collected_ch, BUSCO_db)

    }

    if (params.run_QUAST) {

    reoriented_genomes_collected_ch = reoriented_genomes_ch.only_genomes.collect()

    QUAST_ch = QUAST(reoriented_genomes_collected_ch)

    }

    if (params.run_INSPECTOR) {

    INSPECTOR(reoriented_genomes_ch.genomes_keyed.combine(filtered_ch, by: 0))

    }

    if (params.run_CRAQ) {

    CRAQ(reoriented_genomes_ch.genomes_keyed.combine(filtered_ch, by: 0))

    }

     // Annotation module & taxonomic classification modules

    if (params.run_bakta) {

    channel
    .fromPath(params.bakta_DB)
    .set { BAKTA_db }

    bakta_ch = BAKTA(reoriented_genomes_ch.genomes_keyed,BAKTA_db)

    }

    if (params.run_barrnap) {

    BARRNAP(reoriented_genomes_ch.genomes_keyed)

    }

    if (params.run_skani) {

    reoriented_genomes_collected_ch = reoriented_genomes_ch.only_genomes.collect()

    SKANI_CLASSIFICATION(reoriented_genomes_collected_ch)

    }

    // Generate MultiQC report

    MULTIQC(
        porechop_ch.log.collect().ifEmpty([]),
        nanoplot_ch.nanoplot_stats.collect().ifEmpty([]),
        nanoplot_raw_ch.nanoplot_stats.collect().ifEmpty([]),
        checkm_ch.ifEmpty([]),
        checkm2_ch.ifEmpty([]),
        BUSCO_ch.ifEmpty([]),
        QUAST_ch.ifEmpty([]),
        bakta_ch.bakta_summary.collect().ifEmpty([]),
        kraken2_ch.collect().ifEmpty([])
    )


}