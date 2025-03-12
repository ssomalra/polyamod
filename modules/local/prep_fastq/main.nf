process PREP_FASTQ {
	tag "$meta.id"
	label 'process_low'

	input:
	tuple val(meta), path(guppy_out) // directory containing 'pass' FASTQ files

	output:
	tuple val(meta), path("${meta.id}/input_files/${params.merged_output}.fastq"), emit: fastq
 	tuple val(meta), path("${meta.id}/input_files/${params.merged_output}.fasta"), emit: fasta

	script:
	"""
	mkdir -p ${meta.id}/input_files

	// Merge FASTQ files from the 'pass' directory
	cat ${guppy_out}/pass/*.fastq > ${meta.id}/input_files/${params.output_name}.fastq

	// Convert merged FASTQ to FASTA format
	sed -n '1~4s/^@/>/p;2~4p' ${meta.id}/input_files/${params.output_name}.fastq > ${meta.id}/input_files/${params.output_name}.fasta
}
