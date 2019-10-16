%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the effects of smoothing in binary networks        %
% Here we analyze the significant results for graph measures, including   %
% effects of parcellations and network density.                           %
%                                                                         %
% 15.10.2019 Created by Ana Triana                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/Violinplot-Matlab'))
addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/Paper1'))

folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations';
excel_path='/m/cs/scratch/networks/trianaa1/Paper1/ABIDE_extended_files/binary_parcellation.xlsx';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
parcellation={'Brainnetome','Craddock30','Craddock100','Craddock350'};
meas = {'DegStat', 'BetwStat','ClusStat','EglobStat','ElocStat','meanClusStat'};
thr='01'; %10% density

d=dir(folder);

%Influence of the parcellation
for p=1:size(parcellation,2)
    for m=1:size(meas,2)
        fprintf('Computing for %s \n',meas{m})
        for s=1:size(smooth,2)
            if m==1
                load(sprintf('%s/%s/%s_%smm_%s.%s.mat',folder,parcellation{p},meas{m},smooth{s},thr(1),thr(2)))
            else
                load(sprintf('%s/%s/%s_%smm_%s.mat',folder,parcellation{p},meas{m},smooth{s},thr))
            end
       
            Stat = eval(meas{m});
            tstats = Stat.tvals;
            pvals = 2*min(Stat.pvals,[],2);
            pcor = mafdr(pvals,'BHFDR', 'true');
            Signficant = tstats.*(pcor<0.05);%.*(sum(Degree~=0)>1)';
            node = find(Signficant~=0);
            if isempty(node)
                dummy(1,1) = str2num(smooth{s});
                dummy(1,2) = nan;
                dummy(1,3) = nan;
            else
                dummy(:,1) = ones(size(node,1),1)*str2num(smooth{s});
                dummy(:,2) = node';
                dummy(:,3) = pcor(node)';
            end
            if s==1
                array = dummy;
            else
                array = vertcat(array,dummy);
            end
            clear dummy
        end
        results{p,m} = array;
        clear array
    end
end

%Organizing in tables
par_num=[1,2,3,4]; %1Brainnetome, 2Craddock30, 3Craddock100, 4Craddock350
for m=1:size(meas,2)
    table=zeros(1,4);
    for p=1:size(parcellation,2)
        explore=results{p,m};
        if ~all(isnan(explore(:,2)))
            explore=explore(~isnan(explore(:,2)),:);
            explore(:,4)=ones(size(explore,1),1)*par_num(p);
            table=vertcat(table,explore);
            clear explore
        end
    end
    writematrix(table,excel_path,'Sheet',meas{m})
    clear table
end


%% Influence of the thresholds
clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/Violinplot-Matlab'))
addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/Paper1'))

folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations';
excel_path='/m/cs/scratch/networks/trianaa1/Paper1/ABIDE_extended_files/binary_graphmeas.xlsx';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
parcellation={'Brainnetome','Craddock30','Craddock100','Craddock350'};
meas = {'DegStat', 'BetwStat','ClusStat','EglobStat','ElocStat','meanClusStat'};
thresholds={'005' '007' '009' '01' '011' '013' '015' '017' '019' '02'};

d=dir(folder);

for t=1:size(thresholds,2)
    thr=thresholds{t};
    for m=1:size(meas,2)
        fprintf('Computing for %s and thresholded at %s \n',meas{m},thr)
        for s=1:size(smooth,2)
            if m==1
                load(sprintf('%s/Brainnetome/%s_%smm_%s.%s.mat',folder,meas{m},smooth{s},thr(1),thr(2:end)))
            else
                load(sprintf('%s/Brainnetome/%s_%smm_%s.mat',folder,meas{m},smooth{s},thr))
            end
       
            Stat = eval(meas{m});
            tstats = Stat.tvals;
            pvals = 2*min(Stat.pvals,[],2);
            pcor = mafdr(pvals,'BHFDR', 'true');
            Signficant = tstats.*(pcor<0.05);%.*(sum(Degree~=0)>1)';
            node = find(Signficant~=0);
            if isempty(node)
                dummy(1,1) = str2num(smooth{s});
                dummy(1,2) = nan;
                dummy(1,3) = nan;
            else
                dummy(:,1) = ones(size(node,1),1)*str2num(smooth{s});
                dummy(:,2) = node';
                dummy(:,3) = pcor(node)';
            end
            if s==1
                array = dummy;
            else
                array = vertcat(array,dummy);
            end
            clear dummy
        end
        results{t,m} = array;
        clear array
    end
end
clear array

thres_num=[5, 7, 9, 10, 11, 13, 15, 17, 19, 20];
%Organizing in tables
for m=1:size(meas,2)
    table=zeros(1,4);
    for t=1:size(thresholds,2)
        explore=results{t,m};
        if ~all(isnan(explore(:,2)))
            explore=explore(~isnan(explore(:,2)),:);
            explore(:,4)=ones(size(explore,1),1)*thres_num(t);
            table=vertcat(table,explore);
            clear explore
        end
    end
    writematrix(table,excel_path,'Sheet',meas{m})
    clear table
end

%Plotting
for i=1:size(meas,2)
    measure=readmatrix(excel_path,'Sheet',meas{i});
    if sum(measure(:))~=0
        nodes=unique(measure(:,1));
        for n=1:size(nodes,1)
            explore=measure(find(measure(:,1)==nodes(n)),:);
            matrix=zeros(21,33);
            for j=1:size(explore,1)
                matrix(explore(j,3)+1,explore(j,2)+1)=1;
            end
            matrix(:,2:4)=[];
            matrix(:,3:2:end)=[];
            matrix=matrix(6:end,:);
            matrix([2,4,8,10,12,14],:)=[];
            
            figure
            heatmap(smooth,thresholds,matrix,'Colormap',gray,'FontSize',10,'XLabel','Smoothing Kernel','YLabel','Network Density (%)')
            title(sprintf('Effect Size for %s, node: %s',meas{i},num2str(nodes(n))))
        end
    end
end