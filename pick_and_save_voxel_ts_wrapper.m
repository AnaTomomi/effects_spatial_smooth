% This is a wrapper script for picking and saving voxel time series that
% belong to each ROI. Originally written by Onerva Korhonen 2014-07-14,
% modified 2017-12-08 by AT
% checked and modify to match the directories for Forward preprocessing by
% AT on 2018-07-09

clear cfg
clear all
clc
addpath(genpath('/m/cs/scratch/networks/trianaa1/bramila'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/Paper1/smoothing-group'));
        
folder='/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_50mm/TCD_II';
d= dir([folder '/*']);
d = d(3:end);
for i=1:(length(d))
    subjects{i} = sprintf('%s/%s',folder,d(i).name);
end        

%This is a mock array, it is not used for writing/saving any array. 
%Its purpose is to prevent an error from the parhandle_bramila function in
%the forward case, and to set the folder in which the roi_maks are for the inverse case 
for i=1:(length(d))
    subjects_out{i} = sprintf('/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_50mm/TCD_II/ROI/%s',d(i).name);
end   

cfg.inputfile = '/epi_preprocessed'; %generic name of the file to be used (usually the output from preprocessing)
cfg.roi_mask_names = {'/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-Brainnetome_0mm-0-2mm_with_subcortl_and_cerebellum_correctedMNI.mat'};
%cfg.roi_mask_names = {'roi_maps.mat'};% roi mask for inverse registration 
%cfg.grey_matter_mask_names = {'group_grey_matter_mask-30-4mm.mat'}; %ready-made masks used to calculate adjacency matrices

% ROIs for which the adjacency matrix will be calculated
cfg.adjacency_rois = {'all'};%{'all'};
%cfg.excluded_rois = [237];

cfg_par = bramila_parhandle(cfg,subjects,subjects_out); % reslices the cfg so that it can be used in parfor loop
for i = 1:length(subjects)
    cfg = cfg_par{i};
    subj = cfg.inputfolder; disp(['Data: ' subj]);
    cfg.pipeline='forward'; %options: 'forward', 'inverse'
    %cfg.grey_matter_mask_name = cfg.grey_matter_mask_names{1};
    cfg.roi_mask_name = cfg.roi_mask_names{1};
    input_path = [subj, cfg.inputfile, '.nii'];
    data = load_untouch_nii(input_path);
    cfg.vol = data.img;
    cfg = pick_and_save_voxel_ts(cfg);
end