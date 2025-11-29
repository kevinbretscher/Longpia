process CRAQ {
    tag "NANOPLOT"
    label 'process_low'

    input:
    tuple val(meta), path(ontfile)

    output:
    tuple val(meta), path(ontfile)
    
    when:
    task.ext.when == null || task.ext.when

    script:
    """
    NanoPlot \\
        $args \\
        -t $task.cpus \\
        $input_file
    """
}