process KALLISTOBUSTOOLS_COUNT {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::kb-python=0.25.1" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/kb-python:0.25.1--py_0' :
        'quay.io/biocontainers/kb-python:0.25.1--py_0' }"

    input:
    tuple   val(meta),  path(reads)
    path    index
    path    t2g
    path    t1c
    path    t2c
    val     use_t1c
    val     use_t2c
    val     workflow
    val     technology

    output:
    tuple val(meta), path ("*_kallistobustools_count*") , emit: counts
    path  "versions.yml"                                , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def cdna        = use_t1c ? "-c1 $t1c" : ''
    def introns     = use_t2c ? "-c2 $t2c" : ''
    """
    kb count \\
        -t $task.cpus \\
        -i $index \\
        -g $t2g \\
        $cdna \\
        $introns \\
        --workflow $workflow \\
        -x $technology \\
        $args \\
        -o ${prefix}_kallistobustools_count \\
        ${reads[0]} ${reads[1]}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        kallistobustools: \$(echo \$(kb 2>&1) | sed 's/^kb_python //; s/Usage.*\$//')
    END_VERSIONS
    """
}
