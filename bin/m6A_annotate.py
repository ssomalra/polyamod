import pandas as pd
import os
import argparse

def annotate_m6A(inference_input, gtf_input, output_dir, gtf_columns=None):
    """
    Annotates m6anet m6A modification prediction results using GTF information.
    Parameters:
    - inference_input: path to m6anet inference data.site_proba.csv file
    - gtf_input: path to GTF file
    - output_dir: directory to save the annotated output file
    - gtf_columns: list of column names for the GTF file.
    """

    # default column names for GTF if not provided
    default_gtf_columns = ['chr', 'start', 'end', 'strand', 'gene_id', 'transcript_id', 'gene_name', 'gene_ann', 'transcript_name', 'transcript_ann']
    
    # use user-defined column names if given, else use defaults
    gtf_columns = gtf_columns if gtf_columns else default_gtf_columns

    # read the m6A inference input file
    m6a_df = pd.read_csv(inference_input)
    m6a_df.rename(columns={"transcript_position": "m6A_start"}, inplace=True)

    # remove decimal point in transcript ID
    m6a_df["transcript_id"] = m6a_df["transcript_id"].str.split(".").str[0]

    # calculate end coordinate
    m6a_df.insert(2, "m6A_end", m6a_df["m6A_start"]+1)

    # read GTF file
    gtf_df = pd.read_csv(gtf_input, sep="\t", names=gtf_columns, low_memory=False)

    # merge the data to annotate
    merged_df = m6a_df.merge(gtf_df, on='transcript_id', how='left')

    # move the columns
    # make chr the first column
    cols = list(merged_df.columns)

    if 'chr' in cols: 
        cols.remove('chr')
        cols.insert(0, 'chr')

    # move transcript_id 
    if 'transcript_id' in cols and 'transcript_name' in cols:
        cols.remove('transcript_id')
        idx = cols.index('transcript_name')
        cols.insert(idx, 'transcript_id')

    # reorder dataframe
    merged_df = merged_df[cols]

    # save the output
    output_path = os.path.join(output_dir, "m6a_annotated.tsv")
    merged_df.to_csv(output_path, sep='\t', index=False)
    print(f"Annotated file saved to {output_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Annotate m6Anet m6A modification results")
    parser.add_argument('--input', required=True, help="Path to data.site_proba.csv file from m6anet inference")
    parser.add_argument('--gtf', required=True, help="Path to GTF file")
    parser.add_argument('--output_dir', required=True, help="Directory to save the annotated output file")
    parser.add_argument('--gtf_columns', nargs='+', default=None, help="List of column names in the GTF file (space-separated)")

    args = parser.parse_args()

    # call the function with the parsed arguments
    annotate_m6A(args.input, args.gtf, args.output_dir, args.gtf_columns)
