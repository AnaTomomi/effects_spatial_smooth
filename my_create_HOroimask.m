% This is a script for creating the Harvard-Oxford atlas grey matter ROIs,
% containing subcortical grey matter and cerebellum
% Last modified by Onerva 2014-07-03: changed grey matter mask so that each
% voxel is a roi of its own
% OK 2014-07-14: from 2 mm to 4 mm masks
% OK 2014-07-21: from 4 mm masks to general res
% OK 2014-07-24: replaced bramila_makeRoiStruct with
% my_bramila_make_RoiStruct to use general space2MNI transform, added
% origin fix
% OK 2015-03-05: changed paths to refer to cortl files (hemispheres split);
% added option for not including subcortex and cerebellum

%addpath(genpath('/triton/becs/scratch/braindata/shared/toolboxes/bramila/bramila'));
%addpath('/triton/becs/scratch/braindata/shared/toolboxes/NIFTI');

clear all
close all

addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila'));
addpath('/m/nbe/scratch/braindata/shared/toolboxes/NIFTI');

TH = 30;
blacklist = [];
res = 2;
res_str = [num2str(res), 'mm'];
template = ['HarvardOxford/MNI152_T1_' res_str '_brain.nii'];
include_cerebellum = false;
include_subcortex = false;
%% cortex
if strcmp(res, '2mm')
    %nii_path = '/triton/becs/scratch/braindata/shared/toolboxes/HarvardOxford/split/HarvardOxford-cortl-prob-2mm.nii';
    nii_path = '/m/nbe/scratch/braindata/shared/toolboxes/HarvardOxford/split/HarvardOxford-cortl-prob-2mm.nii';
else
    %nii_path = ['/triton/becs/scratch/networks/aokorhon/preprocessing/bramila_related_code/HarvardOxford/split/HarvardOxford-cortl-prob-', res_str, '.nii'];
    nii_path = ['/m/cs/scratch/networks/aokorhon/preprocessing/bramila_related_code/HarvardOxford/split/HarvardOxford-cortl-prob-', res_str, '.nii'];
end
nii=load_nii(nii_path);
% thresholding
for n=1:size(nii.img,4)
    temp=double(nii.img(:,:,:,n));
    if(n==1)
        out=zeros(size(temp));
    end
    ids=find(temp>TH);
    out(ids)=n;
end
count=n;

%% subcortex
if include_subcortex
    if strcmp(res, '2mm')
        %nii_path = '/triton/becs/scratch/braindata/shared/toolboxes/HarvardOxford/HarvardOxford-sub-prob-2mm.nii';
        nii_path = '/m/nbe/scratch/braindata/shared/toolboxes/HarvardOxford/HarvardOxford-sub-prob-2mm.nii';
    else
        %nii_path = ['/triton/becs/scratch/networks/aokorhon/preprocessing/bramila_related_code/HarvardOxford/HarvardOxford-sub-prob-', res_str, '.nii'];
        nii_path = ['/m/cs/scratch/networks/aokorhon/preprocessing/bramila_related_code/HarvardOxford/HarvardOxford-sub-prob-', res_str, '.nii'];
    end
    nii=load_nii(nii_path);
    nii.img(:,:,:,[1 2 3 12 13 14])=[];  % getting rid of masks for white matter, cortex and ventricles
    % thresholding
    for n=1:size(nii.img,4)
        temp=double(nii.img(:,:,:,n));
        ids=find(temp>TH);
        out(ids)=n+count;
    end
    count=n+count;
end
%% cerebellum
if include_cerebellum
    if strcmp(res, '2mm')
        %nii_path = '/triton/becs/scratch/braindata/shared/toolboxes/HarvardOxford/Cerebellum-MNIfnirt-prob-2mm.nii';
        nii_path = '/m/nbe/scratch/braindata/shared/toolboxes/HarvardOxford/Cerebellum-MNIfnirt-prob-2mm.nii';
    else
        %nii_path = ['/triton/becs/scratch/networks/aokorhon/preprocessing/bramila_related_code/HarvardOxford/Cerebellum-MNIfnirt-prob-', res_str, '.nii'];
        nii_path = ['/m/cs/scratch/networks/aokorhon/preprocessing/bramila_related_code/HarvardOxford/Cerebellum-MNIfnirt-prob-', res_str, '.nii'];
    end
    nii=load_nii(nii_path);
    % thresholding
    for n=1:size(nii.img,4)
        temp=double(nii.img(:,:,:,n));
        ids=find(temp>TH);
        out(ids)=n+count;
        if(length(ids)==0)
            blacklist=[blacklist;n+count];
        end
    end
    count=n+count;
end
%% grey matter masks
grey_matter_mask = zeros(size(out));
grey_matter_mask(find(out>0)) = 1;
grey_matter_voxels = 1:1:numel(out);
grey_matter_voxels = reshape(grey_matter_voxels, size(out));
grey_matter_voxels = grey_matter_voxels .* grey_matter_mask;

if include_subcortex
    if include_cerebellum
        boolean_mask_name = ['HarvardOxford/split/grey_matter-boolean_mask-maxprob-' num2str(TH) '-' res_str '_with_subcortl_and_cerebellum.nii'];
        voxel_mask_name = ['HarvardOxford/split/grey_matter-maxprob-' num2str(TH) '-' res_str '_with_subcortl_and_cerebellum.nii'];
    else
        boolean_mask_name = ['HarvardOxford/split/grey_matter-boolean_mask-maxprob-' num2str(TH) '-' res_str '_with_subcortl.nii'];
        voxel_mask_name = ['HarvardOxford/split/grey_matter-maxprob-' num2str(TH) '-' res_str '_with_subcortl.nii']
    end
elseif include_cerebellum
    boolean_mask_name = ['HarvardOxford/split/grey_matter-boolean_mask-maxprob-' num2str(TH) '-' res_str '_with_cerebellum.nii'];
    voxel_mask_name = ['HarvardOxford/split/grey_matter-maxprob-' num2str(TH) '-' res_str '_with_cerebellum.nii'];
else
    boolean_mask_name = ['HarvardOxford/split/grey_matter-boolean_mask-maxprob-' num2str(TH) '-' res_str '.nii'];
    voxel_mask_name = ['HarvardOxford/split/grey_matter-maxprob-' num2str(TH) '-' res_str '.nii'];
end

save_nii(make_nii(grey_matter_mask, [res res res]), boolean_mask_name)
save_nii(make_nii(grey_matter_voxels, [res res res]), voxel_mask_name)

% origin fixes
clear cfg
cfg.target = boolean_mask_name; %['HarvardOxford/split/grey_matter-boolean_mask-maxprob-' num2str(TH) '-' res_str '.nii'];
cfg.template = template;
cfg = my_correct_origin(cfg);
cfg.target = voxel_mask_name; %['HarvardOxford/split/grey_matter-maxprob-' num2str(TH) '-' res_str '.nii'];
cfg = my_correct_origin(cfg);

% first a mask with all grey matter in one roi

clear cfg
if res == 2
    cfg.imgsize = [91 109 91];
elseif res == 4
    cfg.imgsize = [45 54 45]; % assumes that 4mm and 8mm masks are created with flirt -applyisoxfm
elseif res == 8
    cfg.imgsize = [22 27 22];
end
cfg.roimask = boolean_mask_name; %['HarvardOxford/split/grey_matter-boolean_mask-maxprob-' num2str(TH) '-' res_str '.nii'];
grey_label = {'grey_matter'};
cfg.labels = grey_label;
cfg.res = res;
grey_matter_one_roi = my_bramila_makeRoiStruct(cfg);

% changing the roi structure so that each voxel is a roi of its own
% (supported structure in brainnets)
%load /triton/becs/scratch/networks/aokorhon/funpsy/funpsy-read-only/atlases/HarvardOxford/HO_labels.mat
load /m/cs/scratch/networks/aokorhon/funpsy/funpsy-read-only/atlases/HarvardOxford/HO_labels.mat
grey_matter_label_indices = out(find(out>0));
grey_matter_label_indices = reshape(grey_matter_label_indices, 1, numel(grey_matter_label_indices));
grey_matter_labels = labels(grey_matter_label_indices);
grey_matter = {};
one_roi_map = grey_matter_one_roi.map;
s = size(one_roi_map);
nrows = s(1);
for voxel_ind = 1 : 1 : nrows;
    grey_matter(voxel_ind).map = one_roi_map(voxel_ind, :);
    grey_matter(voxel_ind).centroid = one_roi_map(voxel_ind, :);
    grey_matter(voxel_ind).label = grey_matter_labels(voxel_ind);
    [mnix mniy mniz] = bramila_space2MNI(grey_matter(voxel_ind).centroid(1), grey_matter(voxel_ind).centroid(2), grey_matter(voxel_ind).centroid(3));
    grey_matter(voxel_ind).centroidMNI = [mnix mniy mniz];
end
if include_subcortex
    if include_cerebellum
        mask_name = ['HarvardOxford/split/HO_' num2str(TH) '-' res_str '_grey_matter_with_subcortl_and_cerebellum'];
    else
        mask_name = ['HarvardOxford/split/HO_' num2str(TH) '-' res_str '_grey_matter_with_subcortl'];
    end
elseif include_cerebellum
    mask_name = ['HarvardOxford/split/HO_' num2str(TH) '-' res_str '_grey_matter_with_cerebellum'];
else
    mask_name = ['HarvardOxford/split/HO_' num2str(TH) '-' res_str '_grey_matter'];
end

save(mask_name, 'grey_matter');
%% roi masks
if include_subcortex
    if include_cerebellum
        mask_name = ['HarvardOxford/split/HarvardOxford-maxprob-' num2str(TH) '-' res_str '_with_subcortl_and_cerebellum.nii'];
    else
        mask_name = ['HarvardOxford/split/HarvardOxford-maxprob-' num2str(TH) '-' res_str '_with_subcortl.nii'];
    end
elseif include_cerebellum
    mask_name = ['HarvardOxford/split/HarvardOxford-maxprob-' num2str(TH) '-' res_str '_with_cerebellum.nii'];
else
    mask_name = ['HarvardOxford/split/HarvardOxford-maxprob-' num2str(TH) '-' res_str '.nii'];
end

save_nii(make_nii(out, [res res res]),mask_name)

% origin

clear cfg
cfg.target = mask_name; %['HarvardOxford/split/HarvardOxford-maxprob-' num2str(TH) '-' res_str '.nii'];
cfg.template = template;

clear cfg
if res == 2
    cfg.imgsize = [91 109 91];
elseif res == 4
    cfg.imgsize = [45 54 45];
elseif res == 8
    cfg.imgsize = [22 27 22];
end
cfg.res = res;
cfg.roimask= mask_name;%['HarvardOxford/split/HarvardOxford-maxprob-' num2str(TH) '-' res_str '.nii'];
labels([97 98 99 108 109 110])=[]; % as above, we remove label masks for white matter, cortex and ventricles
labels(blacklist)=[];
cfg.labels=labels;
rois = my_bramila_makeRoiStruct(cfg);
if include_subcortex
    if include_cerebellum
        mask_name = ['HarvardOxford/split/HO_' num2str(TH) '-' res_str '_rois_with_subcortl_and_cerebellum'];
    else
        mask_name = ['HarvardOxford/split/HO_' num2str(TH) '-' res_str '_rois_with_subcortl'];
    end
elseif include_cerebellum
    mask_name = ['HarvardOxford/split/HO_' num2str(TH) '-' res_str '_rois_with_cerebellum'];
else
    mask_name = ['HarvardOxford/split/HO_' num2str(TH) '-' res_str '_rois'];
end
        
save(mask_name, 'rois');
