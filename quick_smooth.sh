#!/bin/bash
#SBATCH -p batch
#SBATCH -t 04:00:00
#SBATCH --qos=normal
#SBATCH --mem-per-cpu=10000
module load fsl/5.0.9
source $FSLDIR/etc/fslconf/fsl.sh

n=$SLURM_ARRAY_TASK_ID
number=`sed "${n}q;d" TCD_I_list.txt`
site=TCD_I
smoothing=Brainnetome_34mm
FWHM=14.468085 #This number is FWHM/2.35

#Input the folder in which the pre-preprocessing will be done
folder=/m/cs/scratch/networks/data/ABIDE_II/Forward/;
cd $folder

fslmaths ./Brainnetome_0mm/$site/${number}/epi_preprocessed.nii -kernel gauss $FWHM -fmean ./$smoothing/$site/${number}/epi_preprocessed.nii

gunzip -d ./$smoothing/$site/${number}/epi_preprocessed.nii.gz #decompress
rm ./$smoothing/$site/${number}/epi_preprocessed.nii.gz

echo $PWD;
