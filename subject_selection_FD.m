clear cfg
clear all
clc

%List the subjects:
%folder='/m/cs/scratch/networks/data/ABIDE_II/Preprocessed/Non_Smoothed-HarvardOxford/NYU_I';
folder='/m/cs/scratch/networks/data/ABIDE_II/Forward';
d= dir(folder);
d = d(3:(end-1));

site_d=dir([folder,'/',d(1).name]);
site_d = site_d(3:end);

sub=1;
%for sub=1:length(d)
    site=1;
    %for site=1:length(site_d)
        subject_d=dir([folder,'/',d(sub).name,'/',site_d(site).name]);
        subject_d=subject_d(3:end);
        for subject=1:length(subject_d)
        load(sprintf('%s/%s/%s/%s/bramila/diagnostics.mat',folder,d(1).name,site_d(site).name,subject_d(subject).name)) %changeme
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
        doAdjacency = 0;
        if intervals(chosenInt)>150
            doAdjacency=1;
        end
sprintf('%s: %f',subject_d(subject).name,doAdjacency)