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

%folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations';
folder='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/Permutations';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
thresholds={'005' '007' '009' '01' '011' '013' '015' '017' '019' '02'};
parcellation='Brainnetome'; %'Brainnetome', 'Craddock30', 'Craddock100','Craddock350'

d=dir(folder);

N=246;%,30,98,329];


kden=zeros(size(smooth,2),size(thresholds,2));
Node=zeros(size(smooth,2),size(thresholds,2));
K=zeros(size(smooth,2),size(thresholds,2));

for s=1:size(smooth,2)
    for t=1:size(thresholds,2)
       fprintf('smooth:%s and parcellation:%s \n',smooth{s},thresholds{t})
       %load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/%s/weightedlinks_%smm_%s.mat',parcellation,smooth{s},thresholds{t}))
       load(sprintf('%s/%s/weightedlinks_%smm_%s.mat',folder,parcellation,smooth{s},thresholds{t}))
    
        %Extract T-stat and p-val
        tstats = stats.tvals;
        pvals = 2*min(stats.pvals,[],2);
        pcor = mafdr(pvals,'BHFDR', 'true');
        
        ids = find(triu(ones(N,N),1));
        links = zeros(N,N);
        links(ids) = tstats.*(pcor<0.05); %Organize results in matrix form
        links=links+links';
        
        link_pval = zeros(N,N); %Organize the p-values 
        link_pval(ids) = pcor;
        
        links(links~=0)=1;
        [kden(s,t),Node(s,t),K(s,t)] = density_und(links);
   end
end

%Plot all thresholds
f=figure;
x=[str2double(smooth)]';
colors={'#6a3d9a','#cab2d6','#ff7f00','#fdbf6f','#e31a1c','#fb9a99','#33a02c','#b2df8a','#1f78b4','#a6cee3'};
for i=1:size(thresholds,2)
    plot(x,kden(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Network density')
xticks(x)
xticklabels(smooth)
title({'Influence of Network density';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(thresholds)
legend boxoff
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);

%Plot a set of upper thresholds
f=figure;
x=[str2double(smooth)]';
kden_upper=kden(:,3:10);
thres_upper={'009' '01' '011' '013' '015' '017' '019' '02'};
colors={'#ff7f00','#fdbf6f','#e31a1c','#fb9a99','#33a02c','#b2df8a','#1f78b4','#a6cee3'};
for i=1:size(kden_upper,2)
    plot(x,kden_upper(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Network density')
xticks(x)
xticklabels(smooth)
title({'Influence of Network density';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(thres_upper)
legend boxoff
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);

%Plot a set of a set of thresholds
f=figure;
x=[str2double(smooth)]';
kden_upper=kden(:,3:5);
thres_upper={'009' '01' '011'};
colors={'#ff7f00','#fdbf6f','#e31a1c'};
for i=1:size(kden_upper,2)
    plot(x,kden_upper(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Network density')
xticks(x)
xticklabels(smooth)
title({'Influence of Network density';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(thres_upper)
legend boxoff
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);

%Plot a set of a set of thresholds II
f=figure;
x=[str2double(smooth)]';
kden_upper=kden(:,6:8);
thres_upper={'013' '015' '017'};
colors={'#fb9a99','#33a02c','#b2df8a'};
for i=1:size(kden_upper,2)
    plot(x,kden_upper(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Network density')
xticks(x)
xticklabels(smooth)
title({'Influence of Network density';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(thres_upper)
legend boxoff
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);