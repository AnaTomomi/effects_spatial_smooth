#!/bin/bash 
#SBATCH -t 27:30:00
#SBATCH -n 1
#SBATCH --mem-per-cpu=6000
#SBATCH -o /m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/Permutations/Brainnetome_jobs/job-extra-%a.out
#SBATCH --array=0-32

module load matlab
matlab -nojvm -r "my_run_ttest_permutations($SLURM_ARRAY_TASK_ID); quit"
