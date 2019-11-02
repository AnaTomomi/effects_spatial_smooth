function my_slurm_permutations_craddock100(idx)
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
savepath='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/Craddock100';


group1=dir(folder1); group1=group1(3:end); group1=group1(4:16:end);
group2=dir(folder2); group2=group2(3:end); group2=group2(4:16:end);

disp('parameters set')

%% Prepare the data
% Create the groups
groups = [1*ones(1,length(group1)) 2*ones(1,length(group2))];
d = [group1; group2];

disp('Data prepared')

% Prepare the matrices 
n=size(d,1);
N=98;
Strength = zeros(length(d),N);
Clus_we = zeros(length(d),N);
meanClus_we = zeros(length(d),1);
Eglob_we = zeros(length(d),1);
Eloc_we = zeros(length(d),N);
Betw_we = zeros(length(d),N);


for i=1:n
    load(sprintf('%s/%s',d(i).folder,d(i).name))
    Adj=tanh(Adj); %Unz-transform each regressed matrix
    Adj=Adj+Adj';%diag(ones(1,N));
    Adj=threshold_proportional(Adj, str2double(thr)); %Threshold the matrix to thr density
    Adj=weight_conversion(Adj, 'normalize');
    Strength(i,:)=double(strengths_und(Adj));
    Clus_we(i,:)=clustering_coef_wu(Adj)';
    CL1=1./clustering_coef_wu(Adj);CL1(CL1==Inf) = 0;
    meanClus_we(i) = mean(CL1);
    Eloc_we(i,:)=double(efficiency_wei(Adj,2))';
    Eglob_we(i) = double(efficiency_wei(Adj));
    Adj=weight_conversion(Adj, 'lengths'); %Required for betweenness centraility computations
    Betw_we(i,:) = betweenness_wei(Adj);
    %Dist=double(distance_bin(Adj));
    %Dist(Dist==Inf) = NaN;
end
disp('Matrices done')

%% Degree
% Start the permutations adn save them
StrStat = bramila_ttest2_np(Strength',groups,10000);
save(sprintf('%s/StrStat_%smm_%s.mat',savepath,smoothing,thr),'StrStat')

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

disp('Strength done!')

%% Clustering
ClusweStat = bramila_ttest2_np(Clus_we',groups,10000);
save(sprintf('%s/ClusweStat_%smm_%s.mat',savepath,smoothing,strrep(thr,'.','')),'ClusweStat')
disp('clustering done!')

%% Mean clustering
meanClusweStat = bramila_ttest2_np(meanClus_we',groups,10000);
save(sprintf('%s/meanClusweStat_%smm_%s.mat',savepath,smoothing,strrep(thr,'.','')),'meanClusweStat')
disp('Mean Clustering done!')

%% Global Efficiency
EglobweStat = bramila_ttest2_np(Eglob_we',groups,10000);
save(sprintf('%s/EglobweStat_%smm_%s.mat',savepath,smoothing,strrep(thr,'.','')),'EglobweStat')
disp('Global Efficiency done!')

%% Local Efficiency
ElocweStat = bramila_ttest2_np(Eloc_we',groups,10000);
save(sprintf('%s/ElocweStat_%smm_%s.mat',savepath,smoothing,strrep(thr,'.','')),'ElocweStat')
disp('Local Efficiency done!')

%% Betweeness centrality
BetwweStat = bramila_ttest2_np(Betw_we',groups,10000);
save(sprintf('%s/BetwweStat_%smm_%s.mat',savepath,smoothing,strrep(thr,'.','')),'BetwweStat')
disp('Betweeness centrality done!')


exit;
