#!/bin/bash 
#SBATCH -t 03:30:00
#SBATCH -n 1
#SBATCH --mem 10000
#SBATCH -o P4mm.out
module load matlab
srun matlab -nojvm -nosplash -r "my_run_ttest_permutations ; exit(0)"
