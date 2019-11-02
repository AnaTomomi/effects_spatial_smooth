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
%folder='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/NBS';
save_path='/m/cs/scratch/networks/trianaa1/Paper1/Figures/ABIDE_extended';
%save_path='/m/cs/scratch/networks/trianaa1/Paper1/Figures/UCLA';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
parcellation={'Brainnetome','Craddock100','Craddock350'};
thres='16';
N=[246,98,329];

% % Plots of distance of links
% for p=1:size(parcellation,2)
%     %Load and calculate the distance between all nodes in the parcellation
%     load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
%     %load(sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/masks/FD05/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
%     
%     dist=zeros(N(p),N(p));
%     for n1=1:N(p)
%         for n2=1:N(p)
%             dist(n1,n2)=abs(pdist2(rois(n1).centroid, rois(n2).centroid,'euclidean'));
%         end
%     end
%     
%     ids=find(triu(dist));
%     dist_vec=dist(ids);
%     
%     f=figure;
%     hold on
%     set(gca,'FontSize',20)
%     set(gca, 'FontName', 'Arial')
%     set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
%     set(gcf,'color',[1 1 1]);
%     %Load the stats and plotting
%     for i=1:size(smooth,2)
%         fprintf('smooth:%s and parcellation:%s \n',smooth{i},parcellation{p})
%         load(sprintf('%s/NBS_%s_%smm_F-test_%s_Fisher_2019.mat',folder,parcellation{p},smooth{i},thres))
%         stats=nbs.NBS.test_stat;             
%         stats_vec=stats(ids);
%         
%         subplot(2,8,i)
%         scatter(dist_vec,stats_vec,'.')
%         xlabel('Distance (mm)')
%         ylabel('F-statistic')
%         title(sprintf('Smooth: %s',smooth{i}))
%         
%         %coeffs(i,p)=corr(dist_vec, stats_vec, 'type', 'Spearman');
%     end
% end

%Spearman correlation
for p=1:size(parcellation,2)
    %Load and calculate the distance between all nodes in the parcellation
    load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
    %load(sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/masks/FD05/group_roi_mask-%s-0-2mm_with_subcortl_and_cerebellum.mat',parcellation{p}));
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
        load(sprintf('%s/NBS_%s_%smm_F-test_%s_Fisher_2019.mat',folder,parcellation{p},smooth{i},thres))
        stats=nbs.NBS.test_stat;             
        stats_vec=stats(ids);
        
        coeffs(i,p)=corr(dist_vec, stats_vec, 'type', 'Spearman');
    end
end

f=figure;
colors={'#4daf4a','#377eb8','#e41a1c'};
x=[str2double(smooth)]';
for i=1:3
    plot(x,coeffs(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Spearman rho')
xticks(x)
xticklabels(smooth)
ylim([-0.2 0.2])
title('Effects of spatial smoothing in distance')
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(parcellation)
legend boxoff
box off
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);

saveas(f,sprintf('%s/NBS_distance_regress_v2.svg',save_path),'svg')
saveas(f,sprintf('%s/NBS_distance_regress_v2.eps',save_path),'epsc')

f=figure;
colors={'#4daf4a'};
x=[str2double(smooth)]';
plot(x,coeffs(:,1),'-o','color',colors{1},'LineWidth',3,'MarkerFaceColor',colors{1})
xlabel('Smoothing level FWHM (mm)')
ylabel('Spearman rho')
xticks(x)
xticklabels(smooth)
ylim([-0.15 0.15])
title('Effects of spatial smoothing in distance')
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
box off
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);

saveas(f,sprintf('%s/NBS_%s_distance_regress.svg',save_path,parcellation{1}),'svg')
saveas(f,sprintf('%s/NBS_%s_distance_regress.eps',save_path,parcellation{1}),'epsc')