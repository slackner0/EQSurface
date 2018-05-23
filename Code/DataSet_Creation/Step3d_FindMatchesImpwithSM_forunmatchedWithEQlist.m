addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_importcsv/');
%%
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/';
outpath=[mappath 'Built/TempEQListFiles/'];

load([mappath 'Built/TempEQListFiles/Impact_EQ_assignment.mat']);
load([mappath 'Built/TempEQListFiles/Match_ShakeMap_USGS_EQ_list.mat']);
load([mappath 'Built/ShakeMap_Info.mat']);
imp=csv2mat_mixed([mappath 'Raw/NOAA/NOAA_Raw_CSV.csv'],2172,47,[18 19 20]);


imp.SECOND(isnan(imp.SECOND))=30;
imptime=datenum(imp.YEAR,imp.MONTH,imp.DAY,imp.HOUR,imp.MINUTE,imp.SECOND);
IMPN=length(imp.YEAR);

%%
%Yet unassigned Shakemaps
smua=(EQ_list==0);

sm_to_imp=zeros(n,1);
imp_to_sm=zeros(IMPN,1);

for i=1:IMPN
    if imp_to_eq(i)==0 && i~=1765
        timediff=abs(imptime(i)-time)*60*24*60;
        dist=sqrt((imp.LATITUDE(i)-lat).^2+(imp.LONGITUDE(i)-lon).^2);
        magdiff=abs(imp.EQ_PRIMARY(i)-magnitude);
        sample=find((timediff<=90).*(dist<=5).*(magdiff<=2).*smua);
        daydiff=abs(datenum(imp.YEAR(i),imp.MONTH(i),imp.DAY(i),12,0,0)-time);
        if size(sample,1)==1
            imp_to_sm(i)=sample;
            imp_to_eq(i)=-1;
            sm_to_imp(sample)=sm_to_imp(sample)+1;
        elseif size(sample,1)>1
            [x,where1]=min(timediff(sample));
            [x,where2]=min(dist(sample));
            if where1==where2
                sample=sample(where1);
                imp_to_sm(i)=sample;
                imp_to_eq(i)=-1;
                sm_to_imp(sample)=sm_to_imp(sample)+1;
            else
                imp_to_eq(i)=-2;
            end
        elseif isnan(imptime(i))
            sample=find((daydiff<=1).*(dist<=2.5).*(magdiff<=2).*smua);
            if size(sample,1)==1
                imp_to_sm(i)=sample;
                imp_to_eq(i)=-1;
                sm_to_imp(sample)=sm_to_imp(sample)+1;
            elseif size(sample,1)>1
                [x,where1]=min(timediff(sample));
                [x,where2]=min(dist(sample));
                if where1==where2
                    sample=sample(where1);
                    imp_to_sm(i)=sample;
                    imp_to_eq(i)=-1;
                    sm_to_imp(sample)=sm_to_imp(sample)+1;
                else
                    imp_to_eq(i)=-2;
                end
            end
        elseif min(daydiff)<1
            sample=find((daydiff<=1).*(dist<=0.2).*(magdiff<=0.2).*smua);
            if size(sample,1)==1
                imp_to_sm(i)=sample;
                imp_to_eq(i)=-1;
                sm_to_imp(sample)=sm_to_imp(sample)+1;
            elseif size(sample,1)>1
                [x,where1]=min(timediff(sample));
                [x,where2]=min(dist(sample));
                if where1==where2
                    sample=sample(where1);
                    imp_to_sm(i)=sample;
                    imp_to_eq(i)=-1;
                    sm_to_imp(sample)=sm_to_imp(sample)+1;
                else
                    imp_to_eq(i)=-2;
                end
            end
        end
        if i/500==round(i/500)
            i/IMPN
        end
    end
end


display(['Number of assigned Impact events: ' num2str(sum(imp_to_eq>0))]);
display(['Number of Impact events with Shakemap but no EQlist: ' num2str(sum(imp_to_eq==-1))]);
display(['Number of Impact events with issue Shakemaps but no EQlist: ' num2str(sum(imp_to_eq==-2))]);
display(['Number of Impact events without match: ' num2str(sum(imp_to_eq==0))]);
display(['Number of Duplicates: ' num2str(sum(sm_to_imp>1))]);


%%
save([outpath 'Impact_EQSM_assignment.mat'],'imp_to_sm','imp_to_eq','-v7.3');
display('DONE with Step3d!!!')
