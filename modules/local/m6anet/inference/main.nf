process M6ANET_INFERENCE {
	tag "$meta.id"
	label 'process_medium'

	conda "bioconda::m6anet==2.1.0"
	container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
	'https://depot.galaxyproject.org/singularity/m6anet:2.1.0--pyhdfd78af_0' :
	'quay.io/biocontainers/m6anet:2.1.0--pyhdfd78af_0' }"

	input:
	tuple val(meta), path(gtf)
	path(dataprep)
	
	output:
	tuple val(meta), path("${meta.id}/m6A/m6Anet_inference"), emit: inference
	path "versions.yml", emit: versions

	script:
	"""
	m6anet inference --input_dir $dataprep --out_dir ${meta.id}/m6A/m6Anet_inference --n_processes ${params.n_processes} --num_iterations ${params.num_iterations}

	// run annotation script
	python ${projectDir}/bin/m6A_annotate.py \\
	   --input m6Anet_inference/data.site_proba.csv \\
	   --gtf $gtf \\
	   --output_dir ${meta.id}/m6A

	cat <<-END_VERSIONS > versions.yml
    	"${task.process}":
        	m6anet: \$( echo 'm6anet 2.1.0' )
    	END_VERSIONS
    	""" 
}
