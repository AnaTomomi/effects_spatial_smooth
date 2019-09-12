#!/bin/bash
#SBATCH --time=45:00
#SBATCH --mem-per-cpu=10G


n=$SLURM_ARRAY_TASK_ID
number=`sed "${n}q;d" TCD_I_list.txt`


#Input the folder in which the pre-preprocessing will be done
folder=/m/cs/scratch/networks/data/ABIDE_II;
cd $folder

#for i in $(ls -d */) ; do 
mkdir -p ./Prepreprocessed/TCD_I/${number} #make the subject's directory

cp ./Original_data/TCD_I/${number}/session_1/anat_1/mprage.nii.gz  ./Prepreprocessed/TCD_I/${number}/anat.nii.gz #copy the data
cd ./Prepreprocessed/TCD_I/${number}/ #go to the directory where the prepreprocess will take place

gunzip -d anat.nii.gz #decompress
mv anat.nii mprage.nii #rename it 

if [ ! -e brain.nii ] ; then
  fslreorient2std mprage.nii mprage_reorient.nii #reorient the images
  fast -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -B -b -o mprage_fast.nii mprage_reorient.nii
  bet mprage_fast_restore.nii.gz brain.nii -R -f 0.2 -g -0.2 #extract the brain
fi

echo $PWD;
cd  $folder

#done
