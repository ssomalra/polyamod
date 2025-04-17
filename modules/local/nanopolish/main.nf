process NANOPOLISH_POLYA {
	tag "$meta.id"
	label "process_high"

	conda "bioconda::nanopolish=0.14.0"
	container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
	'https://depot.galaxyproject.org/singularity/nanopolish:0.14.0--hee927d3_5' :
	'quay.io/biocontainers/nanopolish:0.14.0--hee927d3_5' }"

	input:
	tuple val(meta), path(reference_genome), path(gtf)
	path(fasta)
	path(sorted_bam)

	output:
	tuple val(meta), path("${meta.id}_nanopolish_polya.tsv"), emit: nanopolish_polya
	tuple val(mtea), path("${meta.id}_nanopolish_annotated.tsv"), emit: annotated_polya
	path "versions.yml", emit: versions

	script:
	"""
	// run nanopolish polya
	nanopolish polya --reads $fasta --bam=$sorted_bam --genome=$reference_genome > ${meta.id}_nanopolish_polya.tsv

	// run annotation script
	python ${projectDir}/bin/polya_annotate.py \\
	   --input nanopolish_polya.tsv \\
	   --gtf $gtf
	   --gtf_columns ${params.gtf_columns.join(" ")}

	cat <<-END_VERSIONS > versions.yml
        "${task.process}":
                nanopolish: \$(nanopolish --version | head -n 1)
        END_VERSIONS
        """
}
