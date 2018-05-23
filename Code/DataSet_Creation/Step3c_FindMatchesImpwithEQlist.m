addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_importcsv/');

mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/';
outpath=[mappath 'Built/TempEQListFiles/'];
%%
eq=csv2mat_mixed([mappath 'Built/ComCat/earthquakelist_withshakemap_orover4point5.csv'],225390,34,[1 6 11 12 13 14 15 20 21 22]);
imp=csv2mat_mixed([mappath 'Raw/NOAA/NOAA_Raw_CSV.csv'],2172,47,[18 19 20]);
IMPN=length(imp.YEAR);
EQN=length(eq.year);
imp.SECOND(isnan(imp.SECOND))=30;
imptime=datenum(imp.YEAR,imp.MONTH,imp.DAY,imp.HOUR,imp.MINUTE,imp.SECOND);
eqtime=datenum(eq.year,eq.month,eq.day,eq.hour,eq.minute,eq.second);
imp_to_eq=zeros(IMPN,1);
eq_to_imp=zeros(EQN,1);
%% MANUAL MATCHES
imp_to_eq(2075)=207563;
eq_to_imp(207563)=1;

imp_to_eq(1361)=125579;
eq_to_imp(125579)=1;

imp_to_eq(789)=53135;
eq_to_imp(53135)=1;

imp_to_eq(1033)=81950;
eq_to_imp(81950)=1;

imp_to_eq(454)=12218;
eq_to_imp(12218)=1;

imp_to_eq(162)=1637;
eq_to_imp(1637)=1;

imp_to_eq(49)=447;
eq_to_imp(447)=1;

imp_to_eq(2126)=218337;
eq_to_imp(218337)=1;

imp_to_eq(2127)=218336;
eq_to_imp(218336)=1;

%they lost the leading 100 for the longitude, therefore couldnt be auto
%matched
imp_to_eq(2157)=225199;
eq_to_imp(225199)=1;

%hour wrong
imp_to_eq(2043)=202448;
eq_to_imp(202448)=1;

%day wrong
imp_to_eq(2092)=210789;
eq_to_imp(210789)=1;

%two very similar events in eq list 120733 and 120732, one seems to be
%better match for shakemap, therefore impact needs to be matched to same
%event
imp_to_eq(imp.I_D==5624)=120732;
eq_to_imp(210732)=1;
%two very similar events in eq list 80174 and 80175, one seems to be
%better match for shakemap, therefore impact needs to be matched to same
%event
imp_to_eq(imp.I_D==5344)=80174;
eq_to_imp(80174)=1;

%% RUN
for i=1:IMPN
    %1765 is duplicate event
    if imp_to_eq(i)==0 && i~=1765
        timediff=abs(imptime(i)-eqtime)*60*24*60;
        dist=sqrt((imp.LATITUDE(i)-eq.latitude).^2+(imp.LONGITUDE(i)-eq.longitude).^2);
        magdiff=abs(imp.EQ_PRIMARY(i)-eq.mag);
        sample=find((timediff<=90).*(dist<=5).*(magdiff<=2));
        daydiff=abs(datenum(imp.YEAR(i),imp.MONTH(i),imp.DAY(i),12,0,0)-eqtime);
        if size(sample,1)==1
            imp_to_eq(i)=sample;
            eq_to_imp(sample)=eq_to_imp(sample)+1;
        elseif size(sample,1)>1
            [x,where1]=min(timediff(sample));
            [x,where2]=min(dist(sample));
            if where1==where2
                imp_to_eq(i)=sample(where1);
                eq_to_imp(sample(where1))=eq_to_imp(sample(where1))+1;
            else
                imp_to_eq(i)=-2;
            end
        elseif isnan(imptime(i))
            sample=find((daydiff<=1).*(dist<=2.5).*(magdiff<=2));
            if size(sample,1)==1
                imp_to_eq(i)=sample;
                eq_to_imp(sample)=eq_to_imp(sample)+1;
            elseif size(sample,1)>1
                [x,where1]=min(timediff(sample));
                [x,where2]=min(dist(sample));
                if where1==where2
                    imp_to_eq(i)=sample(where1);
                    eq_to_imp(sample(where1))=eq_to_imp(sample(where1))+1;
                else
                    imp_to_eq(i)=-2;
                end
            end
        elseif min(daydiff)<1
            sample=find((daydiff<=1).*(dist<=0.2).*(magdiff<=0.2));
            if size(sample,1)==1
                imp_to_eq(i)=sample;
                eq_to_imp(sample)=eq_to_imp(sample)+1;
            elseif size(sample,1)>1
                [x,where1]=min(timediff(sample));
                [x,where2]=min(dist(sample));
                if where1==where2
                    imp_to_eq(i)=sample(where1);
                    eq_to_imp(sample(where1))=eq_to_imp(sample(where1))+1;
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
display(['Number of Impact events without match: ' num2str(sum(imp_to_eq==0))]);
display(['Number of Impact events with multiple matches: ' num2str(sum(imp_to_eq==-2))]);
display(['Number of Duplicates (same eq to several imp): ' num2str(sum(eq_to_imp>1))]);


%%
save([outpath 'Impact_EQ_assignment.mat'],'imp_to_eq','-v7.3');
display('DONE with Step3c!!!')
