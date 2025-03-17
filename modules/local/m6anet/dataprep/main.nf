process M6ANET_DATAPREP {
	tag "$meta.id"
	label 'process_medium'

	conda "bioconda::m6anet==2.1.0"
	container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
	'https://depot.galaxyproject.org/singularity/m6anet:2.1.0--pyhdfd78af_0' :
	'quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0' }"

	input:
	tuple val(meta), path(eventalign_output)
	
	output:
	tuple val(meta), path("${meta.id}_m6Anet_dataprep"), emit: dataprep
	path "versions.yml", emit: versions

	script:
	m6anet dataprep --eventalign $eventalign_output --out_dir ${meta.id}_m6Anet_dataprep --n_processes ${params.n_processes}

	cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        m6anet: \$( echo 'm6anet 2.1.0' )
    END_VERSIONS
    """ 
}
