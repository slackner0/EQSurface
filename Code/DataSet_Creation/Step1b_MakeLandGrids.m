%% Shakemaps: Create Workspace for Analysis
%Stephanie Lackner, December 29, 2016 (updated: May 2, 2018)
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_scale')
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_shakemaptools')
%% Input Section
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
LandPath='/Users/slackner/Google Drive/Research/Projects/EarthquakeGDP/Data/Raw/gpw-v4-land-water-area-land/';
outpath=mappath;

%% Import Data
load([mappath 'ShakeMap_Info.mat']);
load([mappath 'ShakeMap_Grid_PGA.mat']);
[land, R] = geotiffread([LandPath 'gpw-v4-land-water-area_land.tif']);
land(land<0)=0;
land=double(land);
landbreakswitch=[land(:,size(land,2)/2+1:end) land(:,1:size(land,2)/2)];

ulxmap(ulxmap<-180)=ulxmap(ulxmap<-180)+360;
urxmap=ulxmap+ncols./res_event;
llymap=ulymap-nrows./res_event;
ylim=-60;
res_GPW=120;

%% Create LandMaps
ShakeMapNA=[];
for event=1:n
    if isfield(PGA, ['id' num2str(event)])
        %make empty landmatrix
        land_map=zeros(nrows(event),ncols(event));

        %check if shakemap crosses 180 longitude line
        if urxmap(event)>180
            breakswitch=1;
        else
            breakswitch=0;
        end

        %Find resolution to match shakemap with GPW data
        resolution=lcm(res_GPW*2, res_event(event));

        % find box limit res_GPW
        boxGPW=box_limit([ulxmap(event) urxmap(event)],[llymap(event) ulymap(event)],res_GPW);

        % check if shakemap is in area that is not covered by GPW.
        if boxGPW(2,2)<ylim
            boxGPW(2,2)=ylim;
            partbelowGPW=1;
        else
            partbelowGPW=0;
        end
        if boxGPW(1,2)<ylim
            boxGPW(1,2)=ylim;
            belowGPW=1;
        else
            belowGPW=0;
        end

        if belowGPW==0
            %get grid coordinates
            [xpop1,xpop2,ypop1,ypop2] = evengrid_limit(boxGPW,-180+180*breakswitch,85,res_GPW);
            %get relevant land map from GPW data
            if breakswitch==0
                land_GPW=land(ypop1:ypop2,xpop1:xpop2);
            else
                land_GPW=landbreakswitch(ypop1:ypop2,xpop1:xpop2);
            end

            % scale maps up to right resolution, making sure that land area doesn't get distorted (keepsum==1)
            f1=round(resolution/res_GPW);
            f2=round(resolution/res_event(event));
            land_GPW_res=upscale(land_GPW,f1,f1,1);
            land_map_res=upscale(land_map,f2,f2,0);

            % find box limit resolution
            box=NaN(2,2);
            box(1,1)=floor(round(ulxmap(event)*resolution,6))/resolution;
            box(2,1)=floor(round(urxmap(event)*resolution,6))/resolution;
            box(1,2)=ceil(round(llymap(event)*resolution,6))/resolution;
            box(2,2)=ceil(round(ulymap(event)*resolution,6))/resolution;

            [axpop1,axpop2,aypop1,aypop2] = evengrid_limit(box,-180+180*breakswitch,85,resolution);
            axpop1_bar=(xpop1-1)*f1+1;
            axpop2_bar=xpop2*f1;
            aypop1_bar=(ypop1-1)*f1+1;
            aypop2_bar=ypop2*f1;
            %Get appropriate part of the GPW land map
            land_GPW_res=land_GPW_res(1+aypop1-aypop1_bar:end-(aypop2_bar-aypop2),1+axpop1-axpop1_bar:end-(axpop2_bar-axpop2));

            %right matrix at high resolution
            if partbelowGPW==0
                land_map_res(:,:)=land_GPW_res;
            else
                land_map_res(1:size(land_GPW_res,1),:)=land_GPW_res;
            end

            %bring resolution down to Shakemap resolution,
            %again making sure that area sum stays the same
            land_map(:,:)=downscale(land_map_res,f2,f2,1);
        end
        eval(['Land_km2.id' num2str(event) '=land_map;']);
    else
        ShakeMapNA=[ShakeMapNA;event];
    end
end

save([outpath 'Land_km2.mat'],'Land_km2','-v7.3');
save([outpath 'ShakeMapNA.mat'],'ShakeMapNA','-v7.3');


%% THE END
display('Done with Step1b!')
