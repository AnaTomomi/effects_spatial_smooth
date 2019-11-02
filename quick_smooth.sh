#!/bin/bash
#SBATCH -p batch
#SBATCH -t 00:15:00
#SBATCH --qos=normal
#SBATCH --mem-per-cpu=4096
module load fsl/5.0.9
source $FSLDIR/etc/fslconf/fsl.sh

n=$SLURM_ARRAY_TASK_ID
number=`sed "${n}q;d" subjects.txt`
#site=TCD_I
smoothing=Brainnetome_32mm
FWHM=13.617021 #This number is FWHM/2.35

#Input the folder in which the pre-preprocessing will be done
folder=/m/cs/scratch/networks/data/UCLA_openneuro/;
cd $folder

fslmaths ./Brainnetome_0mm/${number}/epi_preprocessed.nii -kernel gauss $FWHM -fmean ./$smoothing/${number}/epi_preprocessed.nii

gunzip -d ./$smoothing/${number}/epi_preprocessed.nii.gz #decompress
#rm ./$smoothing/${number}/epi.nii.gz

#echo $PWD;
