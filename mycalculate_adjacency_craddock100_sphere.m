%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This script takes the ROI time series, calculates their pair-wise        %
% correlations to get the adjacency matrix                                %
%                                                                         %
% 27.06.2018 Created by Ana T.                                            %
% 27.09.2019 Modified by AT. Make it more efficient, include thresholds   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear cfg
clear all
clc

%Set the variable names
name='Adj_NoThr_sphere_Craddock10007.mat';
name2='Correlation_sphere_Craddock10007.mat';
%name3='sphere_Craddock100.mat';
parcel='sphere_craddock10007_ts_all_rois.mat';
%threshold=[5 7 9 10 11 13 15 17 19 20];

%List the subjects
d=dir('/m/cs/scratch/networks/data/UCLA_openneuro/*/');
d(ismember({d.folder}, {'/scratch/cs/networks/data/UCLA_openneuro/Preprocessed','masks'})) = [];
d(ismember({d.name}, {'.', '..','FD05','FD07','FD08'})) = [];
fid = fopen('/m/cs/scratch/networks/data/UCLA_openneuro/subjects_FD07.txt','r');
Data=textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '');
subject_list  = Data{1};
fclose(fid);

d(~ismember({d.name}, subject_list))=[];
for i=1:(length(d))
    if ~isfile(sprintf('%s/%s/%s',d(i).folder,d(i).name,name))
        subjects{i} = sprintf('%s/%s/%s',d(i).folder,d(i).name,parcel);
    end
end


ids=find(~cellfun(@isempty,subjects));
subjects=subjects(ids);

for i=1:length(subjects)
    %load the data and extract the roi averages
    load(subjects{i})
    rois = roi_voxel_data.roi_ts;
    
    %Check if there are undefined regions and delete them if there are
    [row ~]=find(rois==0);
    row=unique(row);
    if ~isempty(row)
        disp(sprintf('empty ROIs in %s',subjects{i}))
        rois(row,:)=[];
    end
    
    %load the FD diagnostics matrix
    [filepath,~,~]=fileparts(subjects{i});
    [dummy,subject_id,~]=fileparts(filepath);
    [root,site,~]=fileparts(dummy);
    %[root,smooth,~]=fileparts(dummy);
    load(sprintf('%s/Brainnetome_0mm/%s/bramila/diagnostics.mat',root,subject_id)) %changeme
    clear CSF; clear csfIDs, clear DV; clear GM; clear gmIDs; clear SD; 
    clear WM; clear wmIDs; clear GS; clear gsIDs;
    
    %Look the band in which the sequence length is greater than 4.5 min 
    Idx=find(FD>0.7); %finds which FD is over 0.5
    
    %If there are points in which FD>0.5, the sequence is splitted because we
    %cannot use these points. Then, we need to calculate what is the length of
    %such splitted sequences (intervals). This piece of code calculates the
    %length of the intervals.
    if isempty(Idx)
        Idx=size(FD,1);
    end
    
    len=size(Idx,1);
    intervals=Idx(1,1);
    for j=2:len
        intervals(j,1)=Idx(j,1)-Idx(j-1,1);
    end

    if ~isempty(j)
        intervals(j+1,1)=size(FD,1)-Idx(end,1);
    else
        intervals(2,1)=size(FD,1)-Idx(1,1);
    end

    chosenInt=find(intervals==max(intervals));

    %considers only those intervals larger than 135 (4.5 minutes)
    if intervals(chosenInt)>135
        doAdjacency=1;
        %If the interval chosen is the first one, then we need to 
        if chosenInt==1 
            if intervals(chosenInt)~=size(FD,1)
                rois=rois(:,1:max(intervals)-1);
            end
        else
            t_start=intervals(chosenInt-1)+1;
            t_end=intervals(chosenInt)+intervals(chosenInt-1)-1;%
            if FD(end)<0.7 && t_end==size(FD,1)-1 %204 comes from TCD_II size of FD
                t_end=t_end+1;
            end
            %FD=FD(t_start:t_end,1);
            rois=rois(:,t_start:t_end);  
        end
    else
        doAdjacency=0;
    end
    
    
    %Compute the adjacency matrix only for those subjects whose sequence FD>0.5 
    %length is greater than 135. This computation will only be the upper
    %diagonal of the matrix
    if doAdjacency==1
        s=size(rois,1);
        Adj = zeros(s,s);
        for k=1:s
            for j=(k+1):s
                Adj(k,j) = corr(rois(k,:)',rois(j,:)','Type','Pearson');
            end
        end
        
        %Fill the other half of the adjacency matrix
        C = Adj'+Adj; %+eye(size(A));

        ids = find(triu(ones(size(Adj)),1)); %indices where values are different from 0 in the upper triangle
        %figure; hist(C(ids),100); xlabel('Correlation')
        
        %Check if the negative correlations are more than 25% and issue a warning
        ratio=100*(size(find(Adj<0),1)/(s*s));
        if ratio>25
            fid = fopen(fullfile(filepath,'Adjacency.txt'), 'a');
            if fid == -1
                error('Cannot open log file.');
            end
            fprintf(fid, 'Warning! negative correlations are %f percent of the total correlations', ratio);
            fclose(fid);
        end
        
        %save the adjacency matrix without thresholding 
        save(sprintf('%s/%s',filepath,name),'Adj')
        save(sprintf('%s/%s',filepath,name2),'C')
        sprintf('%s: %s/%s',num2str(i),filepath,name)
        
        
        %threshold at some percentage of the matrix
%         thr_num=length(threshold);
%         for j=1:thr_num
%             C = abs(C);
%             [vals, inds] = sort(C(ids)); %sorts from smallest to biggest
%             N = length(ids);
%             N_lim = round(threshold(j)*N/100); %calculate the number of coeff to hold according to the threshold
%             %vals(N_lim)
%             per = vals(end-N_lim); %looks up the value of the thr% of the largest correlations
%             Adj = double(C>per); %Takes only the values larger than previous lines
%             Adj = Adj.*C; %in case I do not want 1s and 0s, but the whole
%             %correlation numbers
%             %Adj = Adj(ids);
% 
%             save(sprintf('%s/Adj_%s_%s',filepath,num2str(threshold(j)),name3),'Adj')
%         end
    end
    clear roi_voxel_data
    clear FD
    clear rois
end
           