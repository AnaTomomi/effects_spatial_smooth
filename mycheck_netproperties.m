clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));

pipeline='Forward';
method='F-test_Fisher';%50-50, Sphere, F-test_Fisher
folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS';
smooth={'0','4','6','8','10','12','14','16','18'};

d=dir(sprintf('%s/%s',folder,pipeline));
d=d(3:end);

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
end

figure
x=[str2double(smooth)]';
scatter(x,kden,60,'filled')
xlabel('Smoothing level')
ylabel('Network density')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

figure
x=[str2double(smooth)]';
scatter(x,r,60,'filled')
xlabel('Smoothing level')
ylabel('Assortativity')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

figure
x=[str2double(smooth)]';
scatter(x,d_avg,60,'filled')
xlabel('Smoothing level')
ylabel('Mean Degree')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

figure
x=[str2double(smooth)]';
scatter(x,E_global,60,'filled')
xlabel('Smoothing level')
ylabel('Global Efficiency')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

figure
x=[str2double(smooth)]';
scatter(x,C,60,'filled')
xlabel('Smoothing level')
ylabel('Average Cluster Coefficient')
xticks(x)
xticklabels(smooth)
set(gca,'FontSize',18)

figure 
color=[228,26,28; 55,126,184; 77,175,74; 152,78,163; 255,127,0; 255,255,51; 166,86,40; 247,129,191; 153,153,153];
color=color./255;
for i=1:9
    subplot(9,1,i)
    y=histcounts(deg{i});
    y=y./246;
    x=[0:1:size(y,2)-1];
    plot(x,y,'Color',color(i,:),'LineWidth',2,'Marker','*')
    hold on
    xlim([0,12])
    legend(smooth{i})
    xlabel('Node Degree')
    ylabel('Probability')
    set(gca,'FontSize',10)
end
