%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the overlap of the significant networks found by   %
% NBS. It performs the Spearman correlation between the vectorized Adjacen%
% cy matrices to calculate their overlap.                                 %
%                                                                         %
% 28.03.2019 Created by Ana T.                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

pipeline='Forward';
method='NBS';
variant='Fisher_2019';%'Fisher', '50-50-Fisher', or 'Sphere-Fisher' for NBS
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
n1=33;
n2=33;

if strcmp(method,'NBS')
    excel_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Significant_Nets_%s.xlsx',variant);
    folder_mat='/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS/Forward';
else
    excel_file='/m/cs/scratch/networks/trianaa1/Paper1/Significant_Links_Forward_Thresholded_2019.xlsx';
    folder_mat='/m/cs/scratch/networks/data/ABIDE_II/Analysis/Permutations/';
end

[~,~,raw] = xlsread(excel_file);
smoothing=unique(raw(2:end,2));
Index = find(contains(raw(:,1),pipeline));
data_init=raw(Index,:);

ids = find(triu(ones(246,246),1));
stats=struc([]);
con_mat=struc([]);
vector_stats=struc([]);

if strcmp(method,'NBS')
    for i=1:length(smoothing)
        load(sprintf('%s/NBS_Brainnetome_%smm_F-test_Fisher_2019.mat',folder_mat,smooth{i}))
        stats{i}=nbs.NBS.test_stat;
        con_mat{i}=nbs.NBS.con_mat{1,1};
        vector_stats{i}=nbs.NBS.test_stat(ids);
    end
else
    for i=1:length(smoothing)
        load(sprintf('%s/%smm/EdgStat.mat',folder_mat,smoothing{i}))
        vector_stats{i}=EdgStat.tvals;
    end
    smooth=smoothing;
end

for i=1:length(smoothing)
    for j=1:length(smoothing)
        [rho(i,j),pval(i,j)] = corr(vector_stats{i},vector_stats{j},'Type','Spearman');
    end
end

f=figure
if strcmp(method,'NBS')
    hex=['#003766';'#005399';'#1762A2';'#2E72AB';'#4581B4';'#5C91BE';'#73A1C7';'#A2C0D9';'#E7EFF5';'#FFFFFF']; %#E7EFF5
else
    hex=['#003766';'#2E72AB';'#73A1C7';'#FFFFFF']; %#E7EFF5
end
my_map = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
colormap(my_map)
heatmap(smooth,smooth,rho,'Colormap',my_map,'FontSize',20,'XLabel','Smoothing Kernel','YLabel','Smoothing kernel','CellLabelColor','none')
title('Overlap matrix')
caxis([0,1])
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);
saveas(f,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/overlap.svg','svg')
%saveas(f,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/overlap.pdf')