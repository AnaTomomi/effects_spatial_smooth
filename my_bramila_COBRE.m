%% Example of pipeline with default parameters
%   - Notes:
%   Refer to wiki page:
%   https://wiki.aalto.fi/pages/viewpage.action?pageId=92445275 for
%   detailed documentation
%	Last edit: EG 2014-07-14


%%
% Copy this to your folder, specify subject folders with correct file names
%
% Subject folders should contain:
% -epi.nii (functional data)
% -bet.nii (brain-extracted anatomical image)
% -if drifter was used, also .acq file with respiration and heartbeat.
%%

clear cfg; % Running also "clearn all" is good practice to start from an empty and clean workspace

addpath(genpath('/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila'));
addpath('/m/nbe/scratch/braindata/shared/toolboxes/NIFTI');


%% List subject input folders
subjects = {
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040028'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040069'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040079'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040041'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040065'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040130'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040093'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040116'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040126'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040084'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040109'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040078'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040138'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040086'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040097'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040122'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040123'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040038'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040082'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040046'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040140'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040014'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040111'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040147'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040085'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040081'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040051'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040029'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040018'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040100'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040098'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040044'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040143'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040112'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040040'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040128'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040034'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040004'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040027'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040110'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040129'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040076'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040067'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040115'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040087'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040137'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040010'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040001'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040055'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040021'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040083'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040017'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040139'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040012'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040142'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040016'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040102'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040108'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040057'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040107'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040062'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040015'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040088'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040011'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040048'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040042'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040106'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040049'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040092'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040089'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040008'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040009'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040134'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040133'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040061'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040071'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040117'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040104'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040120'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040035'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040119'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040114'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040131'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040146'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040036'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040068'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040037'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040091'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040070'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040080'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040064'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040105'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040007'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040054'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040095'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040074'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040031'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040136'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040099'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040060'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040124'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040013'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040113'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040059'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040125'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040090'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040127'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040075'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040135'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040073'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040020'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040006'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040063'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040058'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040121'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040005'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040025'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040101'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040145'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040019'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040066'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040072'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040002'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040132'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040118'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040050'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040096'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040030'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040022'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040024'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040033'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040144'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040023'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040077'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040094'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040000'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040052'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040043'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040045'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040103'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040047'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040039'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040056'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040026'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040141'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040053'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040003'
'/m/cs/scratch/networks/data/COBRE/Input_4_bramila/0040032'
};

%% List subjects output folders
subjects_out = {
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040028'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040069'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040079'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040041'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040065'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040130'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040093'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040116'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040126'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040084'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040109'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040078'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040138'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040086'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040097'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040122'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040123'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040038'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040082'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040046'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040140'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040014'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040111'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040147'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040085'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040081'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040051'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040029'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040018'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040100'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040098'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040044'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040143'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040112'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040040'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040128'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040034'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040004'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040027'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040110'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040129'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040076'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040067'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040115'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040087'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040137'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040010'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040001'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040055'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040021'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040083'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040017'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040139'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040012'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040142'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040016'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040102'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040108'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040057'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040107'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040062'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040015'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040088'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040011'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040048'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040042'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040106'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040049'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040092'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040089'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040008'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040009'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040134'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040133'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040061'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040071'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040117'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040104'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040120'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040035'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040119'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040114'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040131'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040146'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040036'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040068'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040037'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040091'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040070'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040080'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040064'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040105'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040007'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040054'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040095'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040074'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040031'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040136'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040099'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040060'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040124'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040013'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040113'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040059'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040125'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040090'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040127'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040075'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040135'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040073'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040020'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040006'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040063'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040058'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040121'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040005'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040025'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040101'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040145'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040019'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040066'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040072'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040002'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040132'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040118'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040050'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040096'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040030'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040022'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040024'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040033'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040144'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040023'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040077'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040094'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040000'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040052'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040043'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040045'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040103'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040047'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040039'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040056'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040026'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040141'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040053'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040003'
'/m/cs/scratch/networks/data/COBRE/Preprocessed/0mm/0040032'
};
% subjects_out = subjects; % in case you want to store everything under the same original folder


%% General settings
cfg.overwrite = 1; % set to one if you are re-running preprocessing and you want to overwrite existing files
%cfg.bramilapath = '/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila'; % bramila toolbox path
cfg.bramilapath = '/m/nbe/scratch/braindata/shared/toolboxes/bramila/bramila'; % bramila toolbox path
cfg.StdTemplate='/m/nbe/scratch/braindata/shared/HarvardOxford/MNI152_T1_2mm_brain.nii'; % 2mm MNI template from FSL
cfg.TR = 2; % TR from scanning protocol, used in bramila
cfg.rmvframes = 5; % How many volumes to remove in the beginning (sync trial)

%% temporal filtering
cfg.do_temporal_filtering = 1;
cfg.filtertype = 'butter'; % allowed are butter, fir, fslhp. Use fslhp if you are not doing functional connectivity. Use butter to do like in Power 2014

%% Smoothing
cfg.do_spatial_smooth = 0;
cfg.smooth_FWHM = 0; % used in susan smoothing
cfg.smooth_method = 'FSLgauss'; % 'SPM', 'AFNI', 'FSL' or 'none'

%% slice number parameters, use only one, either slicenum or sliceseq
%cfg.slicenum = 33; % slice count: used in slicetimer, in Siemens scanner odd number of slices starts from 1, even starts from 2
cfg.sliceseq = [1:2:33 2:2:33]; % prespecified slice acquisition sequence

%% Drifter settings
cfg.drifter = 0; % 1 if you have biopac measurements
cfg.driftermode = 0; % 0 = BOLD estimate only, 1 = BOLD+residual added back

%% Biopac settings, these are setup according to the template that Dima and Heini use
% Which channels were active 1 - active, 0 - not active
biopacfile.CH1=1; %usually breath data from belt
biopacfile.CH2=0; %usually ECG
biopacfile.CH3=0; %usually GSR
biopacfile.CH4=1; %usually heart rate from pulse oxymeter_left
biopacfile.CH5=0; %usually heart rate from pulse oxymeter_right
biopacfile.CH35=1; %usually MRI scan off/on information
% sampling interval of physiodata and fMRI
biopacfile.dt=0.001; % in seconds/sample
biopacfile.controlplot=1 ;% plots all data and save as filename.fig
biopacfile.breath=0.01;%new sampling interval for breath it should not be higher than 2.4( for 25 inhales/min)
biopacfile.HR=0.01; %new sampling interval for heart rate, should not be higher than 0.75(for 80 bpm)
% set the range for frequencies in signals in bpm (try to keep those as narrow as posible)
biopacfile.freqBreath=10:25; % in breaths per min
biopacfile.freqHR=40:90; % in beats per minutes
biopacfile.filter=1; % bandpass filter for reference data 1 - active, 0 - not active
cfg.biopacfile = biopacfile;

%% Bramila parameters for optimized cleaning of artefacts
% OPTIONAL parameters (otherwise use defaults as marked here in the example)
% Modify only if needed (see "bramila_checkparameters.m" for defaults)
% cfg.motion_reg_type = 'friston'; % motion regression type
% cfg.voxelsize=[2,2,2];        % voxelsize
% cfg.mask = [];                % initial EPI mask
% cfg.tissue_derivatives = 0;   % tissue regressor derivative order
% cfg.min_tissue_var_expl = 75; % minimum variance percentage for tissue PCA regressors
% cfg.max_tissue_pca_count = 7; % upper limit for tissue PCA regressors
 cfg.remove_global = 1;        % remove global signal
% cfg.mot_derivatives = 1;  % motion regressor derivatives
% cfg.white_mask_th = 0.90; % probability threshold for white matter tissue
% cfg.csf_mask_th = 0.90;   % probability threshold for ventricle tissue
 cfg.detrend_type='Savitzky-Golay';   % detrending type
 cfg.filter_type = 'butter';   % temporal filter type
% cfg.filter_limits = [0,0.01,0.08,0.09];   % filter limits in Hz
cfg.write = 0;    % write all intermediate EPI's
% cfg.save_path = '/m/nbe/scratch/braindata/kauttoj2/code/bramila_git/bramila/out'; % custom save path for bramila motion cleaning results


%% Running preprocessing. Do not modify the code below
cfg = bramila_parhandle(cfg,subjects,subjects_out); % reslices the cfg so that it can be used in parfor loop
if ~strcmp(cfg{1}.gridtype,'slurm')
    parfor i = 1:length(subjects)
        bramila_preprocessor(cfg{i});
    end
else
    for i = 1:length(subjects)
        bramila_slurmprepro(cfg{i});
    end
end
