# Effects of spatial smoothing on group-level differences in functional brain networks

## What?
This is the GIT repository for the code used in the preprocessing, analysis and visualization of the paper "Effects of spatial smoothing on group-level differences in functional brain networks" by Triana, AM., Glerean, E., Saramäki, J., and Korhonen.O.

## Overall organization
All the files have a comment section in the beginning briefly stating what each file does. 

## Prerequisites 
You will need some functions from BraMila, which is available here; https://version.aalto.fi/gitlab/BML/bramila.git or here: https://version.aalto.fi/gitlab/BML/bramila/wikis/home

## Preprocessing
### Files
- calculate_roimaps.m
- MFD_calculation.m
- ForwardBramilaQC.m
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
To preprocess the files, you need to have two files for each subject: rs-fMRI (EPI.nii) and the brain extracted image (bet.nii). You also need the BraMila toolbox. 
1. Choose the Atlas you want to use to create the ROIs. For the paper, we chose the Brainnetome Atlas. Run the file my_bramila_makeRoiStruct.m to create the information about the Atlas in .mat format. 
2. Change the paths and run the Bramila preprocessor with the same parameters as the ones stated in the paper.  
3. Check the quality of the preprocessing. The script ForwardBramilaQC.m could be helpful.
4. Create the group masks by running my_make_ind_mask.m (start_from_epi=1)
5. Average the ROI time-series. You may use the script pick_and_save_voxel_ts_wrapper.m for this purpose.
6. Create the adjacency matrices using the script mycalculate_adjacency.m
7. Organize the subjects according to the groups where each belongs. The script Organize-Subjects.py will help with that.
8. Regress possible effects due to the place where the subjects were scanned and their mean framewise displacement (MFD). The MFD is calculated with the script MFD_calculation.m. Use regress_data.py for the regression.
 

If you want to run the analysis with spheres of fixed radios as ROIs, you need to create the spheres first. The script mymake_sphere.m creates such spheres and the script my_correct_origin.m helps to translate the coordinates to the right format. After creating the spheres, re-run from step 4.

## Analysis
### Files
- bramila_ttest2_np.m
- my_slurm_permutations.m
- run_slurm_permutations.sh
- my_NBS_test.m
- my_NBS_test.sh

The main file is my_NBS_test.m, which runs the Networks-based statistic for comparing two groups at a level of smoothing. Check the paths and run it. This will save the results is .mat format. For speed-up performance, use my_NBS_test.sh. If you want to run NBS, you need to create the data structures first. You may use the file make_NBS_data_design.m
If you want to run the analysis for the thresholded networks, then you need to modify the file my_slurm_permutations.m with the right paths and run the file run_slurm_permutations.sh

## Visualization
### Files
- Brainnetome2Power.m
- binary_aurora.m
- binary_distance.m
- binary_graphmeas.m
- binary_graphmeas_tables.m
- binary_hamming.m
- binary_links.m
- binary_links_threshold.m
- binary_regress_distance.m
- test_aurora.m
- test_distance.m
- test_hamming.m
- test_NBSthreshold.m
- test_parcellations.m
- test_regress_distance.m
- circos

Each file has different visualizations based on the excel file created by the scripts in the analysis part. Since some of the analysis implied assigning the Brainnetome areas to the systems found by Power et. al (2012), the script for that is also included. 
Additionally, the principal visualization is done in circos (http://circos.ca), so the folder with the scripts is also included. This circos visualization is based on the tutorial #19 found in the circos webpage. 

## Questions?
If you have any questions, you may use the issue tracker of this repository or email ana.trianahoyos@aalto.fi
