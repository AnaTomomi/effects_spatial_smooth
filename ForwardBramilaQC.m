%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script provides a quick way to perform quality control for the    %
% forward-registration Bramila Pipeline.                                 %
% The script opens all the necessary files to be analyzed in sequence.   %
% The slice check up is done in the command Window. The NII files are    %
% automatically open; the script pauses its execution and waits until the%
% user presses any key in the command window to launch the next NII file.% 
%                                                                        %
% Last Edited: 05/07/2018 by Ana Triana                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all 
close all
clc

addpath('/m/cs/scratch/networks/trianaa1/scripts')

%Prepare FSL to be executed in Matlab
setenv('FSLDIR','/share/apps/fsl/5.0.9/fsl/')
system('source $FSLDIR/etc/fslconf/fsl.sh')
setenv('FSLOUTPUTTYPE','NIFTI')

%Format all the inputs
folder='/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_0mm/USM_I';

Subjects=dir(folder);
SubjectNum=size(Subjects,1);

for i=3:SubjectNum %3
subject=Subjects(i).name; 
log=dir(fullfile(sprintf('%s/%s',folder,subject),'*.log'));
log=sprintf('%s/%s/%s',folder,subject,log.name);
slice=sprintf('%s/%s/slices',folder,subject);
epi_trans=sprintf('%s/%s/epi_trans.png',folder,subject);
epi_rot=sprintf('%s/%s/epi_rot.png',folder,subject);
epi_disp=sprintf('%s/%s/epi_disp.png',folder,subject);
%MCF_meanvol=sprintf('%s/%s/epi_MCF.nii_meanvol.nii',folder,subject);
MCF_sigma=sprintf('%s/%s/epi_MCF.nii_sigma.nii',folder,subject);
MCF_variance=sprintf('%s/%s/epi_MCF.nii_variance.nii',folder,subject);
brain=sprintf('%s/%s/epi_brain.nii',folder,subject);
SubjectROI=sprintf('%s/%s/betMNI.nii',folder,subject);
motionReg=sprintf('%s/%s/bramila/epi_STD_mot_reg_R2.nii',folder,subject);
motionTissue=sprintf('%s/%s/bramila/epi_STD_tissue_R2.nii',folder,subject);
mask=sprintf('%s/%s/bramila/epi_STD_analysis_mask.nii',folder,subject);
%diag1=sprintf('%s/%s/bramila/diagnostics_corrMat.eps',folder,subject);
diag2=sprintf('%s/%s/bramila/diagnostics_time.eps',folder,subject);
prepro=sprintf('%s/%s/epi_preprocessed.nii',folder,subject);

files={
%MCF_meanvol
MCF_sigma
MCF_variance
brain
SubjectROI
motionReg
motionTissue
mask
prepro
};

%open the slice txt
fileID = fopen(slice,'r');
formatSpec = '%f';
Slice = fscanf(fileID,formatSpec);

%Read the log
fid = fopen(log,'r');
j=1;
while ~feof(fid)
     Log(j,1) = {fgetl(fid)}; 
     j=j+1;
end
 fclose(fid);

%Arrange the slices in readable format
Slice=num2cell(Slice);
SliceInfo={Log{4:size(Slice,1)+4},Slice{:}}'

%open the first set of pictures
[img map]= imread(epi_trans,'png');
imshow(img,map);
figure
[img map]= imread(epi_rot,'png');
imshow(img,map);
figure
[img map]= imread(epi_disp,'png');
imshow(img,map);

%open the Nii files
for j=1:8
    cmd = sprintf('fslview %s',files{j,1}); 
    system(cmd);
    pause
end

%Convert the eps to png, so it is Matlab-readable
%[result,msg] = eps2xxx(diag1,{'png'});
[result,msg] = eps2xxx(diag2,{'png'});
%diag1=sprintf('%s/%s/bramila/diagnostics_corrMat.png',folder,subject);
diag2=sprintf('%s/%s/bramila/diagnostics_time.png',folder,subject);
%[img map]= imread(diag1,'png');
%imshow(img,map);
figure
[img map]= imread(diag2,'png');
imshow(img,map);

pause
disp(sprintf('Subject %s completed',subject));
end