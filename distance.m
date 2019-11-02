%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the influence of distance between ROIs at the links%
% discovered in each smoothing levels                                     %
%                                                                         %
% 26.03.2019 Modified by Ana T. Added comments on the contents of the file%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/Violinplot-Matlab'))

pipeline='Forward';
variant='Fisher_2019'; %'', 'Fisher', '_Sphere', %Sphere_Fisher
method='NBS';

group_mask='/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-Brainnetome-0-2mm_with_subcortl_and_cerebellum.mat';
save_path=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Figures/%s/%s-%s-distance_smooth',pipeline,method,variant);

if strcmp(method,'FDR')
    data=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Significant_Links_%s_%s.xlsx',pipeline,variant);
else
    data=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Significant_Nets_%s.xlsx',variant);
end

%% Euclidean distance influence on links
[~,~,txt] = xlsread(data);
load(group_mask)
txt{1,10}='Dist';
smoothing={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};

if strcmp(method,'FDR')
    smooth=unique(txt(2:end,1));
    sigLinksNo=size(txt,1);
    %Calculate the euclidean distance for significant links
    for i=2:sigLinksNo
        link1=txt{i,2};
        link2=str2double(txt{i,4});
        txt{i,8}=abs(pdist2(rois(link1).centroid, rois(link2).centroid,'euclidean'));
    end

    fig=figure
    for i=1:length(smooth)
        idx=find(strcmp(smooth{i,1},txt(:,1))==1);
        x=str2double(smooth{i,1})*ones(size(idx))';
        y=[txt{idx,8}];
        scatter(x,abs(y),35,'b','filled')
        hold on
        xlim([-0.5,18.5])
        ylim([0,80])
    end
    xlabel('Smooth level')
    ylabel('Distance')
    title('Distances of significant links per smoothing level')
    xticks([str2double(smoothing)])
    x=[0,18];
    plot(x,17*ones(size(x)),'--r','LineWidth',2)
    plot(x,44*ones(size(x)),'--r','LineWidth',2)
    %saveas(fig,save_path,'jpeg')
end

if strcmp(method,'NBS')
    idx=find(strcmp(pipeline,txt(:,1))==1);
    txt=txt(idx,:);
    smooth=unique(txt(2:end,2));
    sigLinksNo=length(txt);
    for i=1:246
        label{i}=rois(i).label;
    end
    for i=1:sigLinksNo
        link1=str2num(txt{i,3});
        link2=str2num(txt{i,5});
        %link1=find(strcmp(label,txt{i,4}));
        %link2=find(strcmp(label,txt{i,6}));
        txt{i,10}=abs(pdist2(rois(link1).centroid, rois(link2).centroid,'euclidean'));
    end
    fig=figure
    for i=1:length(smooth)
        idx=find(strcmp(smooth{i,1},txt(:,2))==1);
        x=str2double(smooth{i,1})*ones(size(idx))';
        y=[txt{idx,10}];
        scatter(x,abs(y),35,'b','filled')
        hold on
        xlim([-0.5,18.5])
        ylim([0,80])
    end
    xlabel('Smoothing level ')
    ylabel('Distance (cm)')
    %title('Distances of significant links per smoothing level')
    xticks([str2double(smoothing)])
    yticklabels({'0','20','40','60','80','100','120','140','160'})
    x=[0,18];
    plot(x,17*ones(size(x)),'--r','LineWidth',2)
    plot(x,44*ones(size(x)),'--r','LineWidth',2)
    set(gca,'FontSize',20)
    set(gca, 'FontName', 'Arial')
    %saveas(fig,save_path,'jpeg')
    
    dist_in_col=NaN(82,16);
    for i=1:length(smooth)
        idx=find(strcmp(smooth{i,1},txt(:,2))==1);
        n=size([txt{idx,10}],2);
        dist_in_col(1:n,i)=[txt{idx,10}]';
    end
    dist_in_col=dist_in_col*2;
    fig=figure
    violinplot(dist_in_col)
    xlabel('Smoothing level FWHM (mm)')
    ylabel('Distance (mm)')
    title('Distances of significant links per smoothing level')
    xticklabels(smoothing)
    set(gca,'FontSize',20)
    set(gca, 'FontName', 'Arial')
    set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    set(gcf,'color',[1 1 1]);
    saveas(fig,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/distance.svg','svg')
    %saveas(fig,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/distance.pdf')
end
%%Euclidean distance and influence on all links
% 
% smoothing={'0','4','6','8','10','12','14','16','18'};
% N=246;
% ids = find(triu(ones(N,N),1));
% 
% load(group_mask)
% dist=zeros(N,N);
% for i=1:N
%     for j=1:N
%         dist(i,j)=pdist2(rois(i).centroid,rois(j).centroid,'euclidean');
%     end
% end
% mask=triu(true(size(dist)),1);
% dist=dist(mask);
% 
% figure
% for i=1:length(smoothing)
%     load(sprintf('%s%smm.mat',stat,smoothing{1,i}))
%     subplot(3,3,i)
%     scatter(dist,stats.tvals,15,mycolors(i,:),'filled')
%     xlim([10,80])
%     ylim([3.5,5.5])
%     title(smoothing{1,i})
% end

