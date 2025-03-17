/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { GUPPY_BASECALL         } from '../modules/local/guppy/main.nf' 
include { PREP_FASTQ             } from '../modules/local/prep_fastq/main.nf'  
include { F5C_INDEX              } from '../modules/local/f5c/index/main.nf'
include { MINIMAP2_ALIGN         } from '../modules/local/minimap/main.nf'
include { SAMTOOLS_FLAGSTAT_VIEW } from '../modules/local/samtools/flagstat_view/main.nf'
include { SAMTOOLS_SORT		 } from '../modules/local/samtools/sort/main.nf'
include { SAMTOOLS_INDEX	 } from '../modules/local/samtools/index/main.nf'
include { NANOPOLISH_POLYA 	 } from '../modules/local/nanopolish/main.nf'
include { F5C_EVENTALIGN	 } from '../modules/local/f5c/eventalign/main.nf'
include { M6ANET_DATAPREP	 } from '../modules/local/m6anet/dataprep/main.nf'
include { M6ANET_INFERENCE	 } from '../modules/local/m6anet/inference/main.nf'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_polyamod_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow POLYAMOD {

    take:
    ch_samplesheet // channel: samplesheet read in from --input
    
    main:
    ch_versions = Channel.empty()

    //
    // MODULE: Run Guppy
    // 
    GUPPY_BASECALL {
	ch_samplesheet.map{sample,fast5_dir,flowcell_id,sequencing_kit,reference_genome,gtf -> tuple(sample,fast5_dir,flowcell_id,sequencing_kit)}
    }

    //
    // MODULE: Convert fastq to fasta
    //        
    PREP_FASTQ {
        GUPPY_BASECALL.out.guppy_out
    }

    //
    // MODULE: Run f5c index
    //
    F5C_INDEX {
	ch_samplesheet.map{sample,fast5_dir,flowcell_id,sequencing_kit,reference_genome,gtf -> tuple(sample,fast5_dir)}
	PREP_FASTQ.out.fasta
    }

    //
    // MODULE: Run minimap2 
    //
    MINIMAP_ALIGN {
        ch_samplesheet.map{sample,fast5_dir,flowcell_id,sequencing_kit,reference_genome,gtf -> tuple(sample,reference_genome)}
	PREP_FASTQ.out.fasta
    }

    //
    // MODULE: Samtools flagstat and view
    // 
    SAMTOOLS_FLAGSTAT_VIEW {
	MINIMAP_ALIGN.out.sam
    }

    // 
    // MODULE: Samtools sort
    //
    SAMTOOLS_SORT {
	SAMTOOLS_FLAGSTAT_VIEW.out.bam
    }

    //
    // MODULE: Samtools index
    //
    SAMTOOLS_INDEX {
	SAMTOOLS_SORT.out.sorted_bam
    }

    //
    // MODULE: Run nanopolish poly(A)
    // 
    NANOPOLISH_POLYA {
        ch_samplesheet.map{sample,fast5_dir,flowcell_id,sequencing_kit,reference_genome,gtf -> tuple(sample,reference_genome,gtf)},
	PREP_FASTQ.out.fasta,
	SAMTOOLS_SORT.out.sorted_bam
    }

    //
    // MODULE: Run f5c eventalign
    // 
    F5C_EVENTALIGN {
	ch_samplesheet.map{sample,fast5_dir,flowcell_id,sequencing_kit,reference_genome,gtf -> tuple(sample,reference_genome)},
	PREP_FASTQ.out.fasta,
	SAMTOOLS_SORT.out.sorted_bam
    }

    //
    // MODULE: Run m6anet dataprep
    //
    M6ANET_DATAPREP {
 	F5C_EVENTALIGN.out.eventalign_output
    }

    //
    // MODULE: Run m6anet inference
    //
    M6ANET_INFERENCE {
	ch_samplesheet.map{sample,fast5_dir,flowcell_id,sequencing_kit,reference_genome,gtf -> tuple(sample,gtf)},
	M6ANET_DATAPREP.out.dataprep
    }

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'polyamod_software_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    emit:
    versions       = ch_versions                 // channel: [ path(versions.yml) ]

}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
