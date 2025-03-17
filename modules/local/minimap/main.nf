process MINIMAP2_ALIGN {
	tag "$meta.id"
	label 'process_medium'

	conda "bioconda::minimap2=2.17"
	container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/minimap2:2.17--hed695b0_3' :
        'quay.io/biocontainers/minimap2:2.17--hed695b0_3' }"

	input:
	tuple val(meta), path(reference_genome)
	path(fasta)

	output:
	tuple val(meta), path("${meta.id}_${params.output_name}.sam"), emit: sam
	path "versions.yml", emit: versions
	
	script:
	"""
    	minimap2 --secondary=no -a -x map-ont $fasta $reference_genome > ${meta.id}_${params.output_name}.sam

    	cat <<-END_VERSIONS > versions.yml
    	"${task.process}":
        	minimap2: \$(minimap2 --version 2>&1)
    	END_VERSIONS
    	"""	
}
