%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script analyzes the effect size of the individual links that form  %
% the network detected by NBS. It only considers those "significant" links%
%                                                                         %
% 14.10.2019 Created by Ana T.                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

%folder='/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended/NBS';
folder='/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/NBS';
%save_path='/m/cs/scratch/networks/trianaa1/Paper1/Figures/ABIDE_extended';
save_path='/m/cs/scratch/networks/trianaa1/Paper1/Figures/UCLA';

smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
if strcmp(folder,'/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05/NBS')
    n1=22; 
    n2=22;
else
    n1=47;
    n2=47;
end
parcellation={'Brainnetome','Craddock100','Craddock350'};
thres='12.25';
N=[246,98,329];

%Load all the F stats and significant links
for p=1:size(parcellation,2)
    stats=struc([]);
    con_mat=struc([]);
    clear Ftest
    clear Cohen
    clear ordered_Cohen
    clear prevalence
    clear link_name
    
    for i=1:length(smooth)
        fprintf('smooth:%s and parcellation:%s \n',smooth{i},parcellation{p})
        load(sprintf('%s/NBS_%s_%smm_F-test_%s_Fisher_2019.mat',folder,parcellation{p},smooth{i},thres))
        stats{i}=nbs.NBS.test_stat;
        if ~isempty(nbs.NBS.con_mat)
            con_mat{i}=nbs.NBS.con_mat{1,1};
        else
            con_mat{i}=[];
        end
    end
    
    dummy=NaN(1,length(smooth)+2);
    for i=1:length(smooth)
        number=nnz(con_mat{i});
        if number~=0
            [id(:,1),id(:,2)]=find(con_mat{i});
            for j=1:number
                for k=1:length(smooth)
                    stat(j,k)=stats{k}(id(j,1),id(j,2)); %4
                end
            end
            dummy = horzcat(id,stat);
        else
            dummy=NaN(1,length(smooth)+2);
        end
   
        if i~=1
            Ftest = vertcat(Ftest,dummy);
        else
            Ftest=dummy;
        end
        clear id;
        clear dummy;
        clear stat;
    end
    
    %Remove NaNs
    Ftest(any(isnan(Ftest), 2), :) = [];
    
    %clear duplicates of nodes
    %Ftest(:,3:end)=Ftest(:,3:end).*Ftest(:,3:end); %Why on earth?
    
    if ~isempty(Ftest)
        [Ftest idxi idxj] = unique(Ftest,'first','rows');
        Cohen=Ftest;

        %Compute the Cohen's d for all the F-stats
        Cohen(:,3:end) = sqrt(Cohen(:,3:end))*sqrt((n1+n2)/(n1*n2));

        prevalence=Ftest(:,3:end);
        threshold=str2num(thres);
        prevalence(prevalence < threshold) = 0;
        prevalence(prevalence >= threshold) = 1;
        for ln=1:size(Cohen,1)
            link_name{ln,1}=strcat(num2str(Cohen(ln,1)),'-',num2str(Cohen(ln,2)));
        end

        %order by columns (smoothing levels)
        [sort_column, order]=sortrows(prevalence);
        rownames=link_name(order);

    %     %Test link orders
    %     figure
    %     heatmap(smooth,rownames,sort_column,'Colormap',gray,'FontSize',7,'XLabel','Smoothing Kernel','YLabel','Links')
    % 
    %     %Link orders are fine!

        %Plot with colors
        ordered_Cohen = Cohen(order,:);

        hex=['#1c6ff8';'#1c6ff8';'#31db92';'#31db92';'#31db92';'#31db92';'#31db92';'#31db92';'#fef720';'#fef720';'#fef720';'#fef720';'#fef720'];
        my_map = sscanf(hex','#%2x%2x%2x',[3,size(hex,1)]).' / 255;
        colormap(my_map)
        caxis([0,1.3])


        fig=imagesc(ordered_Cohen(:,3:end));
        set(fig,'AlphaData',.5*sort_column+.5)
        hold on
        x=[0.5 0.5];
        y=[0 size(ordered_Cohen,1)+1];
        for i=1:16
            line(x+i,y,'Color','k')
        end
        colorbar
        caxis([0,1])
        xlabel('Smoothing level FWHM (mm)')
        ylabel('Sample of Links')
        title(sprintf('Effect Size for: %s',parcellation{p}))
        set(gca,'XTick',[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16])
        set(gca,'XTick',[])
        set(gca,'XTickLabel',smooth)
        set(gca,'YTickLabel',[])
        set(gca,'YTick',[])
        set(gca,'FontSize',20)
        set(gca, 'FontName', 'Arial')
        set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
        set(gcf,'color',[1 1 1]);
        
        saveas(fig,sprintf('%s/NBS_%s_aurora.svg',save_path,parcellation{p}),'svg')
        saveas(fig,sprintf('%s/NBS_%s_aurora.eps',save_path,parcellation{p}),'epsc')
    end
    close all
end