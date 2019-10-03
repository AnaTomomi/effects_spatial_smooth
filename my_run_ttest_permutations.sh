#!/bin/bash 
#SBATCH -t 03:30:00
#SBATCH -n 1
#SBATCH --mem 10000
#SBATCH -o job-%a.out
#SBATCH --array=0-159

module load matlab
matlab -nojvm -r "my_run_ttest_permutations($SLURM_ARRAY_TASK_ID); quit"
