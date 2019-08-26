# Effects of spatial smoothing on group-level differences in functional brain networks

## What?
This is the GIt repository for the code used in the preprocessing, analysis and visualization of the paper "Effects of spatial smoothing on group-level differences in functional brain networks" by Triana, AM., Glerean, E., Saramäki, J., and Korhonen.O.

## Overall organization
All the files have a comment section in the beginning briefly stating what each file does. 

## Prerequisites 
You will need some functions from BraMila, which is available here; https://version.aalto.fi/gitlab/BML/bramila.git or here: https://version.aalto.fi/gitlab/BML/bramila/wikis/home

## Preprocessing
### Files
- calculate_roimaps.m
- MFD_calculation.m
- my_bramila_makeRoiStruct.m
- mycalculate_adjacency.m
- my_correct_origin.m
- my_make_indv_mask.m
- mymake_spheres.m
- my_space2MNI.m
- Organize-Subjects.py
- pick_and_save_voxel_ts.m
- pick_and_save_voxel_ts_wrapper.m
- regress_data.py

### How to?
To preprocess the files, you need to have two files for each subject: rs-fMRI (EPI.nii) and the brain extracted image (bet.nii).
You also

## Analysis
### Files
- bramila_ttest2_np.m
- my_run_ttest_permutations.m
- my_run_ttest_permutations.sh
- my_run_ttest_permutations.m
- my_run_ttest_permutations.sh

## Visualization
### Files
- Brainnetome2Power.m
- mycheck_netproperties.m
- distance.m
- my_aurora.m
- mycheck_netproperties.m
- my_net_analysis.m
- my_spearman.m
- my_thesholdanalysis.m


## Questions?
If you have any questions, you may use the issue tracker of this repository or email ana.trianahoyos@aalto.fi
