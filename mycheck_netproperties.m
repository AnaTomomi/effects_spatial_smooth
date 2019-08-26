%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the basic properties of the significant networks   %
% defined by the NBS Toolbox. It analyzes the networks for all levels of  %
% smoothing.                                                              %
% The basic analyzed properties are:                                      %
%                                 - density                               %
%                                 - assortativity                         %
%                                 - degree                                %
%                                 - local and global efficiency           %
%                                 - clustering                            %
%                                 - betweeness and eigenvector centrality %
% The script also computes the distance of the matrices using Hamming     %
% distance.                                                               %
%                                                                         %
% 26.03.2019 Modified by Ana T. Added comments on the contents of the file%
% 26.03.2019 Modified by Ana T. Change Hamming Distance color             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));

pipeline='Forward';
method='F-test_Fisher_2019';%50-50, Sphere, F-test_Fisher
folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};

d=dir(sprintf('%s/%s',folder,pipeline));
d=d(3:end);

%Compute stats of measures
for i=1:size(smooth,2)
    load(sprintf('%s/NBS_Brainnetome_%smm_%s.mat',d(1).folder,smooth{i},method))
    adj=full(nbs.NBS.con_mat{1}+nbs.NBS.con_mat{1}');
    [kden(i),N(i),K(i)] = density_und(adj);
    r(i) = assortativity_bin(adj,0);
    deg{i} = degrees_und(adj);
    d_avg(i) = mean([deg{i}]);
    E_global(i)=efficiency_bin(adj);
    CC=clustering_coef_bu(adj);
    C(i)=mean(CC);
    BC{i}=betweenness_bin(adj);
    BC_mean(i)=mean(BC{i});
    v{i} = eigenvector_centrality_und(adj);
    v_mean(i) = mean(v{i});
end

for i=1:size(smooth,2)
    if ~isfile(sprintf('%s/NBS_Brainnetome_%smm_F-test_Sphere-Fisher_2019.mat',d(1).folder,smooth{i}))
        kdens(i)=NaN;
    else
        load(sprintf('%s/NBS_Brainnetome_%smm_F-test_Sphere-Fisher_2019.mat',d(1).folder,smooth{i}))
        if isempty(nbs.NBS.con_mat)
            kdens(i)=0;Ns(i)=NaN;Ks(i)=NaN;
        else
            adj=full(nbs.NBS.con_mat{1}+nbs.NBS.con_mat{1}');
            [kdens(i),Ns(i),Ks(i)] = density_und(adj);
        end
    end
end

% Density
f=figure
x=[str2double(smooth)]';
scatter(x,kden,600,'filled')
hold on
scatter(x,kdens,600,'d','filled')
xlabel('Smoothing level FWHM (mm)')
ylabel('Network density')
xticks(x)
xticklabels(smooth)
title({'Density of significant links per smoothing level';'   '})
set(gca,'FontSize',20)
set(gca, 'FontName', 'Arial')
legend('Brainnetome ROIs','Fixed ROI size','Location','northwest')
legend boxoff
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);
saveas(f,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/density.eps','epsc')
%saveas(f,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/density.pdf')

% Assortativity
figure
x=[str2double(smooth)]';
scatter(x,r,60,'filled')
xlabel('Smoothing level')
ylabel('Assortativity')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

%Mean degree == density?
figure
x=[str2double(smooth)]';
scatter(x,d_avg,60,'filled')
xlabel('Smoothing level')
ylabel('Mean Degree')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

%Global Efficiency
figure
x=[str2double(smooth)]';
scatter(x,E_global,60,'filled')
xlabel('Smoothing level')
ylabel('Global Efficiency')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

%Average cluster coefficient
figure
x=[str2double(smooth)]';
scatter(x,C,60,'filled')
xlabel('Smoothing level')
ylabel('Average Cluster Coefficient')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

%Average Betweeness Centrality
figure
x=[str2double(smooth)]';
scatter(x,BC_mean,60,'filled')
xlabel('Smoothing level')
ylabel('Betweeness Centrality')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

%Average Eigenvector Centrality
figure
x=[str2double(smooth)]';
scatter(x,v_mean,60,'filled')
xlabel('Smoothing level')
ylabel('Eigenvector Centrality')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

% Degree distribution
figure 
for i=1:size(smooth,2)
    j=[1,3,5,7,9,11,13,15,2,4,6,8,10,12,14,16];
    subplot(8,2,j(i))
    idx=(deg{i}>0);
    H=deg{i}(idx);
    %y=histcounts(H);
    %y=y./246;
    %x=[0:1:size(y,2)-1];
    %plot(x,y,'Color',color(i,:),'LineWidth',2,'Marker','*')
    %hold on
    histogram(H)
    if i>=15
        xlabel('Node Degree')
    end
    %ylabel(strcat(smooth{i},'mm'))
    xlim([1,12])
    ylim([0,12])
    text(11,10,strcat(smooth{i},'mm'))
    if i==1
        title('Degree Distribution')
    end
    set(gca,'FontSize',10)
end

% Betweeness centrality coefficient distribution
figure 
for i=1:size(smooth,2)
    j=[1,3,5,7,9,11,13,15,2,4,6,8,10,12,14,16];
    subplot(8,2,j(i))
    idx=(BC{i}>0);
    H=BC{i}(idx)/((246-1)*(246-2));
    histogram(H,40)
    if i>=15
        xlabel('Node Degree')
    end
    xlim([0,0.008])
    ylim([0,10])
    text(0.007,8,strcat(smooth{i},'mm'))
    if i==1
        title('Betweeness centrality')
    end
    set(gca,'FontSize',10)
end

% Eigenvector centrality centrality coefficient distribution
figure 
for i=1:size(smooth,2)
    j=[1,3,5,7,9,11,13,15,2,4,6,8,10,12,14,16];
    subplot(8,2,j(i))
    idx=(v{i}>0);
    H=v{i}(idx);
    histogram(H,30)
    if i>=15
        xlabel('Node Degree')
    end
    xlim([0,0.45])
    ylim([0,22])
    text(0.4,9,strcat(smooth{i},'mm'))
    if i==1
        title('Eigenvector Centrality')
    end
    set(gca,'FontSize',10)
end

% Distance of matrices
for i=1:size(smooth,2)
    load(sprintf('%s/NBS_Brainnetome_%smm_%s.mat',d(1).folder,smooth{i},method))
    mat{i}=full(nbs.NBS.con_mat{1}+nbs.NBS.con_mat{1}');
end

hamming=zeros(size(smooth,2),size(smooth,2));

for i=1:size(smooth,2)
    for j=1:size(smooth,2)
        if i<j
            hamming_mat{i,j} = xor(logical(mat{i}),logical(mat{j}));
            %hamming(i,j)=sum(sum(abs(mat{i}-mat{j})))/(246*245);
            hamming(i,j) = (nnz(xor(logical(mat{i}),logical(mat{j}))))/(246*245);
        else
            hamming_mat{i,j} = zeros(246,246);
        end
    end
end

%Simmentric matrix
for i=1:size(smooth,2)
    for j=1:size(smooth,2)
            hamming_mat{i,j} = xor(logical(mat{i}),logical(mat{j}));
            %hamming(i,j)=sum(sum(abs(mat{i}-mat{j})))/(246*245);
            hamming(i,j) = (nnz(xor(logical(mat{i}),logical(mat{j}))))/(246*245);
    end
end
hamming = hamming.*-1;

%Hamming distances
f=figure
hex=['#003766';'#005399';'#1762A2';'#2E72AB';'#4581B4';'#5C91BE';'#73A1C7';'#8BB0D0';'#A2C0D9';'#B9D0E3';'#D0DFEC';'#FFFFFF']; %#E7EFF5
my_map = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
colormap(my_map)
heatmap(smooth,smooth,hamming,'Colormap',my_map,'FontSize',20,'XLabel','Smoothing Kernel','YLabel','Smoothing kernel','CellLabelColor','none')
title('Similarity matrix')
caxis([-0.003,0])
set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
set(gcf,'color',[1 1 1]);
saveas(f,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/hamming.eps','epsc')
%saveas(f,'/m/cs/scratch/networks/trianaa1/Paper1/Figures/Forward/hamming.pdf')
