clear all
close all
clc

power=csvread('/m/cs/scratch/networks/trianaa1/toolboxes/compare_modules/power2011_modules.csv');
load('/m/cs/scratch/networks/trianaa1/Atlas/brainnetome_MPM_rois_2mm.mat');
savepath='/m/cs/scratch/networks/trianaa1/Atlas/brainnetome_MPM_rois_2mm_PowerROIs.mat';

roi_size=size(rois,2);
std_size=size(power,1);

for i=1:roi_size
    for j=1:std_size
        D(j,1)=pdist2(rois(i).centroidMNI,power(j,2:4),'euclidean');
    end
    Idx=find(D==min(D));
    if size(Idx)==[1,1]
        rois(i).net=power(Idx,1);
        rois(i).dist=D(Idx);
    elseif power(Idx(1),1)==power(Idx(2),1)
        rois(i).net=power(Idx(1),1);
        rois(i).dist=D(Idx(1));
    else
        rois(i).net=NaN;
    end
end

save(savepath,'rois')