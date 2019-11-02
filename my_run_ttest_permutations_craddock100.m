function my_run_ttest_permutations_craddock100(idx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script runs permutations analysis for links only                   %
% This script detects differences between the ASD and TC for one smoothing%
% level at a time.                                                        %
%                                                                         %
% ?? Created by Ana T.                                                    %
% 03.10.2019 Modified by Ana T. Add comments to know what it does         %
% 07.10.2019 Fix bug in the binarization of the matrices                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Add path to bramila tool box
addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila'));
addpath(genpath('/m/cs/scratch/cs-e5700-2017/hcp/brain_networks/scripts'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/scripts'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));

%Configure ROIs
N = 98; %number of ROIs
pipeline='Forward'; %'Forward' or 'Inverse'

smooth=[0,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32];
thr=[0.01 0.02];%[0.05 0.07 0.09 0.10 0.11 0.13 0.15 0.17 0.19 0.20];

[A,B] = meshgrid(smooth,thr);
c=cat(2,A',B');
comb=reshape(c,[],2);

clear smoothing
clear thres

smoothing=num2str(comb(idx+1,1));
thr=num2str(comb(idx+1,2));

fprintf('Computing permutations for smooth:%s and thres:%s \n',smoothing,thr)

%set the paths
% folder1= sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/group1/Brainnetome_%smm',smoothing);
% folder2= sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/group2/Brainnetome_%smm',smoothing);
% savepath= sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/Craddock100/links_%smm_%s',smoothing,strrep(thr,'.',''));
folder1= sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/group1/Brainnetome_%smm',smoothing);
folder2= sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/group2/Brainnetome_%smm',smoothing);
savepath= sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/Permutations/Craddock100/links_%smm_%s.mat',smoothing,strrep(thr,'.',''));
%savefigpath= sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Figures/%s',pipeline);
%excel_file=sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/Brainnetome/humanlinks_%smm_%s',smoothing,strrep(thr,'.',''));

%Make a list of subjects
group1= dir(folder1);
group1= group1(3:end); group1= group1(4:16:end);
group2= dir(folder2);
group2= group2(3:end); group2= group2(4:16:end);

%Design vector groups that contains indices 1 and 2 for the different groups
groups = [1*ones(1,length(group1)) 2*ones(1,length(group2))]; %design of groups
%groups = ones(1,2*length(group1)); groups(1,2:2:end)=2;
d = [group1; group2]; %list of subjects in the group

disp('Configurations done...')
%% Test edge weight differences

ids = find(triu(ones(N,N),1));
edges = zeros(length(d),length(ids));
middle=length(d)/2;

disp('Reading the edges...')
for i=1:middle
    %Edge analysis
    load(sprintf('%s/%s',folder1,d(i).name)) %load each adjacency matrix 
    Adj=tanh(Adj);
    Adj=Adj+Adj';%diag(ones(1,N));
    Adj=threshold_proportional(Adj, str2double(thr)); %Threshold the matrix to thr density
    Adj=weight_conversion(Adj, 'binarize');
    edges(i,:) = Adj(ids); %put every link in the matrix, organizes the adjacency matrices in a long vector inside a matrix, which row number is the number of subjects
end
 
for i=middle+1:length(d)
    %Edge analysis
    load(sprintf('%s/%s',folder2,d(i).name)) %load each adjacency matrix 
    Adj=tanh(Adj);
    Adj=Adj+Adj';%diag(ones(1,N));
    Adj=threshold_proportional(Adj, str2double(thr)); %Threshold the matrix to thr density
    Adj=weight_conversion(Adj, 'binarize');
    edges(i,:) = Adj(ids); %put every link in the matrix, organizes the adjacency matrices in a long vector inside a matrix, which row number is the number of subjects
 end

%% Edge weights

%Fisher Z-transform the edge correlations
%edges(find(edges==-1))=-1+eps;edges(find(edges==1))=1-eps;edges=atanh(edges);

disp('Starting permutations...')
stats = bramila_ttest2_np(edges',groups,10000);
% %load(sprintf('stats_Brainnetome_%smm',smoothing));
% tstats = stats.tvals;
% pvals = 2*min(stats.pvals,[],2);
% 
% disp('Permutations done, starting significance analysis...')
% 
% pcor = mafdr(pvals,'BHFDR', 'true'); %Estimate false discovery rate for multiple hypothesis testing
% 
% % Which edges are significantly larger in ASD than in TC
% edge1largerthan2 = zeros(N,N);
% tstat_msk = tstats.*(tstats>0 & pcor<0.05); %Take only those t-stats significantly larger
% edge1largerthan2(ids) = tstat_msk; %Back into matrix form 
% edge1largerthan2_size=size(find(tstat_msk~=0),1);
% 
% % Which edges are significantly larger in TC than in ASD
% edge2largerthan1 = zeros(N,N);
% tstat_msk = tstats.*(tstats<0 & pcor<0.05);
% edge2largerthan1(ids) = tstat_msk;
% edge2largerthan1_size=size(find(tstat_msk~=0),1);
% 
% %Into symmetric matrices
% edge1largerthan2 = edge1largerthan2'+edge1largerthan2;
% edge2largerthan1 = edge2largerthan1'+edge2largerthan1;
% 
% % Summarizing all results
% tstat_msk = tstats.*(pcor<0.05); %Take only those T-values that are smaller than 0.05
% edge_results = zeros(N,N);
% edge_results(ids) = tstat_msk;
% edge_results_size=size(find(tstat_msk~=0),1);
% edge_pvals = zeros(N,N);
% edge_pvals(ids) = pcor;
% 
% disp(sprintf('ASD > TC: %s \n TC > ASD> %s \n Total: %s', num2str(edge1largerthan2_size),num2str(edge2largerthan1_size),num2str(edge_results_size)))
save(savepath,'stats')

%% Visualization
% disp('Stats saved! Starting visualization...')
% 
% load /m/cs/scratch/networks/trianaa1/Atlas/brainnetome_labels.mat
% [~,~,txt] = xlsread('/m/cs/scratch/networks/trianaa1/Atlas/BNA_subregions.xlsx');
% txt=repmat(txt(2:end,6),1,2);
% human_labels=cell(2*length(txt),1);
% human_labels(1:2:end,1)=strcat(txt(:,1),'-L'); 
% human_labels(2:2:end,1)=strcat(txt(:,1),'-R');
% human_labels=regexprep(human_labels,',','');
% 
% % [~,~,raw] = xlsread(excel_file);
% % init_row=size(raw,1)+1;
% raw=[];
% indxs=find(edge_results~=0);
% for ii=1:length(indxs)
%     indx = indxs(ii);
%     [row,col]=ind2sub(size(edge_results),indx);
%     raw(init_row,:)={smoothing,num2str(row),human_labels{row},num2str(col),human_labels{col},num2str(edge_results(indx)),num2str(edge_pvals(indx))};
%     init_row=init_row+1;
%     % fprintf('Edge between %s and %s\n',human_labels{row},human_labels{col})
%     % fprintf('ROI ids %s and %s\n',num2str(row),num2str(col))
%     % fprintf('T-stat: %s and q-value: %s\n',num2str(edge_results(indx)),num2str(edge_pvals(indx)))
% end
% 
% filename=excel_file;
% raw=cell2table(raw);
% writetable(raw,filename,'WriteVariableNames',false)

% if ~isempty(indxs)
% %Plot edge results
% sigedge = edges(:,find(tstat_msk>0));
% fig=figure;
% [f1,xi1] = ksdensity(sigedge(groups==1)); plot(xi1,f1,'r', 'LineWidth', 3);
% hold on
% [f2,xi2] = ksdensity(sigedge(groups==2)); plot(xi2,f2,'b', 'LineWidth', 3);
% xlim([0 max([xi1 xi2])])
% xlabel('Edge weight')
% title(sprintf('Edge weight distributions at %s mm', smoothing))
% legend('ASD','TC')
% saveas(fig,sprintf('%s/WeightDist_%smm_Sphere.png',savefigpath,smoothing))
% close(fig)
% 
% fig=figure;
% x = sigedge(groups==1);
% y = sigedge(groups==2);
% h1 = histogram(x);
% hold on
% h2 = histogram(y);
% h1.Normalization = 'pdf';
% h1.BinWidth = 0.1;
% h2.Normalization = 'pdf';
% h2.BinWidth = 0.1;
% [f1,xi1] = ksdensity(sigedge(groups==1)); plot(xi1,f1,'b', 'LineWidth', 3);
% [f2,xi2] = ksdensity(sigedge(groups==2)); plot(xi2,f2,'r', 'LineWidth', 3);
% xlabel('Edge weight')
% title(sprintf('Edge weight distributions at %s mm', smoothing))
% legend('ASD','TC','ASD,density','TC,density')
% saveas(fig,sprintf('%s/WeightHist_%smm_Sphere.png',savefigpath,smoothing))
% close all
% end
exit;