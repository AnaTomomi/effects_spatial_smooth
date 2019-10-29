%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the effects of smoothing in different parcellations%
%                                                                         %
% 26.03.2019 Created by Ana Triana                                        %
% 29.10.2019 Add save command by Ana Triana                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));

folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/NBS';
%folder='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/NBS';
save_path='/m/cs/scratch/networks/trianaa1/Paper1/Figures/ABIDE_extended';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
parcellation={'Brainnetome','Craddock100','Craddock350','sphere_Brainnetome','sphere_Craddock100','sphere_Craddock350'};
thres='16';

d=dir(folder);

kden=zeros(size(smooth,2),size(parcellation,2));
N=zeros(size(smooth,2),size(parcellation,2));
K=zeros(size(smooth,2),size(parcellation,2));
%Compute density 
for i=1:size(smooth,2)
    for j=1:size(parcellation,2)
        fprintf('smooth:%s and parcellation:%s \n',smooth{i},parcellation{j})
        load(sprintf('%s/NBS_%s_%smm_F-test_%s_Fisher_2019.mat',d(1).folder,parcellation{j},smooth{i},thres))
        if ~isempty(nbs.NBS.con_mat)
            adj=full(nbs.NBS.con_mat{1}+nbs.NBS.con_mat{1}');
            [kden(i,j),N(i,j),K(i,j)] = density_und(adj);
        end
    end
end

%Plot all thresholds
f=figure;
x=[str2double(smooth)]';
colors={'#4daf4a','#377eb8','#e41a1c'};
for i=1:3
    plot(x,kden(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
for i=1:3
    plot(x,kden(:,i+3),'--o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Subnetwork density')
xticks(x)
xticklabels(smooth)
title({'Effects of spatial smoothing in different parcellations';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(parcellation)
legend boxoff
box off
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);

saveas(f,sprintf('%s/NBS_parcellations_density.svg',save_path),'svg')
saveas(f,sprintf('%s/NBS_parcellations_density.eps',save_path),'epsc')

%Plot distance
% Density
f=figure;
x=[str2double(smooth)]';
scatter(x,kden(:,1),600,'filled')
hold on
scatter(x,kden(:,4),600,'d','filled')
xlabel('Smoothing level FWHM (mm)')
ylabel('Subnetwork density')
xticks(x)
xticklabels(smooth)
title({'Density of significant links per smoothing level';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend('Brainnetome ROIs','Fixed ROI size','Location','northwest')
legend boxoff
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);

saveas(f,sprintf('%s/NBS_Brainnetome_density.svg',save_path),'svg')
saveas(f,sprintf('%s/NBS_Brainnetome_density.eps',save_path),'epsc')