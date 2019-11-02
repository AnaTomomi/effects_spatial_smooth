%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the effects of smoothing in binary networks        %
% Here we analyze the significant results for graph measures, including   %
% effects of parcellations and network density. The tables are            %
% automatically generated for archival.                                   %
%                                                                         %
% 02.11.2019 Created by Ana Triana                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Influence of the thresholds
clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/Violinplot-Matlab'))
addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));
addpath(genpath('/m/cs/scratch/networks/trianaa1/Paper1'))

folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations';
%folder='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/Permutations';
excel_path='/m/cs/scratch/networks/trianaa1/Paper1/ABIDE_extended_files/binary_graphmeas_Craddock350.xlsx';
%excel_path='/m/cs/scratch/networks/trianaa1/Paper1/UCLA_files/binary_graphmeas.xlsx';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
meas = {'DegStat', 'BetwStat','ClusStat','EglobStat','ElocStat','meanClusStat'};
thresholds={'005' '007' '009' '01' '011' '013' '015' '017' '019' '02'};

d=dir(folder);

for t=1:size(thresholds,2)
    thr=thresholds{t};
    for m=1:size(meas,2)
        fprintf('Computing for %s and thresholded at %s \n',meas{m},thr)
        for s=1:size(smooth,2)
            if m==1
                load(sprintf('%s/Craddock350/%s_%smm_%s.%s.mat',folder,meas{m},smooth{s},thr(1),thr(2:end)))
            else
                load(sprintf('%s/Craddock350/%s_%smm_%s.mat',folder,meas{m},smooth{s},thr))
            end
       
            Stat = eval(meas{m});
            tstats = Stat.tvals;
            pvals = 2*min(Stat.pvals,[],2);
            pcor = mafdr(pvals,'BHFDR', 'true');
            Signficant = tstats;%.*(pcor<0.05);%.*(sum(Degree~=0)>1)';
            node = find(pcor~=0);
            if isempty(node)
                dummy(1,1) = str2num(smooth{s});
                dummy(1,2) = nan;
                dummy(1,3) = nan;
            else
                dummy(:,1) = ones(size(node,1),1)*str2num(smooth{s});
                dummy(:,2) = node';
                dummy(:,3) = Signficant(node);
                dummy(:,4) = pcor(node)';
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
    table=zeros(1,5);
    for t=1:size(thresholds,2)
        explore=results{t,m};
        if ~all(isnan(explore(:,2)))
            explore=explore(~isnan(explore(:,2)),:);
            explore(:,5)=ones(size(explore,1),1)*thres_num(t);
            table=vertcat(table,explore);
            clear explore
        end
    end
    writematrix(table,excel_path,'Sheet',meas{m})
    clear table
end