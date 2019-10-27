clear all
close all
clc

%folder = '/m/cs/scratch/networks/data/ABIDE_II/Analysis/ABIDE_extended';
%text_path = '/m/cs/scratch/networks/trianaa1/Paper1/Figures/ABIDE_extended';
folder = '/m/cs/scratch/networks/data/UCLA_openneuro/Analysis/FD05';
text_path = '/m/cs/scratch/networks/trianaa1/Paper1/Figures/UCLA';

mode = 'Permutations'; %'NBS' or 'Permutations'
parcellation = 'Brainnetome';
smooth={'0','4','6','8','10','12','14','16','18','20','22','24','26','28','30','32'};
threshold='013';
N=246;

folder = sprintf('%s/%s',folder,mode);
load(sprintf('/m/cs/scratch/networks/trianaa1/Atlas/%s_MPM_rois_2mm_PowerROIs.mat',parcellation))

if strcmp(mode, 'NBS')
    for s=1:length(smooth)
        fprintf('%s/NBS_%s_%smm_F-test_%s_Fisher_2019.mat \n',folder,parcellation,smooth{s},threshold)
        load(sprintf('%s/NBS_%s_%smm_F-test_%s_Fisher_2019.mat',folder,parcellation,smooth{s},threshold))
        if ~isempty(nbs.NBS.con_mat)
            [i,j]=find(nbs.NBS.con_mat{1});
            for n=1:length(i)
                %Get the labels
                i_lab=rois(i(n)).label;
                j_lab=rois(j(n)).label;
                stat=nbs.NBS.test_stat(i(n),j(n));

                %Format the labels
                node1_split=strsplit(i_lab,'_');
                node2_split=strsplit(j_lab,'_');
                node1_mod=erase(i_lab,strcat('_',node1_split{1,2}));
                node2_mod=erase(j_lab,strcat('_',node2_split{1,2}));
                text(n,:)={lower(node1_split{1,2}),node1_mod,lower(node2_split{1,2}),node2_mod,'0','0.7'};
            end
            text=cell2table(text);
            text_file=sprintf('%s/maps%s-%s.links.txt',text_path,smooth{s},parcellation);
            writetable(text,text_file,'WriteVariableNames',false,'Delimiter',' ')
            clear text
        end
    end
end

if strcmp(mode, 'Permutations')
    for s=1:length(smooth)
        fprintf('%s/%s/weightedlinks_%smm_%s.mat \n',folder,parcellation,smooth{s},threshold)
        load(sprintf('%s/%s/weightedlinks_%smm_%s.mat',folder,parcellation,smooth{s},threshold))
        
        %Extract T-stat and p-val
        tstats = stats.tvals;
        pvals = 2*min(stats.pvals,[],2);
        pcor = mafdr(pvals,'BHFDR', 'true');
        
        ids = find(triu(ones(N,N),1));
        links = zeros(N,N);
        links(ids) = abs(tstats.*(pcor<0.05)); %Organize results in matrix form
        
        [i j]=find(links);
        for n=1:length(i)
            %Get the labels
            i_lab=rois(i(n)).label;
            j_lab=rois(j(n)).label;
            stat=links(i(n),j(n));

            %Format the labels
            node1_split=strsplit(i_lab,'_');
            node2_split=strsplit(j_lab,'_');
            node1_mod=erase(i_lab,strcat('_',node1_split{1,2}));
            node2_mod=erase(j_lab,strcat('_',node2_split{1,2}));
            text(n,:)={lower(node1_split{1,2}),node1_mod,lower(node2_split{1,2}),node2_mod,'0','0.7'};
         end
        text=cell2table(text);
        text_file=sprintf('%s/weightmaps%s-%s.links.txt',text_path,smooth{s},parcellation);
        writetable(text,text_file,'WriteVariableNames',false,'Delimiter',' ')
        clear text
    end
end
