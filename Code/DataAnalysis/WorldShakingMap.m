%Stephanie Lackner,(updated: 5/14/18)
%runs for 12minutes
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_from_Sources/cbrewer')
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_scale')
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_logcolor/')

load('/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Raw/GSHAP/GSHPUB.DAT')
load('/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/ALLHistory.mat')
borderpath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Raw/gpw-v4-land-water-area-land/';
[area, R] = geotiffread([borderpath 'gpw-v4-land-water-area_land.tif']);
outpath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Output/Figures/';

area=(area>0);

%Some notes
%EQHistory and EQMax have 0 where noting is happening
%EQNum has zero where nothing is happening on land, and -43 in water

%% Create matrix for GSHPUB data restricted to same global window as area data

%I made the decision that lat/lon describe center
%Drop most right column (repetition of coordinates)
GSHPUB(GSHPUB(:,1)==193,:)=[];

%restrict matrix to area north south boundaries
GSHPUB(GSHPUB(:,2)<-60,:)=[];
GSHPUB(GSHPUB(:,2)>85,:)=[];

%Adjust longitude to convention of -180 to +180
adjust = GSHPUB(:,1)>=180;
GSHPUB(adjust,1)=GSHPUB(adjust,1)-360;

%Replace NaN with zero
GSHPUB(isnan(GSHPUB(:,3)),3)=0;

% 1451 x 3600
GSHMAP=zeros((85+60)*10+1,360*10);

%make matrix of GSHPUB
for  i=1:length(GSHPUB(:,2))
    GSHMAP(round(1451-(GSHPUB(i,2)+60)*10),round((GSHPUB(i,1)+180)*10)+1)=GSHPUB(i,3);
end

%increase size of matrix
GSHMAP=upscale(GSHMAP,2,2,0);

%since lat/lon refers to center, first column needs to go to end of matrix
GSHMAP=[GSHMAP(:,2:end),GSHMAP(:,1)];
%since lat/lon refers to center, most north and south rows need to be
%dropped to keep matrix in boundaries
GSHMAP=GSHMAP(2:end-1,:);

%Now matrix has right window

%increase size of matrix to fit resolution of areadata
GSHMAP=upscale(GSHMAP,6,6,0);

%% Print GSHPUB
map=GSHMAP.*area;
map(area==0)=-0.1;

figure
imagesc(map)
colormap([0.8,0.8,0.8;1,1,1; cbrewer('seq', 'Reds', 150)])
axis off
title('(b) Global Seismic Hazard Map (Data: GSHAP)')
c=colorbar;
c.Label.String = 'PGA with 10% chance of being exceeded in next 50 years';
fig_map=gcf;
truesize(fig_map, size(map)/75)


set(gcf,'paperunits','points');
sizeim=get(gcf,'paperposition');
sizeim=sizeim(3:4);
set(gcf, 'PaperSize', [sizeim(1)-90 sizeim(2)-20], 'paperposition', [-75 -20 sizeim]);
print(gcf,[outpath 'GSHAP'], '-dpdf')
close(gcf)

%% Create shaking history for comparison matrix
EQHistory_scaled=resizem_by_max(EQMax,1/6);

temp=resizem_by_max(EQHistory_scaled(:,2:end-1),1/2);
temp=upscale(temp,2,2,0);

EQHistory_scaled=[EQHistory_scaled(:,1),temp,EQHistory_scaled(:,end)];

%Just to compare aggregation levels visualy:
%imagesc(EQMax)
%colormap([0.8,0.8,0.8;1,1,1; cbrewer('seq', 'Reds', 150)])
%figure
%imagesc(EQHistory_scaled)
%colormap([0.8,0.8,0.8;1,1,1; cbrewer('seq', 'Reds', 150)])

EQHistory_scaled=upscale(EQHistory_scaled,6,6,0);

clear temp GSHPUB
%% create Earthquake maximum shaking history
map0=EQHistory_scaled.*area+area;

map=log10(map0);
map(map0==0)=-0.01;

figure
imagesc(map)
colormap([1,1,1;0.8,0.8,0.8;  parula(420)])
axis off
title('(a) Earthquake Maximum Shaking History')
L = [ 0 1 5 10 25 50 100 200 ];
l = log10(L+1);
hC=colorbar;
set(hC,'Ytick',l,'YTicklabel',L);
xlabel(hC, 'Maximum PGA in %g (log-colorscale)')
fig_map=gcf;
truesize(fig_map, size(map)/75)

set(gcf,'paperunits','points');
sizeim=get(gcf,'paperposition');
sizeim=sizeim(3:4);
set(gcf, 'PaperSize', [sizeim(1)-90 sizeim(2)-20], 'paperposition', [-75 -20 sizeim]);
print(gcf,[outpath 'EQMax'], '-dpdf')
close(gcf)


%% compare GSHPUB with EQHistory
Diff=EQHistory_scaled-GSHMAP;
%RelDiff=Diff./GSHMAP;
granular=5;
Diff(area==0)=(-10-1/granular);
Diff(Diff>10)=10;
figure
imagesc(Diff)

colormap([0.8,0.8,0.8; flipud(cbrewer('div', 'PuOr', 20*granular))])
axis off
title('(c) Difference between Earthquake Max Shaking History and GSHAP Hazard Map')
labels={'','-10','-5','0','5','10+'};
c=colorbar('YTickLabel', labels, 'YTick',[(-10-1/granular) -10 -5 0 5 10]);
c.Label.String = 'Difference in PGA';
fig_map=gcf;
truesize(fig_map, size(Diff)/75)

set(gcf,'paperunits','points');
sizeim=get(gcf,'paperposition');
sizeim=sizeim(3:4);
set(gcf, 'PaperSize', [sizeim(1)-90 sizeim(2)-20], 'paperposition', [-75 -20 sizeim]);
print(gcf,[outpath 'History_GSHAP'], '-dpdf')
close(gcf)
%RelDiff(area==0)=-1.5;
%figure
%imagesc(RelDiff);
%axis off
%colormap([0.8,0.8,0.8;0.8,0.8,0.8;0.8,0.8,0.8; flipud(cbrewer('div', 'PuOr', 11))])
%c=colorbar;
%c.Label.String = 'Relative difference in PGA occurance and GSHAP';

%%
map0=EQHistory./43+area;

map=log10(map0);
map(map0==0)=-0.01;

figure
imagesc(map)
colormap([1,1,1;0.8,0.8,0.8;  parula(233)])
axis off
title('(a) Earthquake Shaking History')
L = [ 0 1 2 3 4 5 10 13];
l = log10(L+1);
hC=colorbar;
set(hC,'Ytick',l,'YTicklabel',L);
xlabel(hC, 'Average annual maximum PGA in %g (log-colorscale)')
fig_map=gcf;
truesize(fig_map, size(map)/75)

set(gcf,'paperunits','points');
sizeim=get(gcf,'paperposition');
sizeim=sizeim(3:4);
set(gcf, 'PaperSize', [sizeim(1)-90 sizeim(2)-20], 'paperposition', [-75 -20 sizeim]);
print(gcf,[outpath 'EQHistory'], '-dpdf')
close(gcf)

%%
map0=EQNum./43;
map0(map0<0)=-0.01;
map=map0;

figure
imagesc(map)
colormap([1,1,1;0.8,0.8,0.8;  parula(223)])
axis off
title('(b) Number of Earthquakes History')
%hC=logcolorbar
hC = colorbar;
%L = [ 0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1 1.1 ];
%l = log10(L+1);
%set(hC,'Ytick',l,'YTicklabel',L);
xlabel(hC, 'Average annual number of events with PGA \geq 10%g')
fig_map=gcf;
truesize(fig_map, size(map)/75)

set(gcf,'paperunits','points');
sizeim=get(gcf,'paperposition');
sizeim=sizeim(3:4);
set(gcf, 'PaperSize', [sizeim(1)-90 sizeim(2)-20], 'paperposition', [-75 -20 sizeim]);
print(gcf,[outpath 'EQNum'], '-dpdf')
close(gcf)

display('Done with WorldShakingMap!!!')
