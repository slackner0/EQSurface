addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_importcsv/');
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_from_Sources/stata_translation')

%%
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/';
outpath=[mappath 'Built/'];

load([mappath 'Built/TempEQListFiles/Impact_EQSM_assignment.mat']);
load([mappath 'Built/TempEQListFiles/Match_ShakeMap_USGS_EQ_list.mat']);
load([mappath 'Built/ShakeMap_Info.mat']);
imp=csv2mat_mixed([mappath 'Raw/NOAA/NOAA_Raw_CSV.csv'],2172,47,[18 19 20]);

m=length(imp.YEAR);

%% Match Stuff

Day_Imp=NaN(n,1);
Month_Imp=NaN(n,1);
Year_Imp=NaN(n,1);
Hour_Imp=NaN(n,1);
Min_Imp=NaN(n,1);
Sec_Imp=NaN(n,1);
Lat_Imp=NaN(n,1);
Lon_Imp=NaN(n,1);
Depth_Imp=NaN(n,1);
Mag_Imp=NaN(n,1);
MaxMMI_Imp=NaN(n,1);
damage_Imp=NaN(n,1);
killed_Imp=NaN(n,1);
inj_Imp=NaN(n,1);
hdes_Imp=NaN(n,1);
hdam_Imp=NaN(n,1);
location_Imp=cell(n,1);
tsunami_Imp=NaN(n,1);
volcano_Imp=NaN(n,1);

temp=NaN(m,2);

for i=1:m
    if imp_to_eq(i)~=0
        eql=imp_to_eq(i);
        if eql~=-1
            where=find(EQ_list==eql);
        else
            where=imp_to_sm(i);
            kick_them(where)=0;
        end
        temp(i,1)=eql;
        if ~isempty(where)
            temp(i,2)=where;
            Day_Imp(where)=imp.DAY(i);
            Month_Imp(where)=imp.MONTH(i);
            Year_Imp(where)=imp.YEAR(i);
            Hour_Imp(where)=imp.HOUR(i);
            Min_Imp(where)=imp.MINUTE(i);
            Sec_Imp(where)=imp.SECOND(i);
            Lat_Imp(where)=imp.LATITUDE(i);
            Lon_Imp(where)=imp.LONGITUDE(i);
            Depth_Imp(where)=imp.FOCAL_DEPTH(i);
            Mag_Imp(where)=imp.EQ_PRIMARY(i);
            MaxMMI_Imp(where)=imp.INTENSITY(i);
            damage_Imp(where)=imp.DAMAGE_MILLIONS_DOLLARS(i);
            killed_Imp(where)=imp.DEATHS(i);
            inj_Imp(where)=imp.INJURIES(i);
            hdes_Imp(where)=imp.HOUSES_DESTROYED(i);
            hdam_Imp(where)=imp.HOUSES_DAMAGED(i);
            location_Imp(where)=imp.LOCATION_NAME(i);
            tsunami_Imp(where)=imp.FLAG_TSUNAMI(i);
        end
    end
end
%%
%Number of events with deaths and eq list, but no Shakemap after 1973
sample=((temp(:,1)>0).*isnan(temp(:,2)).*(imp.YEAR>=1973).*(imp.DEATHS>0)==1);
sum(sample)
%imp.I_D((temp(:,1)>0).*isnan(temp(:,2)).*(imp.YEAR>=1973).*(imp.DEATHS>0)==1)
hist(imp.DEATHS(sample))

%Number of impact events without eq list or shakemap between 1970 and November 2016
sample=((imp.YEAR>=1973).*isnan(temp(:,1)).*isnan(temp(:,2)).*((imp.YEAR==2016).*(imp.MONTH>10)==0)==1);
sum(sample)
hist(imp.EQ_PRIMARY(sample))

%Number of events with deaths and no eq list or shakemap between 1970 and November 2016
sample=((imp.YEAR>=1973).*isnan(temp(:,1)).*isnan(temp(:,2)).*((imp.YEAR==2016).*(imp.MONTH>10)==0).*(imp.DEATHS>0)==1);
sum(sample)
hist(imp.DEATHS(sample))
%imp.I_D(sample.*(imp.DEATHS>10)==1)


%Number of shakemaps with off xdim/ydim, but have impacts
%solved this already by adjusting maps accordingly
%sum((Year_Imp>0).*(kick_them==2)==1)

%%
%impid=854
%matching_assignment(854)
%temp(impid,:)

%EQ_list(22877)
%%
save([ outpath 'kick_them.mat'],'kick_them','-v7.3');
save([outpath 'Impacts_ShakeMapLevel.mat'], '*_Imp','-v7.3');

%% Create output as csv for stata

% Step1: EQ SM
out1={'smind','eqid'};
out2=[[1:n]' EQ_list];
out2((EQ_list==0),:)=[];
out2=num2cell(out2);
out=[out1; out2];
cell2csv(out, [mappath 'Built/TempEQListFiles/SM_EQ']);

%Step2: EQ Imp
out1={'impi_d','eqid'};
out2=[imp.I_D imp_to_eq];
out2((imp_to_eq<=0),:)=[];
out2=num2cell(out2);
out=[out1; out2];
cell2csv(out, [mappath 'Built/TempEQListFiles/IMP_EQ']);

%Step3: SM Imp
out1={'impi_d','smind'};
out2=[imp.I_D imp_to_sm];
out2((imp_to_sm<=0),:)=[];
out2=num2cell(out2);
out=[out1; out2];
cell2csv(out, [mappath 'Built/TempEQListFiles/IMP_SM']);


%% THE END
display('DONE with Step3e!!!')
