%% Shakemaps: Create Event Level Shaking Dataset
%Stephanie Lackner, September 9, 2014 (updated: 5/13/18)
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_shakemaptools')

%% Input Section
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
outpath=mappath;

pthresh=[0.9 0.5 0.25 0.1];

area_thresh=[2,4,8,10,16,32,64,100,128,200,256,300,400,500,512,600,700,800,900,1000,1024,1250,1500,1750,2048,4096,8192,10000,16384,32768,65536,100000];

%Bands={'PGA', 'PGV', 'MMI', 'PSA03', 'PSA10', 'PSA30', 'STDPGA', 'URAT', 'SVEL'};
Bands={'PGA', 'PGV', 'MMI'};

thresholds=[1,2.5:2.5:70;
    1,2.5:2.5:70;
    1:0.25:8;
    1,5,10:10:170,zeros(1,10);
    1,5,10:10:170,zeros(1,10);
    1,5,10:10:170,zeros(1,10);
    0.3,0.5,0.75,0.8,0.85,0.9,0.925,0.95,0.99,zeros(1,20);
    0.5,0.9,1,1.1,1.2,1.5,0,0,0,zeros(1,20);
    0.3,0.5,0.75,0.8,0.85,0.9,0.925,0.95,0.99,zeros(1,20)];

%% Import Data
load([mappath 'ShakeMap_Info.mat']);
load([mappath 'Land_km2.mat']);
load([mappath 'CellCountry.mat']);
load([mappath 'kick_them.mat']);

%% Create Interesting Variables

%Go through bands
for type=1:length(Bands)
    %% Define and load variables for current band
    Band=Bands{type};
    threshold=thresholds(type,:);
    threshold(threshold==0)=[];
    eval(['threshold' Band '=threshold;']);
    load([mappath 'ShakeMap_Grid_' Band 'Land.mat']);

    %% Create empty variables for band
    Peak=NaN(n,1);
    MeanShaking=NaN(n,length(area_thresh));
    A_P=NaN(n,length(pthresh));
    A_thr=NaN(n,length(threshold));

    EC.XLON=NaN(n,1);
    EC.YLAT=NaN(n,1);
    EC.col=NaN(n,1);
    EC.row=NaN(n,1);
    EC.value=NaN(n,1);
    EC.TOD=NaN(n,1);
    EC.country=NaN(n,1);

    SC.value=NaN(n,1);
    SC.col=NaN(n,1);
    SC.row=NaN(n,1);
    SC.Num_peak=NaN(n,1);
    SC.out=NaN(n,1);
    SC.XLON=NaN(n,1);
    SC.YLAT=NaN(n,1);
    SC.TOD=NaN(n,1);
    SC.country=NaN(n,1);

    SCtroid.row_value=NaN(n,1);
    SCtroid.row=NaN(n,1);
    SCtroid.col_value=NaN(n,1);
    SCtroid.col=NaN(n,1);
    SCtroid.value=NaN(n,1);
    SCtroid.XLON=NaN(n,1);
    SCtroid.YLAT=NaN(n,1);
    SCtroid.TOD=NaN(n,1);
    SCtroid.country=NaN(n,1);

    maxarea=NaN(n,1);

    %% Calculate variables for individual events
    for i=1:n
        %check if band exists
        if kick_them(i)==0 && isfield(eval([ Band 'Land']),['id' num2str(i)])
            %define current variables
            map=eval([ Band 'Land.id' num2str(i)]);
            if max(max(map))>0
                area_map=eval(['Land_km2.id' num2str(i)]);
                country_map=double(eval(['countrycell.id' num2str(i)]));
                xd=1/res_event(i);
                yd=1/res_event(i);
                ulx=ulxmap(i);
                uly=ulymap(i);
                hourmin=YMDHMS(i,4)+YMDHMS(i,5)/60;

                %Call function to get information about event
                [Peak(i),MeanShaking(i,:),A_P(i,:),A_thr(i,:),maxarea(i)] = eventshaking(map,area_map,area_thresh,threshold,pthresh);

                %Call function for information about event location
                [SC_temp,SCtroid_temp,EC_temp] = eventlocation(map,country_map,ulx,uly,xd,yd,lat(i),lon(i),hourmin);

                SC.value(i)=SC_temp.value;
                SC.col(i)=SC_temp.col;
                SC.row(i)=SC_temp.row;
                SC.Num_peak(i)=SC_temp.Num_peak;
                SC.out(i)=SC_temp.out;
                SC.XLON(i)=SC_temp.XLON;
                SC.YLAT(i)=SC_temp.YLAT;
                SC.TOD(i)=SC_temp.TOD;
                SC.country(i)=SC_temp.country;

                SCtroid.row_value(i)=SCtroid_temp.row_value;
                SCtroid.row(i)=SCtroid_temp.row;
                SCtroid.col_value(i)=SCtroid_temp.col_value;
                SCtroid.col(i)=SCtroid_temp.col;
                SCtroid.value(i)=SCtroid_temp.value;
                SCtroid.XLON(i)=SCtroid_temp.XLON;
                SCtroid.YLAT(i)=SCtroid_temp.YLAT;
                SCtroid.TOD(i)=SCtroid_temp.TOD;
                SCtroid.country(i)=SCtroid_temp.country;

                EC.XLON(i)=EC_temp.XLON;
                EC.YLAT(i)=EC_temp.YLAT;
                EC.col(i)=EC_temp.col;
                EC.row(i)=EC_temp.row;
                EC.value(i)=EC_temp.value;
                EC.TOD(i)=EC_temp.TOD;
                EC.country(i)=EC_temp.country;
            end
        end
    end

    %% DISTANCES BETWEEN LOCATIONS
    earthellipsoid = referenceSphere('earth','km');

    Dist.EC_SC=distance(EC.YLAT,EC.XLON,SC.YLAT,SC.XLON,earthellipsoid);
    Dist.EC_SCtroid=distance(EC.YLAT,EC.XLON,SCtroid.YLAT,SCtroid.XLON,earthellipsoid);
    Dist.SCtroid_SC=distance(SCtroid.YLAT,SCtroid.XLON,SC.YLAT,SC.XLON,earthellipsoid);

    %% Assign to Band vars and save
    eval(['maxarea_' Band 'Land=maxarea;']);
    eval(['Peak_' Band 'Land=Peak;']);
    eval(['MeanShaking_' Band 'Land=MeanShaking;']);
    eval(['A_thr_' Band 'Land=A_thr;']);
    eval(['A_P_' Band 'Land=A_P;']);
    eval(['EC_' Band 'Land=EC;']);
    eval(['SC_' Band 'Land=SC;']);
    eval(['SCtroid_' Band 'Land=SCtroid;']);
    eval(['Dist_' Band 'Land=Dist;']);

    save([outpath 'ShakeMapLand_VarShake_' Band '.mat'],['maxarea_' Band 'Land'],['Peak_' Band 'Land'],['MeanShaking_' Band 'Land'],['A_thr_' Band 'Land'],['A_P_' Band 'Land'],['EC_' Band 'Land'],['SC_' Band 'Land'],['SCtroid_' Band 'Land'],['Dist_' Band 'Land'],['threshold' Band],'area_thresh','pthresh','-v7.3');
    eval(['clear *' Band '*']);

end


%% THE END
display('Done with Step4b!!!')
