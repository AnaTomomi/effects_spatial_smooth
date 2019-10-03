#!/bin/bash -l
#SBATCH --time=01:00:00 
#SBATCH --mem-per-cpu=4096
#SBATCH -p debug
#SBATCH -o job-%a.out
#SBATCH --array=0-159
module load matlab
matlab -nojvm -r "my_slurm_permutations($SLURM_ARRAY_TASK_ID); quit"
