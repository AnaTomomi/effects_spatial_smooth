clear all 
close all
clc

%% configure paths
%Human inputs
pipeline='Inverse'; %'Forward' or 'Inverse'
smoothing='0';%0,4,6,8,10,12,14,16,18
N = 246; %number of ROIs

%Configure the folders and files
folder1=sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/group1/%s/Brainnetome_%smm',pipeline,smoothing);
folder2=sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/group2/%s/Brainnetome_%smm',pipeline,smoothing);

%% Read the matrices and organize the data
%Make a list of subjects
group1= dir(folder1);
group1= group1(3:end); group1= group1(1:2:end);
group2= dir(folder2);
group2= group2(3:end); group2= group2(1:2:end);
d = [group1; group2]; %list of subjects in the group

subjectNum_per_group=length(group1);
ids = find(triu(ones(N,N),1));
edges = zeros(length(d),length(ids));
middle=length(d)/2;

for i=1:middle
    %Edge analysis
    load(sprintf('%s/%s',folder1,d(i).name)) %load each adjacency matrix 
    edges(i,:) = Adj(ids); %put every link in the matrix, organizes the adjacency matrices in a long vector inside a matrix, which row number is the number of subjects
end
 
for i=middle+1:length(d)
    %Edge analysis
    load(sprintf('%s/%s',folder2,d(i).name)) %load each adjacency matrix 
    edges(i,:) = Adj(ids); %put every link in the matrix, organizes the adjacency matrices in a long vector inside a matrix, which row number is the number of subjects
end

design_g1=csvread('/m/cs/scratch/networks/data/ABIDE_II/Analysis/group1/regress.csv',0,1);
design_g2=csvread('/m/cs/scratch/networks/data/ABIDE_II/Analysis/group2/regress.csv',0,1);
design_g=vertcat(design_g1,design_g2);

%% Fisher transform
edges(find(edges==-1))=-1+eps;edges(find(edges==1))=1-eps;edges=atanh(edges);

%% Regress the nuisance factors
num_edges=size(edges,2);
b=zeros(size(design_g,2),num_edges);
for i=1:num_edges
    b(:,i)=regress(edges(:,i),design_g);
    e(:,i)=edges(:,i)-(design_g*b(:,i));
end

%% Back to matrices

regressed_data=zeros(N,N,middle*2);
for i=1:(middle*2)
    subject=zeros(N,N);
    subject(ids)=e(i,:);
    regressed_data(:,:,i)=subject;
    %save(sprintf('%s/%s-reg.mat',d(i).folder,erase(d(i).name,'.mat')),'subject')
end

for i=1:(middle*2)
    load(sprintf('%s/%s_reg.mat',d(i).folder,erase(d(i).name,'.mat')))
    algo=Adj-regressed_data(:,:,i);
    fprintf('%s = maximum value: %d, minimum value: %d \n',d(i).name,max(max(algo)),min(min(algo)))
end
