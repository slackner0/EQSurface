addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_scatterheat')

mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
outpath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Output/Figures/';
areapath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Raw/gpw-v4-land-water-area-land/';

%% load
load([mappath 'ShakeMapLand_VarShake_PGA.mat']);
load([mappath 'kick_them.mat']);
load([mappath 'ShakeMap_Info.mat']);
[area, R] = geotiffread([areapath 'gpw-v4-land-water-area_land.tif']);

%% clean
area=(area>0);
sample=(kick_them==0).*((YMDHMS(:,1)==2016).*(YMDHMS(:,2)>=11)==0);
A_P_PGALand(sample==0,:)=[];
A_thr_PGALand(sample==0,:)=[];
ECX=EC_PGALand.XLON;
ECY=EC_PGALand.YLAT;
ECX(sample==0,:)=[];
ECY(sample==0,:)=[];
Peak_PGALand(sample==0,:)=[];
magnitude(sample==0,:)=[];
YMDHMS(sample==0,:)=[];


%% Scatterheat

%%%%%%%%%%%%%%%%%%%
sample=(Peak_PGALand>=10).*(magnitude>=4.5);

A_thr_PGALand(sample==0,:)=[];
magnitude(sample==0)=[];
A_P_PGALand(sample==0,:)=[];
Peak_PGALand(sample==0)=[];
sample_n=sum(sample==1);


figure
%magnitude vs. Area
subplot(2,2,2)
scatterheat(magnitude,log10(A_P_PGALand(:,1)),'xpos', 6.05, 'xgrid',0.1)
ylabel('Log_{10} of area (km^2) with 90% of max PGA');
xlabel('Magnitude');
title('(b)')
c=colorbar;
set(c,'YTick', sample_n*[0 0.002 0.004 0.006 0.008 0.01]);
set(c,'YTicklabel',{'0' '2e-3' '4e-3' '6e-3' '8e-3' '1e-2'} );
c.Label.String = 'Density';

subplot(2,2,4)
scatterheat(magnitude,log10(A_thr_PGALand(:,4)),'xpos', 6.05, 'xgrid',0.1)
ylabel('Log_{10} of area (km^2) with at least 10%g PGA');
xlabel('Magnitude');
title('(d)')
c=colorbar;
set(c,'YTick', sample_n*[0 0.002 0.004 0.006 0.008]);
set(c,'YTicklabel',{'0' '2e-3' '4e-3' '6e-3' '8e-3'} );
c.Label.String = 'Density';

%max PGA vs. Area
subplot(2,2,1)
scatterheat(log10(Peak_PGALand),log10(A_P_PGALand(:,1)))
ylabel('Log_{10} of area (km^2) with 90% of max PGA');
xlabel('Log_{10} of maximum PGA (%g)');
title('(a)')
c=colorbar;
set(c,'YTick', sample_n*[0 0.001 0.002 0.003]);
set(c,'YTicklabel',{'0' '1e-3' '2e-3' '3e-3'} );
c.Label.String = 'Density';

subplot(2,2,3)
scatterheat(log10(Peak_PGALand),log10(A_thr_PGALand(:,4)))
ylabel('Log_{10} of area (km^2) with at least 10%g PGA');
xlabel('Log_{10} of maximum PGA (%g)');
title('(c)')
c=colorbar;
set(c,'YTick', sample_n*[0 0.001 0.002 0.003 0.004 0.005]);
set(c,'YTicklabel',{'0' '1e-3' '2e-3' '3e-3' '4e-3' '5e-3'} );
c.Label.String = 'Density';

set(gcf, 'Position', [100 100 1200 580])
set(gcf,'paperunits','points');
sizeim=get(gcf,'paperposition');
sizeim=sizeim(3:4);
set(gcf, 'PaperSize', [sizeim(1)-180 sizeim(2)-50], 'paperposition', [-100 -25 sizeim]);
print(gcf,[outpath 'Figure06'], '-dpdf')

display('DONE with Areacomparison!!!')
