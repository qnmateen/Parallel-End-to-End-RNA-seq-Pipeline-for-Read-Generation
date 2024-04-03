#!/bin/bash 

# Replace with the path to your fastq-dump executable if not in your PATH
fastq_dump_path="/path/to/your/fastq-dump" 

# Set the desired output directory
output_dir="/path/to/output/directory"

# Read SRR IDs from the file and download
while read srr_id; do
    $fastq_dump_path --outdir $output_dir --split-files $srr_id
done < SRR_Acc_List.txt
