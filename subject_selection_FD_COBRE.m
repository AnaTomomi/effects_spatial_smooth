clear cfg
clear all
clc

%List the subjects:
%folder='/m/cs/scratch/networks/data/ABIDE_II/Preprocessed/Non_Smoothed-HarvardOxford/NYU_I';
folder='/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/';
d= dir(folder);
d = d(3:end);

for subject=1:length(d)
load(sprintf('%s%s/bramila/diagnostics.mat',folder,d(subject).name)) %changeme
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
if intervals(chosenInt)>120 %sequences larger than 4.5 minutes
    doAdjacency=1;
end
fprintf('%s: %f \n',d(subject).name,doAdjacency)
end