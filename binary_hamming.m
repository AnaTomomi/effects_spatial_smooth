%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes Hamming distance between matrices for the binary,  %
% thresholded networks                                                    %
%                                                                         %
% 26.03.2019 Created by Ana Triana                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));

smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
parcellation={'Brainnetome','Craddock30','Craddock100','Craddock350'};
thr='01';
N=[246,30,98,329];

% Distance of matrices
for p=1:size(parcellation,2)
    for i=1:size(smooth,2)
        fprintf('smooth:%s and parcellation:%s \n',smooth{i},parcellation{p})
        %load(sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/Permutations/%s/weightedlinks_%smm_%s.mat',parcellation{p},smooth{i},thr))
        load(sprintf('/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/Permutations/%s/weightedlinks_%smm_%s.mat',parcellation{p},smooth{i},thr))
    
        %Extract T-stat and p-val
        tstats = stats.tvals;
        pvals = 2*min(stats.pvals,[],2);
        pcor = mafdr(pvals,'BHFDR', 'true');
        
        ids = find(triu(ones(N(p),N(p)),1));
        links = zeros(N(p),N(p));
        links(ids) = tstats.*(pcor<0.05);
        mat{i}=links;
        
    end
    
    hamming=zeros(size(smooth,2),size(smooth,2));
    
    %Simmetric matrix
    for i=1:size(smooth,2)
        for j=1:size(smooth,2)
                hamming_mat{i,j} = xor(logical(mat{i}),logical(mat{j}));
                %hamming(i,j)=sum(sum(abs(mat{i}-mat{j})))/(246*245);
                hamming(i,j) = (nnz(xor(logical(mat{i}),logical(mat{j}))))/(N(p)*(N(p)-1));
        end
    end
    hamming = hamming.*-1;

    %Hamming distances
    f=figure;
    hex=['#003766';'#005399';'#1762A2';'#2E72AB';'#4581B4';'#5C91BE';'#73A1C7';'#8BB0D0';'#A2C0D9';'#B9D0E3';'#D0DFEC';'#FFFFFF']; %#E7EFF5
    my_map = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
    colormap(my_map)
    heatmap(smooth,smooth,hamming,'Colormap',my_map,'FontSize',20,'XLabel','Smoothing Kernel','YLabel','Smoothing kernel','CellLabelColor','none')
    title(sprintf('Similarity matrix for %s',parcellation{p}))
    %caxis([-0.001,0])
    set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    set(gcf,'color',[1 1 1]);
end