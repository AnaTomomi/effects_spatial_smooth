function my_slurm_permutations(idx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script runs permutations analysis for basic graph measurements     %
% This script detects differences between the ASD and TC for one smoothing%
% level at a time.                                                        %
%                                                                         %
% ?? Created by Ana T.                                                    %
% 03.10.2019 Modified by Ana T. Add comments to know what it does         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/Paper1'))

pipeline='Forward';
smooth=[0,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32];
thr=[0.05 0.07 0.09 0.10 0.11 0.13 0.15 0.17 0.19 0.20];
%thr=0.1;

[A,B] = meshgrid(smooth,thr);
c=cat(2,A',B');
comb=reshape(c,[],2);

clear smoothing
clear thres

smoothing=num2str(comb(idx+1,1));
thr=num2str(comb(idx+1,2));

fprintf('Computing permutations for smooth:%s and thres:%s \n',smoothing,thr)


%smoothing=num2str(smoothing);
%smoothing=smooth{idx+1};
folder1=sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/group1/Brainnetome_%smm',smoothing);
folder2=sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/group2/Brainnetome_%smm',smoothing);
savepath='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/Brainnetome';


group1=dir(folder1); group1=group1(3:end); group1=group1(2:4:end);
group2=dir(folder2); group2=group2(3:end); group2=group2(2:4:end);

disp('parameters set')

%% Prepare the data
% Create the groups
groups = [1*ones(1,length(group1)) 2*ones(1,length(group2))];
d = [group1; group2];

disp('Data prepared')

% Prepare the matrices 
n=size(d,1);
N=246;
Deg = zeros(length(d),N);
Clus = zeros(length(d),N);
meanClus = zeros(length(d),1);
Eglob = zeros(length(d),1);
Eloc = zeros(length(d),N);
Betw = zeros(length(d),N);


for i=1:n
    load(sprintf('%s/%s',d(i).folder,d(i).name))
    Adj=tanh(Adj); %Unz-transform each regressed matrix
    %Adj=Adj+diag(ones(1,N));
    Adj=threshold_absolute(Adj, thr); %Threshold the matrix to thr density
    Deg(i,:)=double(degrees_und(Adj));
    Clus(i,:)=clustering_coef_bu(Adj)';
    CL1=1./clustering_coef_bu(Adj);CL1(CL1==Inf) = 0;
    meanClus(i) = mean(CL1);
    Eloc(i,:)=double(efficiency_bin(Adj,1))';
    Eglob(i) = double(efficiency_bin(Adj));
    Betw(i,:) = betweenness_bin(Adj);
    %Dist=double(distance_bin(Adj));
    %Dist(Dist==Inf) = NaN;
end
disp('Matrices done')

%% Degree
% Start the permutations adn save them
DegStat = bramila_ttest2_np(Deg',groups,10000);
save(sprintf('%s/DegStat_%smm_%s',savepath,smoothing,thr),'DegStat')

% %Get the T and P values
% DegT = DegStat.tvals;
% DegP = 2*min(DegStat.pvals,[],2);
% 
% % Correct the P value
% DegQ = mafdr(DegP,'BHFDR', 'true');
% 
% % Get the two tails
% Deg1largerthan2 = DegT.*(DegT>0 & DegQ<0.05).*(sum(Deg~=0)>1)';
% Deg2largerthan1 = DegT.*(DegT<0 & DegQ<0.05).*(sum(Deg~=0)>1)';

disp('Degree done!')

%% Clustering
ClusStat = bramila_ttest2_np(Clus',groups,10000);
save(sprintf('%s/ClusStat_%smm_%s',savepath,smoothing,strrep(thr,'.','')),'ClusStat')
disp('clustering done!')

%% Mean clustering
meanClusStat = bramila_ttest2_np(meanClus',groups,10000);
save(sprintf('%s/meanClusStat_%smm_%s',savepath,smoothing,strrep(thr,'.','')),'meanClusStat')
disp('Mean Clustering done!')

%% Global Efficiency
EglobStat = bramila_ttest2_np(Eglob',groups,10000);
save(sprintf('%s/EglobStat_%smm_%s',savepath,smoothing,strrep(thr,'.','')),'EglobStat')
disp('Global Efficiency done!')

%% Local Efficiency
ElocStat = bramila_ttest2_np(Eloc',groups,10000);
save(sprintf('%s/ElocStat_%smm_%s',savepath,smoothing,strrep(thr,'.','')),'ElocStat')
disp('Local Efficiency done!')

%% Betweeness centrality
BetwStat = bramila_ttest2_np(Betw',groups,10000);
save(sprintf('%s/BetwStat_%smm_%s',savepath,smoothing,strrep(thr,'.','')),'BetwStat')
disp('Betweeness centrality done!')


exit;
