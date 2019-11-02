#!/bin/bash -l
#SBATCH --time=00:55:00 
#SBATCH --mem-per-cpu=4096
#SBATCH -p debug
#SBATCH -o /m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD07/NBS/Craddock100_jobs/job-sph-%a.out
#SBATCH --array=0-127

module load matlab
matlab -nodesktop -nosplash -nojvm -r "cd('/m/cs/scratch/networks/trianaa1/Paper1/smoothing-group');  my_NBS_test_craddock100($SLURM_ARRAY_TASK_ID); quit"

