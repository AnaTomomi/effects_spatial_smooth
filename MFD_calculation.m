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
folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/group2/Brainnetome_0mm/';
%Define folder containing the FD matrices
folder2='/m/cs/scratch/networks/data/ABIDE_II/Forward/Brainnetome_0mm/';
d=dir(folder);
d=d(3:end);
%Define the sites
ETH=zeros(length(d),1);
TCD=zeros(length(d),1);
USM=zeros(length(d),1);
NYU=zeros(length(d),1);
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
    else
        NYU(i,1)=1;
    end
end

T=table([Subjects],[MeanFD],[ETH],[TCD],[USM],[NYU],[intercept]);
writetable(T,'/m/cs/scratch/networks/data/ABIDE_II/Analysis/group2/regress.csv')
