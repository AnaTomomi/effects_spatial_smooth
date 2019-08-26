clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/Violinplot-Matlab'))

%excel_file='/m/cs/scratch/networks/trianaa1/Paper1/Significant_Nets_Forward.xlsx';
pipeline='Forward';
analysis='individual'; %'individual' or 'together'
method='NBS'; %'NBS' or 'FDR'
variant='Fisher_2019';%'Fisher', '50-50-Fisher', or 'Sphere-Fisher' for NBS
                 %'', '_50-50', or '_Sphere' for FDR
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
n1=33;
n2=33;
              
if strcmp(method,'NBS')
    excel_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Significant_Nets_%s.xlsx',variant);
    [~,~,raw] = xlsread(excel_file);
    smoothing=unique(raw(2:end,2));
    folder_mat='/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS/Forward';
else
    excel_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Significant_Links_%s%s.xlsx',pipeline,variant);
    [~,~,raw] = xlsread(excel_file);
    smoothing=unique(raw(2:end,1));
    folder_mat='/m/cs/scratch/networks/data/ABIDE_II/Analysis/Stats/Forward';
end

%Select only the raws from the pipeline
Index = find(contains(raw(:,1),pipeline));
data_init=raw(Index,:);

%% Plotting
%Plot Cohen's d of significant links
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

Cohen_violin=NaN(82,16);
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

%% Now for everybody!

%Load all the F stats and significant links
stats=struc([]);
con_mat=struc([]);
for i=1:length(smoothing)
    load(sprintf('%s/NBS_Brainnetome_%smm_F-test_Fisher.mat',folder_mat,smooth{i}))
    stats{i}=nbs.NBS.test_stat;
    con_mat{i}=nbs.NBS.con_mat{1,1};
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
[Ftest idxi idxj] = unique(Ftest,'first','rows');
Cohen=Ftest;

%Compute the Cohen's d for all the F-stats
Cohen(:,3:end) = sqrt(Cohen(:,3:end))*sqrt((n1+n2)/(n1*n2));

%% Violin plots

figure
violinplot(Ftest(:,3:end))
hold on
x=linspace(1,16,16);
y=16*ones(size(x));
plot(x,y,'LineWidth',3,'Color','k')
xlabel('Smoothing level')
ylabel('F-statistic')
xticklabels(smooth)
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')

figure
violinplot(Cohen(:,3:end))
xlabel('Smoothing level')
ylabel('Cohens d')
xticklabels(smooth)
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')

%% Plot heatmaps

for i=1:length(Cohen)
    rownames{i,1}=strcat(num2str(Cohen(i,1)),'-',num2str(Cohen(i,2)));
end

colnames={'00','04','06','08','10','12','14','16','18','20','22','24','26','28','30','32'};

%my_map=[247,251,255;222,235,247;198,219,239;158,202,225;107,174,214;66,146,198;33,113,181;8,81,156;8,48,107];
my_map=[247,252,240;224,243,219;204,235,197;168,221,181;123,204,196;78,179,211;43,140,190;8,104,172;8,64,129];
my_map=flipud(my_map/255);

colormap(my_map)
figure
heatmap(colnames,rownames,Cohen(:,3:end),'Colormap',parula,'FontSize',7,'XLabel','Smoothing Kernel','YLabel','Links')
imagesc(Cohen(:,3:end))

%Spaguetti plot
x=[0,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32];
figure
hold on
for i=1:length(Cohen)
    plot(x,Cohen(i,3:end))
end

%% Trying some sorting...

der=diff(Cohen(:,3:end),1,2);    
signed_der=sign(der);
[ordered, order]=sortrows(signed_der);
sort_Cohen=Cohen(order,:);
%sort_Ftest(:,3:end)=sort_Ftest(:,3:end)-sort_Ftest(:,3);

for i=1:length(sort_Cohen)
    rownames{i,1}=strcat(num2str(sort_Cohen(i,1)),'-',num2str(sort_Cohen(i,2)));
end

figure
hex=['#081D58';'#253494';'#225EA8';'#1D91C0';'#41B6C4';'#7FCDBB';'#C7E9B4';'#EDF8B1';'#FFFFD9'];
my_map = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
colormap(my_map)
heatmap(colnames,rownames,sort_Cohen(:,3:end),'Colormap',parula,'FontSize',10,'XLabel','Smoothing Kernel','YLabel','Links')
title('Effect size of significant links at all smoothing levels')

%% Visualizing individually links

for i=1:length(Cohen)
    x=[0,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32];
    y=Cohen(i,3:end);
    plot(x,y)
    pause()
end
