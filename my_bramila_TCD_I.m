%% Example of pipeline with default parameters
%   - Notes:
%   Refer to wiki page:
%   https://wiki.aalto.fi/pages/viewpage.action?pageId=92445275 for
%   detailed documentation
%	Last edit: AT 10-11-2017


%%
% Copy this to your folder, specify subject folders with correct file names
%
% Subject folders should contain:
% -epi.nii (functional data)
% -bet.nii (brain-extracted anatomical image)
% -if drifter was used, also .acq file with respiration and heartbeat.
%%
clear all
clear cfg; % Running also "clearn all" is good practice to start from an empty and clean workspace

addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila'));
addpath('/m/nbe/scratch/braindata/shared/toolboxes/NIFTI');


%% List subject input folders
subjects = {
'/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050245'
%'/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050262'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050237'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050264'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050246'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050253'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050238'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050270'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050260'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050254'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050236'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0051132'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050244'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050259'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050261'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050232'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050263'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0051139'
% '/m/cs/scratch/networks/data/ABIDE_II/Prepreprocessed/Input_4_bramila/TCD_I/0050271'
};

%% List subjects output folders
subjects_out = {
'/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_0mm/TCD_I/0050245'
%'/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_0mm/TCD_I/0050262'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050237'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050264'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050246'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050253'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050238'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050270'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050260'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050254'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050236'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0051132'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050244'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050259'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050261'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050232'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050263'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0051139'
% '/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_6mm/TCD_I/0050271'
};
% subjects_out = subjects; % in case you want to store everything under the same original folder


%% General settings
cfg.overwrite = 1; % set to one if you are re-running preprocessing and you want to overwrite existing files
cfg.bramilapath = '/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila'; % bramila toolbox path
cfg.StdTemplate='/m/nbe/scratch/braindata/shared/HarvardOxford/MNI152_T1_2mm_brain.nii'; % 2mm MNI template from FSL

%cfg.Parcellation='/m/cs/scratch/networks/trianaa1/Atlas/BNA-prob-2mm.nii';
%cfg.Parcellation='/m/cs/scratch/networks/trianaa1/Atlas/HarvardOxford-2mm_with_subcortl_and_cerebellum-Parcellation.nii';
cfg.TR = 2; % TR from scanning protocol, used in bramila
cfg.rmvframes = 5; % How many volumes to remove in the beginning (sync trial)

%% temporal filtering
cfg.do_temporal_filtering = 1;
cfg.filtertype = 'butter'; % allowed are butter, fir, fslhp. Use fslhp if you are not doing functional connectivity. Use butter to do like in Power 2014

%% Smoothing
cfg.do_spatial_smooth = 0;
cfg.smooth_FWHM = 0; % used in susan smoothing
cfg.smooth_method = 'FSLgauss'; % 'SPM', 'AFNI', 'FSL' or 'none'

%% slice number parameters, use only one, either slicenum or sliceseq
%cfg.slicenum = 33; % slice count: used in slicetimer, in Siemens scanner odd number of slices starts from 1, even starts from 2
cfg.sliceseq = [1:38]; % prespecified slice acquisition sequence

%% Drifter settings
cfg.drifter = 0; % 1 if you have biopac measurements
cfg.driftermode = 0; % 0 = BOLD estimate only, 1 = BOLD+residual added back

%% Biopac settings, these are setup according to the template that Dima and Heini use
% Which channels were active 1 - active, 0 - not active
biopacfile.CH1=1; %usually breath data from belt
biopacfile.CH2=0; %usually ECG
biopacfile.CH3=0; %usually GSR
biopacfile.CH4=1; %usually heart rate from pulse oxymeter_left
biopacfile.CH5=0; %usually heart rate from pulse oxymeter_right
biopacfile.CH35=1; %usually MRI scan off/on information
% sampling interval of physiodata and fMRI
biopacfile.dt=0.001; % in seconds/sample
biopacfile.controlplot=1 ;% plots all data and save as filename.fig
biopacfile.breath=0.01;%new sampling interval for breath it should not be higher than 2.4( for 25 inhales/min)
biopacfile.HR=0.01; %new sampling interval for heart rate, should not be higher than 0.75(for 80 bpm)
% set the range for frequencies in signals in bpm (try to keep those as narrow as posible)
biopacfile.freqBreath=10:25; % in breaths per min
biopacfile.freqHR=40:90; % in beats per minutes
biopacfile.filter=1; % bandpass filter for reference data 1 - active, 0 - not active
cfg.biopacfile = biopacfile;

%% Bramila parameters for optimized cleaning of artefacts
% OPTIONAL parameters (otherwise use defaults as marked here in the example)
% Modify only if needed (see "bramila_checkparameters.m" for defaults)
% cfg.motion_reg_type = 'friston'; % motion regression type
% cfg.voxelsize=[2,2,2];        % voxelsize
% cfg.mask = [];                % initial EPI mask
% cfg.tissue_derivatives = 0;   % tissue regressor derivative order
% cfg.min_tissue_var_expl = 75; % minimum variance percentage for tissue PCA regressors
% cfg.max_tissue_pca_count = 7; % upper limit for tissue PCA regressors
 cfg.remove_global = 1;        % remove global signal
% cfg.mot_derivatives = 1;  % motion regressor derivatives
% cfg.white_mask_th = 0.90; % probability threshold for white matter tissue
% cfg.csf_mask_th = 0.90;   % probability threshold for ventricle tissue
 cfg.detrend_type='Savitzky-Golay';   % detrending type
 cfg.filter_type = 'butter';   % temporal filter type
% cfg.filter_limits = [0,0.01,0.08,0.09];   % filter limits in Hz
cfg.write = 1;    % write all intermediate EPI's
% cfg.save_path = '/m/nbe/scratch/braindata/kauttoj2/code/bramila_git/bramila/out'; % custom save path for bramila motion cleaning results


%% Running preprocessing. Do not modify the code below
cfg = bramila_parhandle(cfg,subjects,subjects_out); % reslices the cfg so that it can be used in parfor loop
if ~strcmp(cfg{1}.gridtype,'slurm')
    parfor i = 1:length(subjects)
        bramila_preprocessor(cfg{i});
    end
else
    for i = 1:length(subjects)
        bramila_slurmprepro(cfg{i});
    end
end
