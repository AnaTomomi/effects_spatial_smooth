#!/bin/bash -l
#SBATCH --time=00:55:00 
#SBATCH --mem-per-cpu=4096
#SBATCH -p debug
#SBATCH -o /m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/Brainnetome_jobs/job-we%a.out
#SBATCH --array=0-159
module load matlab
matlab -nojvm -r "my_slurm_permutations($SLURM_ARRAY_TASK_ID); quit"
