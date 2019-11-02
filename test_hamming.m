%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the influence of NBS suprathreshold in the results %
% presented in the Effects of spatial smoothing paper                     %
%                                                                         %
% 26.03.2019 Created by Ana Triana                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/BCT'));

%folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/NBS';
folder='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/NBS';
%save_path='/m/cs/scratch/networks/trianaa1/Paper1/Figures/ABIDE_extended';
save_path='/m/cs/scratch/networks/trianaa1/Paper1/Figures/UCLA';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
parcellation={'Brainnetome'};%,'Craddock100','Craddock350'};
thres='12.25';
N=[246];%,98,329];

% Distance of matrices
for p=1:size(parcellation,2)
    record=NaN(1,length(smooth));
    for i=1:size(smooth,2)
        fprintf('smooth:%s and parcellation:%s \n',smooth{i},parcellation{p})
        load(sprintf('%s/NBS_%s_%smm_F-test_%s_Fisher_2019.mat',folder,parcellation{p},smooth{i},thres))
        if ~isempty(nbs.NBS.con_mat)
            mat{i}=full(nbs.NBS.con_mat{1}+nbs.NBS.con_mat{1}');
        else
            mat{i}=zeros(N(p),N(p));
            record(i)=i;
        end
    end
    record=record(~isnan(record));
    
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
    for i=1:length(record)
        hamming(record(i),:)=NaN(1,16);
        hamming(:,record(i))=NaN(16,1);
    end

    %Hamming distances
    f=figure;
    %hex=['#003766';'#005399';'#1762A2';'#2E72AB';'#4581B4';'#5C91BE';'#73A1C7';'#8BB0D0';'#A2C0D9';'#B9D0E3';'#D0DFEC';'#FFFFFF']; %#E7EFF5
    hex=['#003766';'#1762A2';'#4581B4';'#73A1C7';'#8BB0D0';'#A2C0D9';'#D0DFEC';'#FFFFFF'];
    my_map = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
    colormap(my_map)
    heatmap(smooth,smooth,hamming,'Colormap',my_map,'FontSize',20,'XLabel','Smoothing Kernel','YLabel','Smoothing kernel','CellLabelColor','none','MissingDataColor','#C0C0C0')
    title(sprintf('Similarity matrix for %s',parcellation{p}))
    caxis([-0.004,0])
    set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    set(gcf,'color',[1 1 1]);
    
    saveas(f,sprintf('%s/NBS_%s_hamming.svg',save_path,parcellation{p}),'svg')
    saveas(f,sprintf('%s/NBS_%s_hamming.eps',save_path,parcellation{p}),'epsc')
end
