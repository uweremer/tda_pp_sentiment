#!/bin/bash

#SBATCH --nodes=2
#SBATCH --ntasks=16
#SBATCH --time=24:00:00
#SBATCH --mem=64gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=uwe.remer@sowi.uni-stuttgart.de
#SBATCH --output=job.out
#SBATCH --error=job.error
#SBATCH --job-name=RauhSent

module load math/R/4.1.2
Rscript --vanilla batch_pipeline.R
