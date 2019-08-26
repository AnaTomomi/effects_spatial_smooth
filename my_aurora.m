%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the effect size of the individual links that form  %
% the network detected by NBS. It only considers those "significant" links%
%                                                                         %
% 26.03.2019 Created by Ana T.                                            %
% 28.03.2019 Modified to include the Permutations                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

pipeline='Forward';
method='';%NBS
variant='Fisher_2019';%'Fisher', '50-50-Fisher', or 'Sphere-Fisher' for NBS
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
n1=33;
n2=33;

if strcmp(method,'NBS')
    excel_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Significant_Nets_%s.xlsx',variant);
    folder_mat='/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS/Forward';
else
    excel_file='/m/cs/scratch/networks/trianaa1/Paper1/Significant_Links_Forward_Thresholded_2019.xlsx';
    folder_mat='/m/cs/scratch/networks/data/ABIDE_II/Analysis/Permutations/';
end
    
[~,~,raw] = xlsread(excel_file);
smoothing=unique(raw(2:end,2));


%Select only the raws from the pipeline
Index = find(contains(raw(:,1),pipeline));
data_init=raw(Index,:);

%% Read the F-values for all the significant links at all levels

%Load all the F stats and significant links
N=246;
stats=struc([]);
con_mat=struc([]);

if strcmp(method,'NBS')
    for i=1:length(smoothing)
        load(sprintf('%s/NBS_Brainnetome_%smm_F-test_Fisher_2019.mat',folder_mat,smooth{i}))
        stats{i}=nbs.NBS.test_stat;
        con_mat{i}=nbs.NBS.con_mat{1,1};
    end
else
    for i=1:length(smoothing)
        load(sprintf('%s/%smm/EdgStat.mat',folder_mat,smoothing{i}))
        Edges_T=EdgStat.tvals;
        ids = find(triu(ones(N,N),1));
        stats{i}=zeros(N,N);
        stats{i}(ids)=Edges_T;
        stats{i}=stats{i}+stats{i}';
        
        idx = find(startsWith(raw(:,2),smoothing{i}));
        datum=raw(idx,:);
        con_mat{i}=zeros(N,N);
        for j=1:size(datum,1)
            con_mat{i}([datum{j,3}],[datum{j,5}])=1;
        end
        con_mat{i}=sparse(con_mat{i});
    end
end

for i=1:length(smoothing)
    number=nnz(con_mat{i});
    [id(:,1),id(:,2)]=find(con_mat{i});
    for j=1:number
        for k=1:length(smoothing)
            stat(j,k)=stats{k}(id(j,1),id(j,2)); %4
        end
    end
    dummy = horzcat(id,stat);
    if i~=1
        Ftest = vertcat(Ftest,dummy);
    else
        Ftest=dummy;
    end
    clear id;
    clear dummy;
    clear stat;
end
%clear duplicates of nodes
if ~strcmp(method,'NBS')
    Ftest(:,3:end)=Ftest(:,3:end).*Ftest(:,3:end);
end
[Ftest idxi idxj] = unique(Ftest,'first','rows');
Cohen=Ftest;

%Compute the Cohen's d for all the F-stats
Cohen(:,3:end) = sqrt(Cohen(:,3:end))*sqrt((n1+n2)/(n1*n2));

%% Create the mask (prevalence)

if ~strcmp(method,'NBS')
    for i=1:size(raw,1)
        raw{i,3}=num2str(raw{i,3});
        raw{i,5}=num2str(raw{i,5});
    end
end

raw(:,10)=strcat(raw(:,3),'-',raw(:,5));
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

%order by columns (smoothing levels)
[sort_column, order2]=sortrows(prevalence);
link_prevalence=unique(raw(2:end,10)); %order of links for the prevalence matrix
rownames=link_prevalence(order2);

%Test link orders
figure
heatmap(smoothing,rownames,sort_column,'Colormap',gray,'FontSize',7,'XLabel','Smoothing Kernel','YLabel','Links')

%Link orders are fine!

%% Plot with colors

for i=1:link_no
    link_cohen{i,1} = strcat(num2str(Cohen(i,1)),'-',num2str(Cohen(i,2)));
end

for i=1:size(rownames,1)
    Index = find(startsWith(link_cohen,rownames{i,1}));
    order_by_prevalence(i,1) = Index; 
end

ordered_Cohen = Cohen(order_by_prevalence,:);

hex=['#1c6ff8';'#1c6ff8';'#31db92';'#31db92';'#31db92';'#31db92';'#31db92';'#31db92';'#fef720';'#fef720';'#fef720';'#fef720';'#fef720'];
my_map = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
colormap(my_map)
caxis([0,1.3])


fig=imagesc(ordered_Cohen(:,3:end));
set(fig,'AlphaData',.5*sort_column+.5)
hold on
x=[0.5 0.5];
y=[0 120];
for i=1:16
    line(x+i,y,'Color','k')
end
colorbar
caxis([0,1.3])
xlabel('Smoothing level FWHM (mm)')
ylabel('Sample of Links')
title('Effect Size')
%set(gca,'XTick',[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16])
set(gca,'XTick',[])
set(gca,'XTickLabel',smooth)
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);
saveas(fig,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/effect_size_c1_v2_thr.eps','epsc')
saveas(fig,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/effect_size_c1_v2_thr.pdf')