#!/bin/bash
#Small script to accomodate the files for bramila input. 
#It decompress, copies and renames the files into the right folder. 

folder=/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed; #Input the folder in which the pre-preprocessing will be done

site=CALTECH_I; #changeme

cd $folder/$site

gunzip -d ./*/brain.nii.gz

for i in $(ls -d */) ; do 
mkdir -p $folder/Input_4_bramila/$site/$i #make the subject's directory
cp ./${i}/brain.nii  $folder/Input_4_bramila/$site/${i}/bet.nii
cp /m/cs/scratch/networks/data/ABIDE_II/Original_data/$site/${i}/session_1/rest_1/rest.nii.gz $folder/Input_4_bramila/$site/${i}/epi.nii.gz
echo $i 
done

gunzip -d /m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/$site/*/epi.nii.gz
