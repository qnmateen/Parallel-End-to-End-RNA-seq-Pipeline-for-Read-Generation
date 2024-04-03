#!/bin/bash

#PBS -N RNAseqAnalysis
#PBS -o pipeline_output.log
#PBS -e pipeline_error.log
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=128:mem=200gb
#PBS -J 1-16%4

function error_exit {
  echo "[ERROR] $1. Exiting." >&2
  exit 1
}

# Load modules
module load fastqc/0.11.9 || error_exit "Failed to load FastQC module"
module load trimmomatic/0.39 || error_exit "Failed to load Trimmomatic module"
module load star/2.7.9a || error_exit "Failed to load STAR module"
module load featurecounts/2.0.1 || error_exit "Failed to load featureCounts module"

# Set paths
input_dir="/path/to/input/data"
qc_dir="/path/to/fastqc/results"
trimmed_dir="/path/to/trimmed/reads"
alignment_dir="/path/to/alignments"
counts_dir="/path/to/featurecounts"
star_index="/path/to/star_index"
genome_fasta="/path/to/human_reference.fa"
genome_gtf="/path/to/human_annotation.gtf"

# Ensure STAR index exists
if [ ! -d "$star_index" ]; then
  STAR --runThreadN 128 --runMode genomeGenerate \
       --genomeDir $star_index \
       --genomeFastaFiles $genome_fasta \
       --sjdbGTFfile $genome_gtf \
       --sjdbOverhang 100 || error_exit "STAR index build failed"
fi

# Retrieve sample ID based on PBS_ARRAY_INDEX
sample_id=$(sed -n "${PBS_ARRAY_INDEX}p" sample_list.txt) || error_exit "Failed to set sample ID"

# FastQC
fastqc -o $qc_dir -t 16 $input_dir/${sample_id}_1.fastq.gz $input_dir/${sample_id}_2.fastq.gz || error_exit "FastQC failed"

# Trimmomatic
java -jar trimmomatic-0.39.jar PE -threads 16 \
     $input_dir/${sample_id}_1.fastq.gz $input_dir/${sample_id}_2.fastq.gz \
     $trimmed_dir/${sample_id}_1P.fastq.gz $trimmed_dir/${sample_id}_1U.fastq.gz \
     $trimmed_dir/${sample_id}_2P.fastq.gz $trimmed_dir/${sample_id}_2U.fastq.gz \
     ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36 || error_exit "Trimmomatic failed"

# STAR Alignment
STAR --runThreadN 32 --genomeDir $star_index \
     --readFilesIn $trimmed_dir/${sample_id}_1P.fastq.gz $trimmed_dir/${sample_id}_2P.fastq.gz \
     --outFileNamePrefix $alignment_dir/${sample_id}_ \
     --outSAMtype BAM SortedByCoordinate || error_exit "STAR alignment failed"

# featureCounts
featureCounts -p -T 16 -t exon -g gene_id \
     -a $genome_gtf -o $counts_dir/${sample_id}.counts \
     $alignment_dir/${sample_id}_Aligned.sortedByCoord.out.bam || error_exit "featureCounts failed"

