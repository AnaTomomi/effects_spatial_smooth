clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/Violinplot-Matlab'))
addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/Paper1'))

smooth={'00','04','06','08','10','12','14','16','18'};%,'20','22','24','26','28','30','32'};
load /m/cs/scratch/networks/trianaa1/Atlas/brainnetome_labels.mat
excel_file = '/m/cs/scratch/networks/trianaa1/Paper1/Significant_Links_Forward_Thresholded_2019.xlsx';
N=246;
subjectNum_per_group=33;

%% Organize the information of all significant links at all levels
for s=1:size(smooth,2)
    load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/Permutations/%smm/EdgStat.mat',smooth{s}))
    
    %Extract T-stat and p-val
    tstats = EdgStat.tvals;
    pvals = 2*min(EdgStat.pvals,[],2);
    pcor = mafdr(pvals,'BHFDR', 'true'); %Correct for q-values

    % ASD = zeros(N,N);%ASD edges are stronger than TC
    % ASD(ids) = tstats.*(tstats>0 & pcor<0.05);
    % TC = zeros(N,N);%TC edges are stronger than ASD
    % TC(ids) = tstats.*(tstats<0 & pcor<0.05);
    % ASD = ASD'+ASD;
    % TC = TC'+TC;

    %Create the matrix of significant different elements
    ids = find(triu(ones(N,N),1));
    links = zeros(N,N);
    links(ids) = tstats.*(pcor<0.05);
    link_pval = zeros(N,N);
    link_pval(ids) = pcor;

    [i,j]=find(links);
    if s==1
        raw(:,1)=ones(size(i,1),1)*str2num(smooth{s});
        raw(:,2)=i;
        raw(:,4)=j;
        raw(:,6)=nonzeros(links);
    else
        clear dummy
        dummy(:,1)=ones(size(i,1),1)*str2num(smooth{s});
        dummy(:,2)=i;
        dummy(:,4)=j;
        dummy(:,6)=nonzeros(links);
        raw=vertcat(raw,dummy);
    end
end

raw = num2cell(raw);
for i=1:size(raw,1)
    raw{i,3}=labels{raw{i,2}};
    raw{i,5}=labels{raw{i,4}};
    raw{i,7}=abs(raw{i,6})*sqrt((subjectNum_per_group+subjectNum_per_group)/(subjectNum_per_group*subjectNum_per_group));
end

raw=cell2table(raw);
%writetable(raw,excel_file,'WriteVariableNames',false)
%% Analyze the links

[~,~,raw] = xlsread(excel_file);

%% Distance of the links
group_mask='/m/cs/scratch/networks/data/ABIDE_II/Forward/masks/group_roi_mask-Brainnetome_0mm-0-2mm_with_subcortl_and_cerebellum.mat';
load(group_mask)
txt=raw;
txt{1,10}='Dist';
smoothing=unique(raw(2:end,2));

idx=find(strcmp('Forward',txt(:,1))==1);
txt=txt(idx,:);
smooth=unique(txt(2:end,2));
sigLinksNo=length(txt);
    for i=1:246
        label{i}=rois(i).label;
    end
    for i=1:sigLinksNo
        link1=(txt{i,3});
        link2=(txt{i,5});
        %link1=find(strcmp(label,txt{i,4}));
        %link2=find(strcmp(label,txt{i,6}));
        txt{i,9}=abs(pdist2(rois(link1).centroid, rois(link2).centroid,'euclidean'));
    end
    fig=figure
    for i=1:length(smooth)
        idx=find(strcmp(smooth{i,1},txt(:,2))==1);
        x=str2double(smooth{i,1})*ones(size(idx))';
        y=[txt{idx,9}];
        scatter(x,abs(y),35,'b','filled')
        hold on
        xlim([-0.5,18.5])
        ylim([0,80])
    end
    xlabel('Smoothing level')
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
    
    dist_in_col=NaN(15,9);
    for i=1:length(smooth)
        idx=find(strcmp(smooth{i,1},txt(:,2))==1);
        n=size([txt{idx,10}],2);
        dist_in_col(1:n,i)=[txt{idx,10}]';
    end
    dist_in_col=dist_in_col*2;
    fig=figure
    violinplot(dist_in_col)
    xlabel('Smoothing level (mm)')
    ylabel('Distance (cm)')
    title('Distances of significant links per smoothing level')
    xticklabels(smoothing)
    set(gca,'FontSize',20)
    set(gca, 'FontName', 'Arial')


%% Effect size of links 
smoothing=unique(raw(2:end,2));
Index = find(contains(raw(:,1),'Forward'));
data_init=raw(Index,:);
figure
for j=1:length(smoothing)
    Index = find(startsWith(data_init(:,2),smoothing{j}));
    data=data_init(Index,:);
    y=[data{:,8}]';
    size(y)
    x=str2double(smoothing{j})*ones(size(y));
    scatter(x,y,'.b')
    hold on
end
xlabel('Smoothing level')
ylabel('Cohens d')
x=[str2double(smooth)]';
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')

Cohen_violin=NaN(15,9);
for i=1:length(smoothing)
    Index = find(startsWith(data_init(:,2),smoothing{i}));
    n=size(Index,1);
    Cohen_violin(1:n,i)=[data_init{Index,8}]';
end

figure
violinplot(Cohen_violin)
xlabel('Smoothing level (mm)')
ylabel('Cohens d')
xticklabels(smooth)
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
title('Effect size of significant links')

%% Prevalence of links
for i=2:size(raw,1)
    raw{i,10}=strcat(num2str(raw{i,3}),'-',num2str(raw{i,5}));
end
smoothing=unique(raw(2:end,2));
link=unique(raw(2:end,10));

link_no=length(link);
smooth_no=length(smoothing);
prevalence =zeros(link_no,smooth_no);
for i=1:link_no%iterate over links
    for j=1:smooth_no %iterate over smoothing levels
        Index = find(startsWith(raw(:,2),smoothing{j}));
        data_init=raw(Index,:);
        if any(strcmp(data_init(:,10), link{i}))
            prevalence(i,j)=1;
        end
    end
end
%prevalence order = links

prev=sum(prevalence,2);
[ordered, order]=sortrows(prev);
persistence=prevalence(order,:);
link=link(order);

new_ordered=zeros(size(persistence));
kernel_prev=unique(prev);

for i=1:length(kernel_prev)
    Index=find(ordered==kernel_prev(i));
    [new_ordered(Index,:), new_order]=sortrows(persistence(Index,:),'descend');
    link_tmp=link(Index);
    new_link(Index,1)=link_tmp(new_order);
end

heatmap(smoothing,new_link,new_ordered,'Colormap',gray,'FontSize',7,'XLabel','Smoothing Kernel','YLabel','Links') %This is ok in order of links!

figure
[sort_column, order2]=sortrows(prevalence);
link=unique(raw(2:end,10)); %order of links for the prevalence matrix
rownames=link(order2);
heatmap(smoothing,rownames,sort_column,'Colormap',gray,'FontSize',14,'XLabel','Smoothing Kernel','YLabel','Links','CellLabelColor','none')


%% Analysis for other measurements
clear dummy;
meas = {'DegStat', 'BetwStat','ClusStat','EglobStat','ElocStat','meanClusStat'};
for m=1:size(meas,2)
    measure = meas{m};
    for s=1:size(smooth,2)
        load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/Permutations/%smm/%s.mat',smooth{s},measure))
        [~,name,ext] = fileparts(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/Permutations/%smm/%s.mat',smooth{s},measure));
        Stat = eval(name);
        tstats = Stat.tvals;
        pvals = 2*min(Stat.pvals,[],2);
        pcor = mafdr(pvals,'BHFDR', 'true');
        Deg = tstats.*(pcor<0.05);%.*(sum(Degree~=0)>1)';
        node = find(Deg~=0);
        if isempty(node)
            dummy(1,1) = str2num(smooth{s});
            dummy(1,2) = nan;
        else
            dummy(:,1) = ones(size(node,1),1)*str2num(smooth{s});
            dummy(:,2) = node';
        end
        if s==1
            array = dummy;
        else
            array = vertcat(array,dummy);
        end
        clear dummy
    end
    meas{m} = array;
end


