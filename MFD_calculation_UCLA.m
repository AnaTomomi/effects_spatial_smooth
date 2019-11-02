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
folder='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD07/group2/Brainnetome_0mm/';
%Define folder containing the FD matrices
folder2='/m/cs/scratch/networks/data/UCLA_openneuro/Brainnetome_0mm/';
%Define saving path
write_path='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD07/group2/regress.csv';
%Define language for regression
config='python'; %options: 'matlab', 'python'

d=dir(folder);
d=d(3:7:end);



%Define the sites 
%gender=zeros(length(d),1);
intercept=ones(length(d),1);

for i=1:length(d)
    datum=strsplit(d(i).name,'-');
    sub=char(datum{1,1});
    subject=char(datum{1,2});
    path=strcat(folder2,sub,'-',subject,'/bramila/diagnostics.mat');
    load(path);
    MeanFD(i,1)=mean(FD);
    Subjects{i,1}=strcat(sub,'-',subject);
    %gender(i,1)=1;
end

if strcmp(config,'matlab')
    T=table([Subjects],[MeanFD],[intercept]);
else
    T=table([Subjects],[MeanFD]);
end

writetable(T,write_path)
