import pandas as pd
import os
import argparse

def annotate_polya(nanopolish_input, gtf_input, output_dir, gtf_columns=None):
    """
    Annotates nanopolish polyA results using GTF information

    Parameters:
    - nanopolish_input: path to nanopolish polya TSV file
    - gtf_input: path to GTF file
    - output_dir: directory to save the annotated output file
    - gtf_columns: list of column names for the GTF file.
    """

    # default column names for GTF if not provided
    default_gtf_columns = ['chr', 'start', 'end', 'strand', 'gene_id', 'transcript_id', 'gene_name', 'gene_ann', 'transcript_name', 'transcript_ann']
    
    # use user-defined column names if given, else use defaults
    gtf_columns = gtf_columns if gtf_columns else default_gtf_columns
    
    # read nanopolish polya input file
    nanopolish_df = pd.read_csv(nanopolish_input, sep="\t")
    nanopolish_df.rename(columns={"contig": "transcript_id"}, inplace=True)

    # filter by QC tag
    filtered_df = nanopolish_df[nanopolish_df["qc_tag"] == "PASS"]
    filtered_df["transcript_id"] = filtered_df["transcript_id"].str.split(".").str[0]

    # read GTF file
    gtf_df = pd.read_csv(gtf_input, sep='\t', names=gtf_columns, low_memory=False)
    
    # merge the data to annotate
    merged_df = filtered_df.merge(gtf_df, on='transcript_id', how='left')

    # save the output
    output_path = os.path.join(output_dir, "nanopolish_annotated.tsv")
    merged_df.to_csv(output_path, sep='\t', index=False)
    print(f"Annotated file saved to {output_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Annotate Nanopolish PolyA results")
    parser.add_argument('--input', required=True, help="Path to Nanopolish polya TSV file")
    parser.add_argument('--gtf', required=True, help="Path to GTF file")
    parser.add_argument('--output_dir', required=True, help="Directory to save the annotated output file")
    parser.add_argument('--gtf_columns', nargs='+', default=None, help="List of column names in the GTF file (space-separated)")
    
    args = parser.parse_args()

    # call the function with the parsed arguments
    annotate_polya(args.input, args.gtf, args.output_dir, args.gtf_columns)
    
