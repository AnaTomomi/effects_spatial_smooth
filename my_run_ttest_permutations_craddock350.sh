#!/bin/bash 
#SBATCH -t 27:30:00
#SBATCH -n 1
#SBATCH --mem-per-cpu=6000
#SBATCH -o /m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/Craddock350_jobs/job-extra-%a.out
#SBATCH --array=0-32

module load matlab
matlab -nojvm -r "my_run_ttest_permutations_craddock350($SLURM_ARRAY_TASK_ID); quit"
