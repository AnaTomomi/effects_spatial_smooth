%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the effects of smoothing in different parcellations%
% in binary, undirected networks                                          %
%                                                                         %
% 16.16.2019 Created by Ana Triana                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/Violinplot-Matlab'))
addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/Paper1'))

folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
parcellation={'Brainnetome','Craddock30','Craddock100','Craddock350'};
thr='01'; %10% density

d=dir(folder);

N=[246,30,98,329];


kden=zeros(size(smooth,2),size(parcellation,2));
Node=zeros(size(smooth,2),size(parcellation,2));
K=zeros(size(smooth,2),size(parcellation,2));

for s=1:size(smooth,2)
    for p=1:size(parcellation,2)
       fprintf('smooth:%s and parcellation:%s \n',smooth{s},parcellation{p})
       load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/%s/links_%smm_%s.mat',parcellation{p},smooth{s},thr))
    
        %Extract T-stat and p-val
        tstats = stats.tvals;
        pvals = 2*min(stats.pvals,[],2);
        pcor = mafdr(pvals,'BHFDR', 'true');
        
        ids = find(triu(ones(N(p),N(p)),1));
        links = zeros(N(p),N(p));
        links(ids) = tstats.*(pcor<0.05); %Organize results in matrix form
        links=links+links';
        
        link_pval = zeros(N(p),N(p)); %Organize the p-values 
        link_pval(ids) = pcor;
        
        [kden(s,p),Node(s,p),K(s,p)] = density_und(links);
   end
end

%Plot all parcellations
f=figure;
x=[str2double(smooth)]';
colors={'#4daf4a','#984ea3','#377eb8','#e41a1c'};
for i=1:4
    plot(x,kden(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Network density')
xticks(x)
xticklabels(smooth)
title({'Effects of spatial smoothing in different parcellations';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(parcellation)
legend boxoff
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);