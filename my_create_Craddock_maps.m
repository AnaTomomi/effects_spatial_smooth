% This is a script generates the parcellation voxel ROI maps. 

%Created by AT 25.09.209

clear all
close all
clc

addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila'));
addpath('/m/nbe/scratch/braindata/shared/toolboxes/NIFTI');

n=329;
%cfg.imgsize = [65 77 49];

number = [1:1:n];
for i=1:n
    label{i,1} = sprintf('roi_%s',int2str(number(i)));
end
cfg.labels = label;
%load('/m/cs/scratch/networks/trianaa1/Atlas/brainnetome_labels.mat');
%cfg.labels = labels;
cfg.res = 2;
%cfg.roimask = sprintf('/m/cs/scratch/networks/trianaa1/Atlas/3x3x4mm/Craddock%s.nii',int2str(n));
cfg.roimask='/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-Craddock350-0-2mm_with_subcortl_and_cerebellum.nii';

rois = my_bramila_makeRoiStruct(cfg);

for i=1:n
    
end

%save_path = sprintf('/m/cs/scratch/networks/trianaa1/Atlas/3x3x4mm/BNA-maxprob-thr0_rois_%smm',int2str(n),int2str(cfg.res));
save_path = '/m/cs/scratch/networks/trianaa1/Atlas/3x3x4mm/BNA-maxprob-thr0_rois_3mm.mat';
save(save_path, 'rois');
