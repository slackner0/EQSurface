addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_from_Sources/stata_translation')

mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
outpath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/TempEQListFiles/';

load([mappath 'ShakeMap_Info.mat']);
load([mappath 'ShakeMap_Grid_PGALand.mat']);

%%%
peakPGA=zeros(n,1);
for i=1:n
    if isfield(PGALand,['id' num2str(i)])
        map=eval(['PGALand.id' num2str(i)]);
        peakPGA(i)=max(max(map));
    end
end
%%%

area=ncols.*nrows.*(1./res_event).*(1./res_event);

%% CLEAN OUT SHAKEMAPS that are very close and produced far apart (years) from each other
kick_out=zeros(n,1);

for i=1:n
     j=i;
     while kick_out(i)==0 && j<n
         j=j+1;
         %within two seconds, lat lon within 1.5 cell
         if abs(time(j)-time(i))*24*60*60<2 && sqrt((lat(i)-lat(j))^2+(lon(i)-lon(j))^2)<1.5
             %timestamp at least 500 days apart
             if timestamp(i)-timestamp(j)>500 && (area(i)*10>area(j) || (area(j)<=12 && area(i)>12))
                 kick_out(j)=1;
             elseif timestamp(i)-timestamp(j)<-500 && (area(j)*10>area(i) || (area(i)<=12 && area(j)>12))
                 kick_out(i)=1;
             end
         end
     end
end

for i=1:n
     j=i;
     while kick_out(i)==0 && j<n
         j=j+1;
         %within 65 seconds, lat lon within 2 cell
         if abs(time(j)-time(i))*24*60*60<65 && sqrt((lat(i)-lat(j))^2+(lon(i)-lon(j))^2)<2
             %timestamp at least 1000 days apart
             if timestamp(i)-timestamp(j)>1000 && (area(i)*10>area(j) || (area(j)<=12 && area(i)>12))
                 kick_out(j)=1;
             elseif timestamp(i)-timestamp(j)<-1000 && (area(j)*10>area(i) || (area(i)<=12 && area(j)>12))
                 kick_out(i)=1;
             end
         end
     end
end

%summarize(kick_out)

%%

Out1={'kick_out' 'smind' 'smpeakpga' 'smid' 'smdepth' 'smlat' 'smlon' 'smmagnitude' 'smncols' 'smnetwork' 'smcode_version' 'smnrows' 'smregion' 'smres_event' 'smstatus' 'smtime' 'smtimestamp' 'smtype' 'smulxmap' 'smulymap' 'smversion' 'smxdim' 'smydim' 'smyear' 'smmonth' 'smday' 'SMhour' 'SMminute' 'SMsecond'};
%replace commas
region=strrep(region, ',', ' ');
id=strrep(id, ',', ' ');
type=strrep(type, ',', ' ');
network=strrep(network, ',', ' ');
status=strrep(status, ',', ' ');

Out2=[];
for i=1:n
    Out2=[Out2; kick_out(i) i peakPGA(i) id(i) depth(i) lat(i) lon(i) magnitude(i) ncols(i) network(i) code_version(i) nrows(i) region(i) res_event(i) status(i) time(i) timestamp(i) type(i) ulxmap(i) ulymap(i) version(i) 1/res_event(i) 1/res_event(i) YMDHMS(i,1) YMDHMS(i,2) YMDHMS(i,3) YMDHMS(i,4) YMDHMS(i,5) YMDHMS(i,6)];
end

Out=[Out1; Out2];

cell2csv(Out, [outpath 'ShakeMap_List']);
display('DONE with Step1d!!!')
