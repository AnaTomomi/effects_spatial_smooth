%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the influence of NBS suprathreshold in the results %
% presented in the Effects of spatial smoothing paper                     %
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
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
thres={'2.25','4','6.25','9','12.25','16','20.25','25'};
parcellation='Brainnetome'; %'Brainnetome', 'Craddock30', 'Craddock100','Craddock350'
save_path='/m/cs/scratch/networks/trianaa1/Paper1/Figures/ABIDE_extended';

d=dir(folder);

if strcmp(parcellation,'Brainnetome')
    d=d(7:134); %select Brainnetome parcellations only
elseif strcmp(parcellation,'Craddock30')
    d=d(263:390);
elseif strcmp(parcellation,'Craddock100')
    d=d(135:262);
elseif strcmp(parcellation,'Craddock350')
    d=d(391:518);
end

kden=zeros(size(smooth,2),size(thres,2));
N=zeros(size(smooth,2),size(thres,2));
K=zeros(size(smooth,2),size(thres,2));
%Compute density 
for i=1:size(smooth,2)
    for j=1:size(thres,2)
        fprintf('smooth:%s and thres:%s \n',smooth{i},thres{j})
        load(sprintf('%s/NBS_%s_%smm_F-test_%s_Fisher_2019.mat',d(1).folder,parcellation,smooth{i},thres{j}))
        if ~isempty(nbs.NBS.con_mat)
            adj=full(nbs.NBS.con_mat{1}+nbs.NBS.con_mat{1}');
            [kden(i,j),N(i,j),K(i,j)] = density_und(adj);
        else
            kden(i,j)=0;
        end
    end
end

%Plot all thresholds
f=figure;
x=[str2double(smooth)]';
colors={'#f781bf','#a65628','#ffff33','#ff7f00','#984ea3','#4daf4a','#377eb8','#e41a1c'};
for i=1:size(thres,2)
    plot(x,kden(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Subnetwork density')
xticks(x)
xticklabels(smooth)
title({'Influence of NBS suprathresholds';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(thres)
legend boxoff
box off
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);

saveas(f,sprintf('%s/NBS_thresholds.svg',save_path),'svg')
saveas(f,sprintf('%s/NBS_thresholds.eps',save_path),'epsc')

%Plot a set of upper thresholds
f=figure;
x=[str2double(smooth)]';
kden_upper=kden(:,4:8);
thres_upper={'9','12.25','16','20.25','25'};
colors={'#ff7f00','#984ea3','#4daf4a','#377eb8','#e41a1c'};
for i=1:size(kden_upper,2)
    plot(x,kden_upper(:,i),'-o','color',colors{i},'LineWidth',3,'MarkerFaceColor',colors{i})
    hold on
end
xlabel('Smoothing level FWHM (mm)')
ylabel('Subetwork density')
xticks(x)
xticklabels(smooth)
title({'Influence of NBS suprathresholds';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend(thres_upper)
legend boxoff
box off
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);

saveas(f,sprintf('%s/NBS_thresholds_zoom1_v2.svg',save_path),'svg')
saveas(f,sprintf('%s/NBS_thresholds_zoom2_v2.eps',save_path),'epsc')
