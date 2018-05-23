%%
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_importcsv/');
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
outpath=[mappath 'TempEQListFiles/'];

load([mappath 'ShakeMap_Info.mat']);
load([mappath 'TempEQListFiles/Match2.mat']);
list=csv2mat_mixed([mappath 'TempEQListFiles/ShakeMap_AND_EARTHQUAKE_List_MATCH.csv'],7882,2,[]);
%%
smind=[smind;list.smind];
eqid=[sm_to_eq;list.eqid];
smind(eqid==0)=[];
eqid(eqid==0)=[];
%%
EQ_list=zeros(n,1);
kick_them=ones(n,1);

kick_them(smind)=0;
EQ_list(smind)=eqid;

save([outpath 'Match_ShakeMap_USGS_EQ_list.mat'],'EQ_list','kick_them','-v7.3');
display('DONE with Step3b!!!')
