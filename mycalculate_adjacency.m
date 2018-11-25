%This script takes the ROI time series, calculates their pair-wise correlations to get the adjacency matrix
clear cfg
clear all
clc

%List the subjects:
%folder='/m/cs/scratch/networks/data/ABIDE_II/Preprocessed/Non_Smoothed-HarvardOxford/NYU_I';
folder='/m/cs/scratch/networks/data/ABIDE_II/Forward';
d= dir(folder);
d = d(3:(end-1));%d(3:(end-4));
%threshold=[10]; %25 50 75];

site_d=dir([folder,'/',d(1).name]);
site_d = site_d(3:end);


for sub=1:length(d)
    for site=1:length(site_d)
        subject_d=dir([folder,'/',d(sub).name,'/',site_d(site).name]);
        subject_d=subject_d(3:end);
        for subject=1:length(subject_d)
            %load the data and extract the roi averages
            load(sprintf('%s/%s/%s/%s/roi_voxel_ts_all_rois.mat',folder,d(sub).name,site_d(site).name,subject_d(subject).name))
            rois = roi_voxel_data.roi_ts;
            
            %Check if there are undefined regions and delete them if there are
            [row ~]=find(rois==0);
            row=unique(row);
            if ~isempty(row)
                disp(sprintf('empty ROIs in %s/%s/%s/%s',folder,d(sub).name,site_d(site).name,subject_d(subject).name))
                rois(row,:)=[];
            end
            
            %load the FD diagnostics matrix
            load(sprintf('%s/%s/%s/%s/bramila/diagnostics.mat',folder,d(sub).name,site_d(site).name,subject_d(subject).name)) 
            clear CSF; clear csfIDs, clear DV; clear GM; clear gmIDs; clear SD; 
            clear WM; clear wmIDs; clear GS; clear gsIDs;

            %Look the band in which the sequence length is greater than 150 
            Idx=find(FD>0.5); %finds which FD is over 0.5

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

            %considers only those intervals larger than 150
            if intervals(chosenInt)>150
                doAdjacency=1;
                %If the interval chosen is the first one, then we need to 
                if chosenInt==1 
                    if intervals(chosenInt)~=size(FD,1)
                        rois=rois(:,1:max(intervals)-1);
                    end
                else
                    t_start=intervals(chosenInt-1)+1;
                    t_end=intervals(chosenInt)+intervals(chosenInt-1)-1;%
                    if FD(end)<0.5 && t_end==204
                        t_end=t_end+1;
                    end
                    %FD=FD(t_start:t_end,1);
                    rois=rois(:,t_start:t_end);  
                end
            else
                doAdjacency=0;
            end

            %Compute the adjacency matrix only for those subjects whose sequence FD>0.5 
            %length is greater than 150. This computation will only be the upper
            %diagonal of the matrix
            if doAdjacency==1
                s=size(rois,1);
                Adj = zeros(s,s);
                for i=1:s
                    for j=(i+1):s
                        Adj(i,j) = corr(rois(i,:)',rois(j,:)','Type','Pearson');
                    end
                end

                %Fill the other half of the adjacency matrix
                C = Adj'+Adj; %+eye(size(A));

                ids = find(triu(ones(size(Adj)),1)); %indices where values are different from 0 in the upper triangle
                %figure; hist(C(ids),100); xlabel('Correlation')
    
                %Check if the negative correlations are more than 25% and issue a warning
                ratio=100*(size(find(Adj<0),1)/(s*s));
                if ratio>25
                    fid = fopen(fullfile(folder, d(sub).name, site_d(site).name, subject_d(subject).name,'Adjacency.txt'), 'a');
                    if fid == -1
                        error('Cannot open log file.');
                    end
                    fprintf(fid, 'Warning! negative correlations are %f percent of the total correlations', ratio);
                    fclose(fid);
                end

                %save the adjacency matrix without thresholding 
                save(sprintf('%s/%s/%s/%s/Adj_%s.mat',folder,d(sub).name,site_d(site).name,subject_d(subject).name,'NoThr'),'Adj')
                sprintf('%s/%s/%s/%s/',folder,d(sub).name,site_d(site).name,subject_d(subject).name)
    
%     %threshold at some percentage of the matrix
%     thr_num=length(threshold);
%     for i=1:thr_num
%         [vals, inds] = sort(A(ids)); %sorts from smallest to biggest
%         N = length(ids);
%         N_lim = round(threshold(i)*N/100); %calculate the number of coeff to hold according to the threshold
%         %vals(N_lim)
%         per = vals(end-N_lim); %looks up the value of the thr% of the largest correlations
%         Adj = double(A>per); %Takes only the values larger than previous lines
%         Adj = Adj.*A; %in case I do not want 1s and 0s, but the whole
%         %correlation numbers
% 
%         save(sprintf('%s/%s/Adjacency_%s.mat',folder,d(sub).name,num2str(threshold(i))),'Adj')
%         save(sprintf('%s/%s/Correlation.mat',folder,d(sub).name),'C')
%     end
                clear roi_voxel_data
                clear FD
                clear rois
            end
        end
    end
end
           