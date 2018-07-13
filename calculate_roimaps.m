%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script calculates each subject's ROI maps (voxel coordinates for  %
% each ROI).                                                             %
% The script needs the Subject Atlas and the brain mask of the subject to%
% compute an accurate, adjusted Atlas for the subject (different from the%
% back-registered one). Then, the script calculates the voxel indeces for%
% each voxel belonging to a region and stores the data in a structure    %
% which is saved.                                                        %
% Please notice that the label file should be changed accorddingly to the%
% parcellation being used.                                               %
% Last modified:12.12.2017 by AT                                         %
% 13.07.2018 corrected mask for epi signals, easy switch between atlases %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clear cfg

%add the necessary paths
addpath(genpath('/m/cs/scratch/networks/trianaa1/bramila'));
addpath('/m/nbe/scratch/braindata/shared/toolboxes/NIFTI');

%Prepare FSL to be executed in Matlab
setenv('FSLDIR','/share/apps/fsl/5.0.9/fsl/');
system('source $FSLDIR/etc/fslconf/fsl.sh');
setenv('FSLOUTPUTTYPE','NIFTI');

%Prepare the folders
d= dir('/m/cs/scratch/networks/data/ABIDE_II/Inverse/Brainnetome_0mm/ETH_II/*');
d = d(3:end);
for i=1:(length(d))
    subjects{i} = sprintf('/m/cs/scratch/networks/data/ABIDE_II/Inverse/Brainnetome_0mm/ETH_II/%s',d(i).name);
end   

for i=1:(length(d))
    subjects_out{i} = sprintf('/m/cs/scratch/networks/data/ABIDE_II/Inverse/Brainnetome_0mm/ETH_II/ROI/%s',d(i).name);
end   

cfg.data = 'epi_preprocessed.nii'; 
cfg.atlas = 'SubjectAtlas.nii';
cfg.masked_atlas = 'Masked_SubjectAtlas.nii';
cfg.parcellation='brainnetome'; %'brainnetome' or 'ho'

cfg_par = bramila_parhandle(cfg,subjects,subjects_out);
for i = 1:length(subjects)
    cfg = cfg_par{i};
    subj = cfg.inputfolder; disp(['Data: ' subj]);
    input_file = [subj, cfg.data];
    
    cfg = roi_maps(cfg);
end

function cfg=roi_maps(cfg)
%set names
data=sprintf('%s/%s',cfg.inputfolder, cfg.data);
atlas=sprintf('%s/%s',cfg.inputfolder, cfg.atlas); %/m/cs/scratch/networks/data/ABIDE_II/Sandbox/voxel/29105
mask_data=sprintf('%s/%s',cfg.inputfolder, 'mask_epidata.nii');
masked_atlas=sprintf('%s/%s',cfg.inputfolder, cfg.masked_atlas);
mask_name=sprintf('%s/roi_maps.mat',cfg.inputfolder);

%load the labels 
if strcmp(cfg.parcellation,'brainnetome')
    load /m/cs/scratch/networks/trianaa1/Atlas/brainnetome_labels.mat
else 
    load /m/cs/scratch/networks/trianaa1/Atlas/HO_30-2mm_rois_with_subcortl_and_cerebellum.mat
end 

%Creating the structure and erasing slices not included in the Atlas
if strcmp(cfg.parcellation,'ho')
    labels([97,98,99,108,109,110])=[];
    rois.map=[];
    rois.labels=[];
end

%Generate the mask based on epi_brain
system(sprintf('fslmaths %s -thr 0 -bin %s',data,mask_data));

%apply the mask to the Atlas
system(sprintf('fslmaths %s -mas %s %s',atlas,data,masked_atlas));

data=load_untouch_nii(atlas);

[x y z ~]=size(data.img);
intensity=max(max(max(data.img)));

for i=1:intensity
    intensityMap=[];
    for j=1:z
        [a b]=find(data.img(:,:,j)==i);
        c=ones(size(a,1),1)*j;
        if ~isempty(a)
            Temp=horzcat(a,b,c);
            intensityMap=vertcat(intensityMap,Temp);
        end
    end
    rois(i,1).map=intensityMap;
    rois(i,1).labels=labels{i,1};
end

save(mask_name, 'rois');

end