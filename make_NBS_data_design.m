clear all
close all
clc

smooth=[0,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32];

pipeline='Forward'; %'Forward' or 'Inverse'
test='F-test';
N = 30; %number of ROIs 246 Brainnetome, 30, 98, 329 Craddock


for s=1:16
    smoothing=num2str(smooth(s));
    folder1=sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/group1/Brainnetome_%smm',smoothing);
    folder2=sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/group2/Brainnetome_%smm',smoothing);
    data_path=sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/NBS/temp/sphere_craddock30_%smm.mat',smoothing);
    design_path=sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/NBS/design.mat');
    
    group1= dir(folder1);
    group1= group1(3:end); group1= group1(14:16:end); %OJO! Needs change
    group2= dir(folder2);
    group2= group2(3:end); group2= group2(14:16:end);
    subjectNum_per_group=length(group1);
    
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
    
    save(data_path,'data')
end
