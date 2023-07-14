#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=10
#SBATCH --mem=180gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=mail-address
#SBATCH --output=job.out
#SBATCH --error=job.error
#SBATCH --job-name=RauhSent

module load R
Rscript --vanilla batch_pipeline.R