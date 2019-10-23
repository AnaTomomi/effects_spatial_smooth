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
parcellation={'Brainnetome','Craddock30','Craddock100','Craddock350'};
thr='01'; %10% density
N=[246,30,98,329];

% Distance of links
for p=1:size(parcellation,2)
    %load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
    load(sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/masks/FD05/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
    
    %Calculate the distances
    for i=1:size(smooth,2)
        fprintf('smooth:%s and parcellation:%s \n',smooth{i},parcellation{p})
        %load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/%s/weightedlinks_%smm_%s.mat',parcellation{p},smooth{i},thr))
        load(sprintf('%s/%s/weightedlinks_%smm_%s.mat',folder,parcellation{p},smooth{i},thr))
    
        %Extract T-stat and p-val
        tstats = stats.tvals;
        pvals = 2*min(stats.pvals,[],2);
        pcor = mafdr(pvals,'BHFDR', 'true');
        
        ids = find(triu(ones(N(p),N(p)),1));
        links = zeros(N(p),N(p));
        links(ids) = tstats.*(pcor<0.05); %Organize results in matrix form
        %links=links+links';
        
        if sum(links(:))~=0
            [node1,node2]=find(links);
            for d=1:size(node1)
                dist(i,d)=abs(pdist2(rois(node1(d)).centroid, rois(node2(d)).centroid,'euclidean'));
            end
        else 
            dist(i,1)=0;
        end
    end
    
    %Violin plots
    dist=dist'; %The matrix should be distances in rows, smoothing in columns
    dist=dist*2;
    dist(dist==0) = NaN;
    
    for k=1:size(dist,2)
        if all(isnan(dist(:,k)))
            dist(1,k)=0;
        end
    end   
    
    fig=figure;
    violinplot(dist)
    xlabel('Smoothing level FWHM (mm)')
    ylabel('Distance (mm)')
    title(sprintf('Distances of significant links per smoothing level: %s',parcellation{p}))
    xticklabels(smooth)
    set(gca,'FontSize',20)
    set(gca, 'FontName', 'Arial')
    set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    set(gcf,'color',[1 1 1]);
    
    clear dist
end