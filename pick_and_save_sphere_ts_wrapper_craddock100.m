% This is a wrapper script for picking and saving voxel time series that
% belong to each ROI. Originally written by Onerva Korhonen 2014-07-14,
% modified 2017-12-08 by AT
% checked and modify to match the directories for Forward preprocessing by
% AT on 2018-07-09
% Modified to loop over all sites (faster computation)
% Also checked that it works with fixed ROI sizes. 
% AT on 2019-03-20 

clear cfg
clear all
clc
addpath(genpath('/m/cs/scratch/networks/trianaa1/bramila'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/Paper1/smoothing-group'));

% d = dir('/m/cs/scratch/networks/data/ABIDE_II/Forward/*/*/*');
% d(ismember({d.name}, {'.', '..','group_mask-Brainnetome_0mm-2mm.nii','group_roi_mask-Brainnetome_0mm-0-2mm_with_subcortl_and_cerebellum.mat','group_roi_mask-Brainnetome_0mm-0-2mm_with_subcortl_and_cerebellum.nii','group_roi_mask-Brainnetome_0mm-0-2mm_with_subcortl_and_cerebellum_correctedMNI.mat'})) = [];
% 
% %check if the files have been created and if yes, then skip that subject
% 
% for i=1:(length(d))
%     if ~isfile(sprintf('%s/%s/sphere_craddock100_ts_all_rois_info.mat',d(i).folder,d(i).name))
%         subjects{i} = sprintf('%s/%s',d(i).folder,d(i).name);
%     end
% end
d=dir('/m/cs/scratch/networks/data/UCLA_openneuro/*/');
d(ismember({d.folder}, {'/scratch/cs/networks/data/UCLA_openneuro/Preprocessed','masks'})) = [];
d(ismember({d.name}, {'.', '..','FD05','FD07','FD08'})) = [];
fid = fopen('/m/cs/scratch/networks/data/UCLA_openneuro/subjects_FD07.txt','r');
Data=textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '');
subject_list  = Data{1};
fclose(fid);

d(~ismember({d.name}, subject_list))=[];
for i=1:(length(d))
    if ~isfile(sprintf('%s/%s/sphere_craddock10007_ts_all_rois_info.mat',d(i).folder,d(i).name))
        subjects{i} = sprintf('%s/%s',d(i).folder,d(i).name);
    end
end


ids=find(~cellfun(@isempty,subjects));
subjects=subjects(ids);
        
%This is a mock array, it is not used for writing/saving any array. 
%Its purpose is to prevent an error from the parhandle_bramila function in
%the forward case, and to set the folder in which the roi_maks are for the inverse case 
for i=1:(length(d))
    subjects_out{i} = sprintf('%s/ROIs/%s',d(i).folder,d(i).name);
end 

subjects_out=subjects_out(ids);
        
cfg.inputfile = '/epi_preprocessed'; %generic name of the file to be used (usually the output from preprocessing)
%cfg.roi_mask_names = {'/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-Brainnetome_0mm-0-2mm_with_subcortl_and_cerebellum_correctedMNI.mat'};
cfg.roi_mask_names = {'/m/cs/scratch/networks/data/UCLA_openneuro/masks/FD07/group_roi_mask-craddock100-sphere-0-2mm_with_subcortl_and_cerebellum.mat'};
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
    cfg = pick_and_save_sphere_ts_craddock100(cfg);
end
