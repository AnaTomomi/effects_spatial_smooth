%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is used to generate spherical ROIs of fixed sizes based on  %
% an existing parcellation                                                %
%                                                                         %
% ?? Created by Ana T.                                                    %
% 11.10.2019 Modified by Ana T. Add comments to know what it does         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila'));
%addpath(genpath('/m/cs/scratch/networks/trianaa1/bramila/bramila'));
addpath('/m/nbe/scratch/braindata/shared/toolboxes/NIFTI');

group_mask='/m/cs/scratch/networks/data/UCLA_openneuro/masks/FD07/group_roi_mask-craddock350-0-2mm_with_subcortl_and_cerebellum.mat';
load(group_mask)

%Move some centroids a tiny bit
% rois(90).centroidMNI = [44,-14,-26];
% rois(96).centroidMNI = [50,-8,-28];
% rois(237).centroidMNI = [-4,-10,8];
 
for i=1:329
    label{i}=rois(i).label;
    centroid(i,1:3)=rois(i).centroidMNI;
end

cfg.radius=1;
cfg.roi=centroid;
cfg.labels=label';
clear rois
clear centroid
clear label
clear group_mask
clear i
rois = bramila_makeRoiStruct(cfg);

% load /m/cs/scratch/networks/trianaa1/Atlas/brainnetome_MPM_rois_2mm.mat
% for i=1:246
%     roi=rois(i).map;
%     s(i)=size(roi,1);
%     max_x(i)=max(roi(:,1))-min(roi(:,1));
%     max_y(i)=max(roi(:,2))-min(roi(:,2));
%     max_z(i)=max(roi(:,3))-min(roi(:,3));
% end
% fprintf('The maximum size is: %s, %s, and %s \n',num2str(min(max_x)), num2str(min(max_y)),num2str(min(max_z)))

%Check that there is no overlap

for i=1:329
    for j=(i+1):329
        C=intersect(rois(i).map,rois(j).map,'rows');
        if ~isempty(C)
            disp(sprintf('ROIs overlapping at rois %s-%s',num2str(i),num2str(j)))
        end
    end
end

save('/m/cs/scratch/networks/data/UCLA_openneuro/masks/FD07/group_roi_mask-craddock350-sphere-0-2mm_with_subcortl_and_cerebellum.mat','rois')