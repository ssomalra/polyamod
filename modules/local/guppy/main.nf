process GUPPY_BASECALL {
	tag "$meta.id"
	label 'process_high'

	input:
	tuple val(meta), path(fast5_dir), val(flowcell_id), val(sequencing_kit)

	output:
	tuple val(meta), path("${meta.id}/guppy_out"), emit: guppy_out

	script:
	"""
	# ensure that guppy is in the path
	export PATH=\$PATH:${params.guppy_package}/bin

	# run guppy basecalling
	guppy_basecaller -i $fast5_dir -s ${meta.id}/guppy_out --flowcell $flowcell_id --kit $sequencing_kit --fast5_out --num_callers ${params.num_callers}
	"""
}
