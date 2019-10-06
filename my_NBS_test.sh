#!/bin/bash -l
#SBATCH --time=00:35:00 
#SBATCH --mem-per-cpu=4096
#SBATCH -p debug
#SBATCH -o job-%a.out
#SBATCH --array=0-127

module load matlab
matlab -nodesktop -nosplash -nojvm -r "cd('/m/cs/scratch/networks/trianaa1/Paper1/smoothing-group');  my_NBS_test($SLURM_ARRAY_TASK_ID); quit"

