#!/bin/bash
#SBATCH -p batch
#SBATCH -t 04:00:00
#SBATCH --qos=normal
#SBATCH --mem-per-cpu=10000
module load fsl/5.0.9
source $FSLDIR/etc/fslconf/fsl.sh

n=$SLURM_ARRAY_TASK_ID
number=`sed "${n}q;d" CALTECH_I.txt`
site=CALTECH_I
FWHM=4/2.35

#Input the folder in which the pre-preprocessing will be done
folder=/m/cs/scratch/networks/data/ABIDE_II/Forward/;
cd $folder

fslmaths ./Brainnetome_0mm/$site/${number}/epi_preprocessed.nii -kernel gauss $FWHM -fmean ./Brainnetome_6mm/$site/${number}/epi_preprocessed.nii

echo $PWD;
echo $FWHM
