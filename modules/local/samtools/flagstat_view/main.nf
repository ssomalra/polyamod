process SAMTOOLS_FLAGSTAT_VIEW {
	tag "$meta.id"
	label 'process_medium'

	conda "bioconda::samtools=1.21"
	container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
	'https://depot.galaxyproject.org/singularity/samtools:1.21--h96c455f_1' :
	'quay.io/biocontainers/samtools:1.21--h96c455f_1' }"

	input:
	tuple val(meta), path(sam) 

	output:
	tuple val(meta), path("${meta.id}/input_files/${params.output_name}.bam"), emit: bam 
	path (${meta.id}/input_files/"alignment_summary.txt"), emit: flagstat
	path "versions.yml", emit: versions

	script:
	"""
	samtools flagstat $sam > ${meta.id}/input_files/alignment_summary.txt
	samtools view -hSB $sam > ${meta.id}/input_files/${params.output_name}.bam

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
 		samtools: \$(samtools --version | head -n 1)
    	END_VERSIONS
    	"""
}
