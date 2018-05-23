%Stephanie Lackner, January 18, 2017 (updated: 5/16/18)
%% Input Section
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_scale')
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_shakemaptools')
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
borderpath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Raw/gpw-v4-land-water-area-land/';
outpath=mappath;

%% Import Data
[area_grid, R] = geotiffread([borderpath 'gpw-v4-land-water-area_land.tif']);
load([mappath 'ShakeMap_Grid_PGALand.mat']);
load([mappath 'ShakeMap_Info.mat']);
load([mappath 'kick_them.mat']);

%% Clean
ulxmap(ulxmap<-180)=ulxmap(ulxmap<-180)+360;
years=YMDHMS(:,1);
area_grid=(area_grid>0);

%% Now overlap with shaking
reso=120;
box=[-180 -60 ; 180  85];
%     box = [x1 y1;         map:  y2 ----
%            x2 y2]                 |    |
%                                   |    |
%                              x1,y1 ---- x2
clear R region status version type network code_version depth id lat lon YMDHMS timestamp nrows ncols time xdim* ydim


breakswitch=0;
EQHistory=zeros(size(area_grid));
EQMax=zeros(size(area_grid));
EQNum=zeros(size(area_grid));


for y=1973:2015
    subset=(years==y).*(kick_them==0);
    [ mpga, number_quakes, sum_lpga, sum_pga, sum_pga_square, mag_map, list] = shakelap(area_grid,box,reso,subset,breakswitch,PGALand,1./res_event,ulxmap,ulymap,res_event,magnitude);
    clear mag_map sum_lpga sum_pga sum_pga_square
    mpga(mpga<0)=0;
    EQHistory=EQHistory+mpga;
    EQMax=max(EQMax,mpga);
    EQNum=EQNum+number_quakes;
    clear mpga number_quakes
end

%save output
save([outpath 'ALLHistory.mat'],'EQ*', '-v7.3');

%%
display('Done with Step4c!!!');
