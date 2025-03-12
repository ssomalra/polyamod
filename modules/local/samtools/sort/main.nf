process SAMTOOLS_SORT {
	tag "samtools_sort"
	label 'process_medium'

	conda "bioconda::samtools=1.21"
	container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
	'https://depot.galaxyproject.org/singularity/samtools:1.21--h96c455f_1' :
	'quay.io/biocontainers/samtools:1.21--h96c455f_1' }"

	input:
	tuple val(meta), path(bam) 

	output:
	tuple val(meta), path("${meta.id}/input_files/${params.output_name}.sorted.bam"), emit: sorted_bam 
	path "versions.yml", emit: versions

	script:
	"""
	samtools sort $bam -o ${meta.id}/input_files/{params.output_name}.sorted.bam

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
 		samtools: \$(samtools --version | head -n 1)
    	END_VERSIONS
    	"""
}
