#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=30
#SBATCH --mem=32gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=uwe.remer@sowi.uni-stuttgart.de
#SBATCH --output=job.out
#SBATCH --error=job.error
#SBATCH --job-name=RauhSent

module load math/R/4.1.2
Rscript --vanilla batch_pipeline.R
