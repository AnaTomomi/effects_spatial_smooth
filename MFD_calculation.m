%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script computes the mean FD for all the sequence for a group of    5
% subjects. It also organizes the ABIDE information and codes the site    %
% from which each subject was scanned. The script writes the information  %
% in csv format, intented to be used as input for data regression.        %
% Created 16.07.2018 by AT.                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
close all

%Define subject folder
folder='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/group2/Brainnetome_0mm/';
%Define folder containing the FD matrices
folder2='/m/cs/scratch/networks/data/UCLA_openneuro/Brainnetome_0mm/';
%Define saving path
write_path='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/group2/regress.csv';
%Define language for regression
config='python'; %options: 'matlab', 'python'

d=dir(folder);
d=d(3:4:end);



%Define the sites 
ETH=zeros(length(d),1);
TCD=zeros(length(d),1);
USM=zeros(length(d),1);
NYU=zeros(length(d),1);
CMU=zeros(length(d),1);
CALTECH=zeros(length(d),1);
intercept=ones(length(d),1);

for i=1:length(d)
    datum=strsplit(d(i).name,'-');
    site=char(datum{1,1});
    subject=char(datum{1,2});
    path=strcat(folder2,site,'/',subject,'/bramila/diagnostics.mat');
    load(path);
    MeanFD(i,1)=mean(FD);
    Subjects{i,1}=strcat(site,'-',subject);
    if strcmp(site,'ETH_II')
        ETH(i,1)=1;
    elseif strcmp(site,'TCD_II')
        TCD(i,1)=1;
    elseif strcmp(site,'USM_II')
        USM(i,1)=1;
    elseif strcmp(site,'USM_I')
        USM(i,1)=1;
    elseif strcmp(site,'NYU_I')
        NYU(i,1)=1;
    elseif strcmp(site,'TCD_I')
        TCD(i,1)=1;
    elseif strcmp(site,'CMU_I')
        CMU(i,1)=1;
    else
        CALTECH(i,1)=1;
    end
end

if strcmp(config,'matlab')
    T=table([Subjects],[ETH],[TCD],[USM],[NYU],[CMU],[CALTECH],[MeanFD],[intercept]);
else
    T=table([Subjects],[ETH],[TCD],[USM],[NYU],[CMU],[CALTECH],[MeanFD]);
end

writetable(T,write_path)
