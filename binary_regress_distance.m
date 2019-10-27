%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the influence of distance between ROIs at the links%
% discovered in each smoothing levels                                     %
%                                                                         %
% 14.10.2019 Modified by Ana T. Added comments on the contents of the file%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/Violinplot-Matlab'))

%folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/NBS';
folder='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/Permutations';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
parcellation={'Brainnetome','Craddock30','Craddock100','Craddock350'};
thr='01';
N=[246,30,98,329];

% Plots of distance of links
for p=1:size(parcellation,2)
    %Load and calculate the distance between all nodes in the parcellation
    %load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
    load(sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/masks/FD05/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
    
    dist=zeros(N(p),N(p));
    for n1=1:N(p)
        for n2=1:N(p)
            dist(n1,n2)=abs(pdist2(rois(n1).centroid, rois(n2).centroid,'euclidean'));
        end
    end
    
    ids=find(triu(dist));
    dist_vec=dist(ids);
    
    f=figure;
    hold on
    set(gca,'FontSize',20)
    set(gca, 'FontName', 'Arial')
    set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    set(gcf,'color',[1 1 1]);
    %Load the stats and plotting
    for i=1:size(smooth,2)
        fprintf('smooth:%s and parcellation:%s \n',smooth{i},parcellation{p})
        %load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/%s/weightedlinks_%smm_%s.mat',parcellation{p},smooth{i},thr))
        load(sprintf('%s/%s/weightedlinks_%smm_%s.mat',folder,parcellation{p},smooth{i},thr))
    
        %Extract T-stat and p-val
        tstats = stats.tvals;
        pvals = 2*min(stats.pvals,[],2);
        pcor = mafdr(pvals,'BHFDR', 'true');
        
        ids_s = find(triu(ones(N(p),N(p)),1));
        links = zeros(N(p),N(p));
        links(ids_s) = abs(tstats); %Organize results in matrix form
                   
        stats_vec=links(ids);
        
        subplot(2,8,i)
        scatter(dist_vec,stats_vec,'.')
        xlabel('Distance (mm)')
        ylabel('T-statistic')
        title(sprintf('Smooth: %s',smooth{i}))
        
        %coeffs(i,p)=corr(dist_vec, stats_vec, 'type', 'Spearman');
    end
end

%Spearman correlation
for p=1:size(parcellation,2)
    %Load and calculate the distance between all nodes in the parcellation
    %load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
    load(sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/masks/FD05/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
    
    dist=zeros(N(p),N(p));
    for n1=1:N(p)
        for n2=1:N(p)
            dist(n1,n2)=abs(pdist2(rois(n1).centroid, rois(n2).centroid,'euclidean'));
        end
    end
    
    ids=find(triu(dist));
    dist_vec=dist(ids);
    
    %Load the stats and plotting
    for i=1:size(smooth,2)
        fprintf('smooth:%s and parcellation:%s \n',smooth{i},parcellation{p})
        %load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/%s/weightedlinks_%smm_%s.mat',parcellation{p},smooth{i},thr))
        load(sprintf('%s/%s/weightedlinks_%smm_%s.mat',folder,parcellation{p},smooth{i},thr))
    
        %Extract T-stat and p-val
        tstats = stats.tvals;
        pvals = 2*min(stats.pvals,[],2);
        pcor = mafdr(pvals,'BHFDR', 'true');
        
        ids_s = find(triu(ones(N(p),N(p)),1));
        links = zeros(N(p),N(p));
        links(ids_s) = abs(tstats); %Organize results in matrix form
                   
        stats_vec=links(ids);
        
        coeffs(i,p)=corr(dist_vec, stats_vec, 'type', 'Spearman');
    end
end

f=figure;
colors={'#4daf4a','#984ea3','#377eb8','#e41a1c'};
x=[str2double(smooth)]';
for i=1:4
    plot(x,coeffs(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Spearman rho')
xticks(x)
xticklabels(smooth)
title('Effects of spatial smoothing in distance')
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(parcellation)
legend boxoff
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);