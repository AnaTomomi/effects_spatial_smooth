clear all
close all
clc

smoothing='0';
N=329;

folder1=sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD07/group1/Brainnetome_%smm',smoothing);
folder2=sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD07/group2/Brainnetome_%smm',smoothing);
data_path=sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD07/NBS/temp/craddock350_%smm.mat',smoothing);
design_path=sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD07/NBS/design.mat');

%% Read the matrices and organize the data
%Make a list of subjects
group1= dir(folder1);
group1= group1(3:end); group1= group1(8:16:end); %OJO! Needs change
group2= dir(folder2);
group2= group2(3:end); group2= group2(8:16:end);
subjectNum_per_group=length(group1);

%Design vector groups that contains indices 1 and 2 for the different groups
d = [group1; group2]; %list of subjects in the group
ids = find(triu(ones(N,N),1));
middle=length(d)/2;

%Organize the data according to NBS guidelines
for i=1:middle
    load(sprintf('%s/%s',folder1,d(i).name)) %load each adjacency matrix 
    Adj=Adj+Adj';
    %Adj=Adj+diag(ones(1,N));
    data(:,:,i)=Adj;
end
 
for i=middle+1:length(d)
    load(sprintf('%s/%s',folder2,d(i).name)) %load each adjacency matrix 
    Adj=Adj+Adj';
    %Adj=Adj+diag(ones(1,N)); %This line is commented out because inverse
    %z-score is performed later. If left, 1 would not be 1 anymore
    data(:,:,i)=Adj;
end

%From z-scores to correlations again
subNum=subjectNum_per_group*2;
for i=1:subNum
    data(:,:,i)=tanh(data(:,:,i));
    data(:,:,i)=data(:,:,i)+diag(ones(1,N));
end

%save(data_path,'data')
%data= data_path;

design1=zeros(subNum,1); design1(1:subjectNum_per_group,1)=ones(subjectNum_per_group,1);
design2=zeros(subNum,1); design2(subjectNum_per_group+1:end,1)=ones(subjectNum_per_group,1);
design_mat=[design1 design2];
save(design_path,'design_mat')
design_mat=design_path;
