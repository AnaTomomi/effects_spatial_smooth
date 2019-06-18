clear all 
close all
clc

%add required paths
addpath(genpath('/m/cs/scratch/networks/trianaa1/toolboxes/NBS1.2'));

%% configure paths
%Human inputs
smoothing='0';%0,4,6,8,10,12,14,16,18

pipeline='Forward'; %'Forward' or 'Inverse'
test='F-test';
N = 246; %number of ROIs
thres='16'; %Do NOT change!!!!

%Configure the folders and files
folder1=sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/group1/%s/Brainnetome_%smm',pipeline,smoothing);
folder2=sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/group2/%s/Brainnetome_%smm',pipeline,smoothing);
savepath= sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS/%s/NBS_Brainnetome_%smm_%s_Fisher_2019',pipeline,smoothing,test);
figure_path=sprintf('/m/cs/scratch/networks/trianaa1/Paper1/Figures/%s/NBS_Brainnetome_%smm_%s_Fisher',pipeline,smoothing,test);
data_path=sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS/%s/subjects.mat',pipeline);
design_path=sprintf('/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS/%s/design.mat',pipeline);
excel_file='/m/cs/scratch/networks/trianaa1/Paper1/Significant_Nets_Fisher_2019.xlsx';

%Configure the Atlas
labels='/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS/Forward/labels.txt';
centroids=[];
%centroids='/m/cs/scratch/networks/data/ABIDE_II/Analysis/NBS/Forward/brainnetome.txt';
%% Read the matrices and organize the data
%Make a list of subjects
group1= dir(folder1);
group1= group1(3:end); group1= group1(2:5:end); %OJO! Needs change
group2= dir(folder2);
group2= group2(3:end); group2= group2(2:5:end);
subjectNum_per_group=length(group1);

%Design vector groups that contains indices 1 and 2 for the different groups
d = [group1; group2]; %list of subjects in the group
ids = find(triu(ones(N,N),1));
middle=length(d)/2;

%Organize the data according to NBS guidelines
for i=1:middle
    load(sprintf('%s/%s',folder1,d(i).name)) %load each adjacency matrix 
    Adj=Adj+Adj';
    %Adj=Adj+diag(ones(1,N));
    data(:,:,i)=Adj;
end
 
for i=middle+1:length(d)
    load(sprintf('%s/%s',folder2,d(i).name)) %load each adjacency matrix 
    Adj=Adj+Adj';
    %Adj=Adj+diag(ones(1,N)); %This line is commented out because inverse
    %z-score is performed later. If left, 1 would not be 1 anymore
    data(:,:,i)=Adj;
end

%From z-scores to correlations again
subNum=subjectNum_per_group*2;
for i=1:subNum
    data(:,:,i)=tanh(data(:,:,i));
    data(:,:,i)=data(:,:,i)+diag(ones(1,N));
end

save(data_path,'data')
data= data_path;

%design_g1=csvread('/m/cs/scratch/networks/data/ABIDE_II/Analysis/group1/regress.csv',0,1);
%design_g2=csvread('/m/cs/scratch/networks/data/ABIDE_II/Analysis/group2/regress.csv',0,1);
%design_g=vertcat(design_g1,design_g2);
%design1=zeros(66,1); design1(1:2:(2*subjectNum_per_group),1)=1;
%design_mat=[design_g design1];
design1=zeros(66,1); design1(1:subjectNum_per_group,1)=ones(subjectNum_per_group,1);
design2=zeros(66,1); design2(subjectNum_per_group+1:end,1)=ones(subjectNum_per_group,1);
design_mat=[design1 design2];
%design_mat=zeros(66,1); design_mat(1:33,1)=ones(33,1);
save(design_path,'design_mat')
design_mat=design_path;

%% Config the structure for the NBS 

UI.method.ui='Run NBS'; %'Run NBS' | 'Run FDR'
UI.test.ui=test; %'One Sample' | 't-test' | 'F-test'
UI.size.ui='Extent'; %'Extent' | 'Intensity'
UI.thresh.ui=thres; %T-threshold
UI.perms.ui='10000'; %number of permutations
UI.alpha.ui='0.05'; %level of significance
UI.contrast.ui='[1 1]';%'[0 0 0 0 0 1]'; %which group is assumed to be bigger?
UI.design.ui=design_mat; %N x P design matrix
UI.exchange.ui=''; % optional: if exchange matrix is needed
UI.matrices.ui=data; %matrix with all the subjects
UI.node_coor.ui=''; %coordinates in MNI space                         
UI.node_label.ui=labels; %labels of Brainnetome

%To see why F-test, please see https://www.nitrc.org/forum/forum.php?thread_id=9008&forum_id=3444
%% Run the NBS Toolbox

run NBSrun(UI,[])
global nbs

save(savepath,'nbs')
%saveas(gcf,figure_path,'jpg');
%close all

[~,~,raw] = xlsread(excel_file);
init_row=size(raw,1)+1;
if ~isempty(nbs.NBS.con_mat)
    [i,j]=find(nbs.NBS.con_mat{1});
    for n=1:length(i)
        i_lab=nbs.NBS.node_label{i(n)};
        j_lab=nbs.NBS.node_label{j(n)};
        stat=nbs.NBS.test_stat(i(n),j(n));
        fprintf('%s to %s. Test stat: %0.2f\n',num2str(i(n)),num2str(j(n)),stat);
        cohen=sqrt(stat)*sqrt((subjectNum_per_group+subjectNum_per_group)/(subjectNum_per_group*subjectNum_per_group));
        hedge=(1-(3/((4*(subjectNum_per_group+subjectNum_per_group-2))-1)))*cohen;
        raw(init_row,:)={pipeline,smoothing,num2str(i(n)),i_lab,num2str(j(n)),j_lab,num2str(stat),cohen,hedge};
        init_row=init_row+1;
    end
    raw=cell2table(raw);
    %writetable(raw,excel_file,'WriteVariableNames',false)
else
    raw(init_row,:)={pipeline,smoothing,'NaN','NaN','NaN','NaN','NaN','NaN','NaN'};
end