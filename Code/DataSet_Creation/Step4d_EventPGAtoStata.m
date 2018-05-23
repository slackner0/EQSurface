%% Shakemaps: Create Stata Data Set from Matlab Data Set
%Stephanie Lackner, November 23, 2014 (updtaed 5/14/18)
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_from_Sources/stata_translation')

%% Input Section
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
Bands={'PGA'};
outpath=mappath;

%% Import Files
load([mappath 'ShakeMap_Grid_PGALand.mat']);
load([mappath 'ShakeMap_Info.mat']);
load([mappath 'kick_them.mat']);

%% Cleaning: Make sure no commas are in the data (CSV!!!)
region=strrep(region, ',', ' ');
id=strrep(id, ',', ' ');
type=strrep(type, ',', ' ');
network=strrep(network, ',', ' ');
status=strrep(status, ',', ' ');

%% ShakeMap Info
%create var names
C1A={'id','code_version','region'};
C1B={'magnitude','depth','year','month','day','hour','minute','second','kick_them'};
%var content
C2A=cell(n,3);
C2A(:,1)=id;
C2A(:,2)=code_version;
C2A(:,3)=region;
C2B_num=[ magnitude, depth, YMDHMS, kick_them];
C2B_cell=num2cell(C2B_num);
% Convert NaN to . (Stata NaNs)
C2B_cell(isnan(C2B_num))={'.'};
%combine
Output_Table=[C1A C1B; C2A C2B_cell];
%export
cell2csv(Output_Table, [outpath 'ShakeMapInfo']);

clear code_version region magnitude depth YMDHMS lat lon ncols network nrows res_event status time timestamp type ulxmap ulymap version xdim*

for band_type=1:length(Bands)
    Band=Bands{band_type};
    load([mappath 'ShakeMapLand_VarShake_' Band '.mat']);
end

%% Band Data
for band_type=1:length(Bands)
    Band=Bands{band_type};
    threshold=eval(['threshold' Band ]);
    %create var names
    C1A={'id'};
    C1B={['maxarea_' Band ],['peak_' Band ],['ec_value_' Band],['sc_value_' Band],['sctroid_value_' Band],['ec_TOD_' Band],['sc_TOD_' Band],['sctroid_TOD_' Band],['ec_country_' Band],['sc_country_' Band],['sctroid_country_' Band],['ec_XLON_' Band],['sc_XLON_' Band],['sctroid_XLON_' Band], ['ec_YLAT_' Band],['sc_YLAT_' Band],['sctroid_YLAT_' Band],['Dist_EC_SC_' Band], ['Dist_EC_SCtroid_' Band], ['Dist_SC_SCtroid_' Band]};
    C1C=cell(1,length(area_thresh));
    C1D=cell(1,length(pthresh));
    C1E=cell(1,length(threshold));
    C1F=cell(1,length(threshold));
    for i=1:length(area_thresh)
        C1C(i)={['MeanShaking_' Band '_in' num2str(area_thresh(i)) 'km2']};
    end
    for i=1:length(pthresh)
        C1D(i)={['Area_with' num2str(pthresh(i)) 'percentPeak' Band ]};
    end
    for i=1:length(threshold)
        C1E(i)={['Area_above' num2str(threshold(i)*100) Band]};
    end
    C1F={'kick_them'};
    %var content
    C2A=id;
    C2B_num=eval(['[maxarea_' Band 'Land, Peak_' Band 'Land, EC_' Band 'Land.value,SC_' Band 'Land.value,SCtroid_' Band 'Land.value,EC_' Band 'Land.TOD,SC_' Band 'Land.TOD,SCtroid_' Band 'Land.TOD,EC_' Band 'Land.country,SC_' Band 'Land.country,SCtroid_' Band 'Land.country,EC_' Band 'Land.XLON,SC_' Band 'Land.XLON,SCtroid_' Band 'Land.XLON,EC_' Band 'Land.YLAT,SC_' Band 'Land.YLAT,SCtroid_' Band 'Land.YLAT, Dist_' Band 'Land.EC_SC,Dist_' Band 'Land.EC_SCtroid,Dist_' Band 'Land.SCtroid_SC]']);
    C2C_num=eval(['MeanShaking_' Band 'Land']);
    C2D_num=eval(['A_P_' Band 'Land']);
    C2E_num=eval(['A_thr_' Band 'Land']);
    C2F_num=kick_them;

    clear kick_them *PGA* id 

    C2B_cell=num2cell(C2B_num);
    C2C_cell=num2cell(C2C_num);
    C2D_cell=num2cell(C2D_num);
    C2E_cell=num2cell(C2E_num);
    C2F_cell=num2cell(C2F_num);
    % Convert NaN to . (Stata NaNs)
    C2B_cell(isnan(C2B_num))={'.'};
    C2C_cell(isnan(C2C_num))={'.'};
    C2D_cell(isnan(C2D_num))={'.'};
    C2E_cell(isnan(C2E_num))={'.'};
    C2F_cell(isnan(C2F_num))={'.'};
    %combine
    Output_Table=[C1A C1B C1C C1D C1E C1F; C2A C2B_cell C2C_cell C2D_cell C2E_cell C2F_cell];
    %export
    cell2csv(Output_Table, [outpath 'ShakeMap' Band]);
end

%% THE END
display('Done with Step4d!');
