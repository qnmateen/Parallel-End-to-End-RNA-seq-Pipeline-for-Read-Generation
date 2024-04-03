#!/bin/bash

# Install bioinformatics tools with the latest versions
conda install -c bioconda -y fastqc
conda install -c bioconda -y trimmomatic
conda install -c bioconda -y star
conda install -c bioconda -y subread # featureCounts is part of subread
conda install -c bioconda -y sra-tools

# Deactivate the environment
conda deactivate

echo "Installation completed. Use 'conda activate env name to activate the environment."
