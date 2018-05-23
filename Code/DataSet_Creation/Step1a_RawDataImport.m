%% Shakemaps: Create Matlab Workspace from Raw Data
%Stephanie Lackner, September 9, 2014 (updated: 5/14/18)

%% Input Section
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_from_Sources/matlab_libgrid/')
%path to folder where the xml files are saved
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Raw/ShakeMaps_XML/';

%path to folder where the output is saved
outpath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';

%% Import DATA
Bands={'PGA', 'PGV', 'MMI', 'PSA03', 'PSA10', 'PSA30', 'STDPGA', 'URAT', 'SVEL'};

id_string='id';
filenameend='*.xml';
file_list=dir(fullfile(mappath, filenameend));
n=length(file_list);

id=cell(n,1);
timestamp=NaN(n,1);
version=NaN(n,1);
magnitude=NaN(n,1);
depth=NaN(n,1);
lat=NaN(n,1);
lon=NaN(n,1);
time=NaN(n,1);
region=cell(n,1);
type=cell(n,1);
network=cell(n,1);
status=cell(n,1);
code_version=cell(n,1);

nrows=NaN(n,1);
ncols=NaN(n,1);
ulxmap=NaN(n,1);
ulymap=NaN(n,1);
xdim=NaN(n,1);
ydim=NaN(n,1);

res_event=zeros(n,1);

num=1;

for event=num:n
    filename=file_list(event).name;
    %header information
    [hdrstruct,eventdetails]=readsmheader(fullfile(mappath,filename));
    %Save Other Data
    id(event)={eventdetails.id};
    timestamp(event)=eventdetails.process_timestamp;
    version(event)=eventdetails.version;
    magnitude(event)=eventdetails.magnitude;
    depth(event)=eventdetails.depth;
    lat(event)=eventdetails.lat;
    lon(event)=eventdetails.lon;
    time(event)=eventdetails.time;
    region(event)={eventdetails.region};
    type(event)={eventdetails.type};
    network(event)={eventdetails.network};
    status(event)={eventdetails.shakemap_grid.map_status};
    code_version(event)={eventdetails.shakemap_grid.code_version};

    nrows(event)=hdrstruct.nrows;
    ncols(event)=hdrstruct.ncols;
    ulxmap(event)=hdrstruct.ulxmap;
    ulymap(event)=hdrstruct.ulymap;
    xdim(event)=hdrstruct.xdim;
    ydim(event)=hdrstruct.ydim;

    %Save Shakemap Grid
    smgrid=readsmgrid(fullfile(mappath,filename));
    for band_type=1:9
        Band=Bands{band_type};
        %check if band exists for the event
        band_position=find(strcmp(eventdetails.bandnames,Band));
        if isempty(band_position)==0
            eval([Band '.([ id_string num2str(event) ])=squeeze(smgrid.grid(:,:,band_position));']);
        end
    end
    res_event(event)=round(xdim(event)^(-1));
    if event/100==round(event/100)
      event/n
    end
end


%% other event information
YMDHMS=datevec(time);

resx=round(1./xdim);
resy=round(1./ydim);

res_event=resx;
res_eventy=resy;

temp=(resx==resy);
resx(temp)=[];
resy(temp)=[];
%scatter(resx, resy)
%summarize(resx)
%summarize(resy)

% some events have resx=12 and resy=20 => translate to resolution of 60
xdimydimoff=(1==(res_event==12).*(res_eventy==20));
res_event(xdimydimoff)=60;

nrows(xdimydimoff)=nrows(xdimydimoff)*60/20;
ncols(xdimydimoff)=ncols(xdimydimoff)*60/12;


% Save Workspace
save([outpath 'ShakeMap_Info.mat'], 'xdimydimoff','res_event','id','type','network','status','code_version','timestamp','version','magnitude','depth','lat','lon','time','YMDHMS','region','nrows','ncols','n','ulxmap','ulymap','xdim','ydim', '-v7.3');


for band_type=1:9
    Band=Bands{band_type};
    save([outpath 'ShakeMap_Grid_' Band '.mat'],Band,'-v7.3');
end



%% THE END
display('Done with Step1a!!!')
