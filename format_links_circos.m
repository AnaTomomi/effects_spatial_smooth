clear all
close all
clc

%excel_file='/m/cs/scratch/networks/trianaa1/Paper1/Significant_Nets_Forward.xlsx';
pipeline='Forward';
analysis='individual'; %'individual' or 'together'
method='NBS'; %'NBS' or 'FDR'
variant='Fisher_2019';%'Fisher', '50-50-Fisher', or 'Sphere-Fisher' for NBS
                 %'', '_50-50', or '_Sphere' for FDR

if strcmp(method,'NBS')
    excel_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Significant_Nets_%s.xlsx',variant);
    [~,~,raw] = xlsread(excel_file);
    smoothing=unique(raw(2:end,2));
else
    excel_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Significant_Links_%s%s.xlsx',pipeline,variant);
    [~,~,raw] = xlsread(excel_file);
    smoothing=unique(raw(2:end,1));
end

%% format for NBS 

if strcmp(method,'NBS')
    Index = find(contains(raw(:,1),pipeline));
    data_init=raw(Index,:);
    if strcmp(analysis,'individual')
        for j=1:length(smoothing)
            Index = find(startsWith(data_init(:,2),smoothing{j}));
            data=data_init(Index,:);
            size_data=size(data,1);
            for i=1:size_data
                node1_split=strsplit(data{i,4},'_');
                node2_split=strsplit(data{i,6},'_');
                node1_mod=erase(data{i,4},strcat('_',node1_split{1,2}));
                node2_mod=erase(data{i,6},strcat('_',node2_split{1,2}));
                    %     if isempty(find(contains(list,node1_mod)))
                    %         node1_mod=data{i,3};
                    %     end
                    %     if isempty(find(contains(list,node2_mod)))
                    %         node2_mod=data{i,4};
                    %     end
                weight=str2double(data{i,7})/(max(str2double(data(:,7))));
                text(i,:)={lower(node1_split{1,2}),node1_mod,lower(node2_split{1,2}),node2_mod,'0',num2str(weight)};
            end
            text=cell2table(text);
            text_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Figures/%s/maps%s-%s.links.txt',pipeline,smoothing{j},variant);
            writetable(text,text_file,'WriteVariableNames',false,'Delimiter',' ')
            clear text
        end
    end
    
    if strcmp(analysis,'together')
        size_data_init=size(data_init,1);
        for i=1:size_data_init
            data_init{i,6}=strcat(data_init{i,3},'-',data_init{i,4});
        end
        [D,~,X] = unique(data_init(:,6));
        Y = hist(X,unique(X));
        Z = struct('name',D,'freq',num2cell(Y(:)));
        size_z=length(Z);
        
        for i=1:size_z
            nodes(1,1:2)=strsplit(Z(i).name,'-');
            node1_split=strsplit(nodes{1,1},'_');
            node2_split=strsplit(nodes{1,2},'_');
            
            node1_mod=erase(nodes{1,1},strcat('_',node1_split{1,2}));
            node2_mod=erase(nodes{1,2},strcat('_',node2_split{1,2}));
            %     if isempty(find(contains(list,node1_mod)))
            %         node1_mod=nodes{1,1};
            %     end
            %     if isempty(find(contains(list,node2_mod)))
            %         node2_mod=nodes{1,2};
            %     end
            
            if Z(i).freq>6
                link='1';
            elseif Z(i).freq>3 && Z(i).freq<=6
                link='2';
            else
                link='0';
            end
            
            text(i,:)={lower(node1_split{1,2}),node1_mod,lower(node2_split{1,2}),node2_mod,link,num2str(Z(i).freq/9)};
        end
        text=cell2table(text);
        text_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Figures/%s/maps-group-%s.links.txt',pipeline,variant);
        writetable(text,text_file,'WriteVariableNames',false,'Delimiter',' ')
        clear text
    end
end

%% formatting for FDR
if strcmp(method,'FDR') && strcmp(analysis,'together')
    load /m/cs/scratch/networks/trianaa1/Atlas/brainnetome_labels.mat
    for i=2:length(raw)
        raw(i,2)=labels(str2double(raw(i,2)),1);
        raw(i,4)=labels(str2double(raw(i,4)),1);
        raw{i,8}=strcat(raw{i,2},'-',raw{i,4});
    end
    raw=raw(2:end,:);
    [D,~,X] = unique(raw(:,8));
    Y = hist(X,unique(X));
    Z = struct('name',D,'freq',num2cell(Y(:)));
    size_z=length(Z);
    
    for i=1:size_z
    nodes(1,1:2)=strsplit(Z(i).name,'-');
    node1_split=strsplit(nodes{1,1},'_');
    node2_split=strsplit(nodes{1,2},'_');
    
    node1_mod=erase(nodes{1,1},strcat('_',node1_split{1,2}));
    node2_mod=erase(nodes{1,2},strcat('_',node2_split{1,2}));
    
%     if isempty(find(contains(list,node1_mod)))
%         node1_mod=nodes{1,1};
%     end
%     if isempty(find(contains(list,node2_mod)))
%         node2_mod=nodes{1,2};
%     end
    
    if Z(i).freq>6
        link='1';
    elseif Z(i).freq>3 && Z(i).freq<=6
        link='2';
    else
        link='0';
    end
    
    text(i,:)={lower(node1_split{1,2}),node1_mod,lower(node2_split{1,2}),node2_mod,link,num2str(Z(i).freq/9)};
    end
    text=cell2table(text);
    text_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Figures/%s/maps-group-FDR-%s.links.txt',pipeline,variant);
    writetable(text,text_file,'WriteVariableNames',false,'Delimiter',' ')
    clear text
    
end


if strcmp(method,'FDR') && strcmp(analysis,'individual')
    load /m/cs/scratch/networks/trianaa1/Atlas/brainnetome_labels.mat
    for i=2:length(raw)
        raw(i,2)=labels(str2double(raw(i,2)),1);
        raw(i,4)=labels(str2double(raw(i,4)),1);
        %raw{i,8}=strcat(raw{i,2},'-',raw{i,4});
    end
    
    for j=1:length(smoothing)
        Index = find(startsWith(raw(:,1),smoothing{j}));
        data=raw(Index,:);
        size_data=size(data,1);
        for i=1:size_data
            node1_split=strsplit(data{i,2},'_');
            node2_split=strsplit(data{i,4},'_');
            node1_mod=erase(data{i,2},strcat('_',node1_split{1,2}));
            node2_mod=erase(data{i,4},strcat('_',node2_split{1,2}));
            
            if ~isstr(data{i,6})
                weight=abs(data{i,6})/(max(abs(cell2mat(data(:,6)))));
                text(i,:)={lower(node1_split{1,2}),node1_mod,lower(node2_split{1,2}),node2_mod,'0',num2str(weight)};
            else
                weight=abs(str2double(data{i,6}))/(max(abs(str2double(data(:,6)))));
                text(i,:)={lower(node1_split{1,2}),node1_mod,lower(node2_split{1,2}),node2_mod,'0',num2str(weight)};
            end
        end
        text=cell2table(text);
        text_file=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Figures/%s/maps%s-FDR%s.links.txt',pipeline,smoothing{j},variant);
        writetable(text,text_file,'WriteVariableNames',false,'Delimiter',' ')
        clear text
    end
end
%% Trying visualizing matrices :(

% load /m/cs/scratch/networks/trianaa1/Atlas/brainnetome_MPM_rois_2mm_PowerROIs.mat
% map=cbrewer('div','RdGy',4);
% map2=flipud(cbrewer('div','RdGy',12));
% map=[map2(1,:);map2(1,:);map2(1,:);map2(1,:);map2(1,:);map2(1,:);map2(1,:);map2(1,:);map2(1,:);map2(1,:);map2(8:12,:)];
% 
% 
% figure
% for i=1:length(smoothing)
%     Index = find(startsWith(raw(:,1),smoothing{i}));
%     data=raw(Index,:);
%     size_data=size(data,1);
%     
%     sigLink=zeros(246,246);
%     for j=1:size_data
%         node1=str2double(data(j,2));
%         node2=str2double(data(j,4));
%         sigLink(node1,node2)=data{j,6};
%     end
%     subplot(3,3,i)
%     imagesc(sigLink)
%     colormap(map)
%     set(gca,'XTick',[])
%     set(gca,'YTick',[])
%     axis square
% end
% set(gca,'FontName','Arial')
% set(gcf,'Units', 'Normalized', 'OuterPosition', [0 0 1 .75]);
% set(gcf,'Color',[1 1 1])
