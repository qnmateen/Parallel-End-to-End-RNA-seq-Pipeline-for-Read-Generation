#!/bin/bash

# Define your conda environment name
ENV_NAME="rnaseq-tools"

# Create a new conda environment
conda create -n $ENV_NAME -y

# Activate the environment
conda activate $ENV_NAME

# Install bioinformatics tools with the latest versions
conda install -c bioconda -y fastqc
conda install -c bioconda -y trimmomatic
conda install -c bioconda -y star
conda install -c bioconda -y subread # featureCounts is part of subread
conda install -c bioconda -y sra-tools

# Deactivate the environment
conda deactivate

echo "Installation completed. Use 'conda activate $ENV_NAME' to activate the environment."
