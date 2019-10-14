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

folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/NBS';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
parcellation={'Brainnetome','Craddock30','Craddock100','Craddock350'};
thres='6.25';
N=[246,30,98,329];

% Distance of links
for p=1:size(parcellation,2)
    load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
    
    %Calculate the distances
    for i=1:size(smooth,2)
        fprintf('smooth:%s and parcellation:%s \n',smooth{i},parcellation{p})
        load(sprintf('%s/NBS_%s_%smm_F-test_%s_Fisher_2019.mat',folder,parcellation{p},smooth{i},thres))
        if ~isempty(nbs.NBS.con_mat)
            [node1,node2]=find(nbs.NBS.con_mat{1});
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