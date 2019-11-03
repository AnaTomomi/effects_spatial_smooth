%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script selects the craddock parcellations from the Craddock Atlas used  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath('/m/nbe/scratch/nbe/braindata/shared/toolboxes/NIFTI');

atlas='/m/cs/scratch/networks/trianaa1/Atlas/Craddock_random_all.nii';
nii=load_nii(atlas);
x=size(nii.img,1);
y=size(nii.img,2);
z=size(nii.img,3);
t=size(nii.img,4);

atlas1=nii.img(:,:,:,10);%select the atlas with 100 ROIs
atlas2=nii.img(:,:,:,31);%select the atlas with 350 ROIs

nii_path = '/m/cs/scratch/networks/trianaa1/Atlas/Craddock_random_100.nii';
save_nii(make_nii(atlas1, [x y z]), nii_path)

nii_path = '/m/cs/scratch/networks/trianaa1/Atlas/Craddock_random_350.nii';
save_nii(make_nii(atlas2, [x y z]), nii_path)