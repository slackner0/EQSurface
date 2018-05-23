%% Shakemaps: Make Land Shake Maps
%Stephanie Lackner, December 29, 2014 (updated: May 2, 2018)
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_scale')
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_shakemaptools')
%% Input Section
MapFilePath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
Workingpath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Code/DataSet_Creation/';
outpath=MapFilePath;

Bands={'PGA', 'PGV', 'MMI', 'PSA03', 'PSA10', 'PSA30', 'STDPGA', 'URAT', 'SVEL'};

%% Import Data
cd(MapFilePath);
load ShakeMap_Info.mat;
load Land_km2.mat;
cd(Workingpath);

%% Create LandMaps
for type=1:9
    Band=Bands{type};
    load([MapFilePath 'ShakeMap_Grid_' Band '.mat']);
    for event=1:n
        if isfield(eval(Band), ['id' num2str(event)])
            tempLand=eval(['Land_km2.id' num2str(event)]);
            tempLand(tempLand<0.000001)=0;
            tempLand(tempLand>0)=1;
            temp=eval([Band '.id' num2str(event)]);
            %rescaleshakemap
            if xdimydimoff(event)==1
                temp=upscale(temp,round(60/12),round(60/20),0);
            end
            %multiply shakemap with landcover
            temp=temp.*tempLand;
            eval([Band 'Land.id' num2str(event) '=temp;']);
        end
    end
    save([outpath 'ShakeMap_Grid_' Band 'Land.mat'],[Band 'Land'],'-v7.3');
    eval(['clear ' Band ' ' Band 'Land']);
end

%% THE END
display('Done with Step1c!')
