%%
addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_importcsv/');
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';
outpath=[mappath 'TempEQListFiles/'];
load([mappath 'ShakeMap_Info.mat']);

smlist=csv2mat_mixed([mappath 'TempEQListFiles/ShakeMaps_NOT_MATCHED.csv'],8790,1,[]);
eq=csv2mat_mixed([mappath 'TempEQListFiles/EARTHQUAKE_List_NOT_MATCHED.csv'],217508,34,[10 15 20 21 22 23 24 29 30 31]);
%%
SMN=length(smlist.smind);
EQN=length(eq.eqid);
eq_to_sm=zeros(EQN,1);
sm=smlist.smind;
sm_to_eq=zeros(SMN,1);

eqtime=datenum(eq.year,eq.month,eq.day,eq.hour,eq.minute,eq.second);
%% MANUAL MATCHES
sm_to_eq(sm==22215)=54549;
eq_to_sm(eq.eqid==54549)=eq_to_sm(eq.eqid==54549)+1;

sm_to_eq(sm==22333)=58683;
eq_to_sm(eq.eqid==58683)=eq_to_sm(eq.eqid==58683)+1;

sm_to_eq(sm==11826)=eq.eqid(186016);
eq_to_sm(186016)=eq_to_sm(186016)+1;

sm_to_eq(sm==16174)=204298;
eq_to_sm(eq.eqid==204298)=eq_to_sm(eq.eqid==204298)+1;

sm_to_eq(sm==22094)=48515;
eq_to_sm(eq.eqid==48515)=eq_to_sm(eq.eqid==48515)+1;

sm_to_eq(sm==16852)=53119;
eq_to_sm(eq.eqid==53119)=eq_to_sm(eq.eqid==53119)+1;

sm_to_eq(sm==22271)=56412;
eq_to_sm(eq.eqid==56412)=eq_to_sm(eq.eqid==56412)+1;

sm_to_eq(sm==22908)=81690;
eq_to_sm(eq.eqid==81690)=eq_to_sm(eq.eqid==81690)+1;

sm_to_eq(sm==11227)=170809;
eq_to_sm(eq.eqid==170809)=eq_to_sm(eq.eqid==170809)+1;

sm_to_eq(sm==21745)=33329;
eq_to_sm(eq.eqid==33329)=eq_to_sm(eq.eqid==33329)+1;

sm_to_eq(sm==15551)=188069;
eq_to_sm(eq.eqid==188069)=eq_to_sm(eq.eqid==188069)+1;

sm_to_eq(sm==25550)=eq.eqid(147509);
eq_to_sm(147509)=eq_to_sm(147509)+1;

sm_to_eq(sm==13047)=eq.eqid(161472);
eq_to_sm(161472)=eq_to_sm(161472)+1;

sm_to_eq(sm==1317)=eq.eqid(166772);
eq_to_sm(166772)=eq_to_sm(166772)+1;

sm_to_eq(sm==1320)=eq.eqid(166825);
eq_to_sm(166825)=eq_to_sm(166825)+1;

sm_to_eq(sm==3245)=eq.eqid(188356);
eq_to_sm(188356)=eq_to_sm(188356)+1;

sm_to_eq(sm==1890)=eq.eqid(189524);
eq_to_sm(189524)=eq_to_sm(189524)+1;

sm_to_eq(sm==166)=eq.eqid(203727);
eq_to_sm(203727)=eq_to_sm(203727)+1;

sm_to_eq(sm==244)=eq.eqid(205035);
eq_to_sm(205035)=eq_to_sm(205035)+1;

sm_to_eq(sm==1229)=eq.eqid(217051);
eq_to_sm(217051)=eq_to_sm(217051)+1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Go through shakemaps, in same minute difference
Problem=[];
Matched=[];
for i=1:SMN
    if sm_to_eq(i)==0
    smi=sm(i);
    %Calculate time difference in seconds
    timediff=abs(time(smi)-eqtime)*24*60*60;
    %At most something appart
    sample=find(timediff<=60);
    if size(sample,1)==1
        timedist=abs(time(smi)-eqtime(sample))*24*60*60;
        dist=sqrt((lat(smi)-eq.latitude(sample))^2+(lon(smi)-eq.longitude(sample))^2);
        magdiff=abs(magnitude(smi)-eq.mag(sample));
        if ((magdiff<2.2 && magnitude(smi)>=5.5) || magdiff<0.7 || timedist<2) && (dist<2 || dist>359)
            sm_to_eq(i)=eq.eqid(sample);
            eq_to_sm(sample)=eq_to_sm(sample,1)+1;
            %Matched=[Matched; i sample eq.place(i) region(sample) eq.year(i) YMDHMS(sample,1) eq.month(i) YMDHMS(sample,2) eq.day(i) YMDHMS(sample,3) eq.hour(i) YMDHMS(sample,4) eq.minute(i) YMDHMS(sample,5)];
        else
            sm_to_eq(i)=-1;
            %if dist<50 & magnitude(smi)>=5.9
                Problem=[Problem; smi i sample timedist dist magdiff eq.mag(sample) magnitude(smi) eq.place(sample) region(smi) lat(smi) eq.latitude(sample) lon(smi) eq.longitude(sample) eq.year(sample) eq.month(sample) eq.day(sample) eq.hour(sample) eq.minute(sample) eq.second(sample) YMDHMS(smi,:) ];
            %end
        end
    elseif size(sample,1)>1
        dist=sqrt((lat(smi)-eq.latitude(sample)).^2+(lon(smi)-eq.longitude(sample)).^2);
        magdiff=(magnitude(smi)-eq.mag(sample));
        timedist=abs(time(smi)-eqtime(sample))*24*60*60;
        [x,where1]=min(timedist);
        [x,where2]=min(dist);
        temp=timedist;
        temp(where1)=[];
        min2=min(temp);
        temp=dist;
        temp(where2)=[];
        min2d=min(temp);
        if where1==where2
            if (dist(where1)<2 || dist(where1)>359)  && ((magdiff(where1)<2.2 && magnitude(smi)>=5.5 || timedist(where1)<2) || magdiff(where1)<0.7 )
                sm_to_eq(i)=eq.eqid(sample(where1));
                eq_to_sm(sample(where1))=eq_to_sm(sample(where1))+1;
            else
                sm_to_eq(i)=-1;
                Problem=[Problem; smi i sample(where1) timedist(where1) dist(where1) magdiff(where1) eq.mag(sample(where1)) magnitude(smi) eq.place(sample(where1)) region(smi) lat(smi) eq.latitude(sample(where1)) lon(smi) eq.longitude(sample(where1)) eq.year(sample(where1)) eq.month(sample(where1)) eq.day(sample(where1)) eq.hour(sample(where1)) eq.minute(sample(where1)) eq.second(sample(where1)) YMDHMS(smi,:) ];
            end
        elseif (timedist(where1)<1 && min2>5) || timedist(where1)*5<min2
            if (dist(where1)<2 || dist(where1)>359)  && ((magdiff(where1)<2.2 && magnitude(smi)>=5.5 || timedist(where1)<2) || magdiff(where1)<0.7 )
                sm_to_eq(i)=eq.eqid(sample(where1));
                eq_to_sm(sample(where1))=eq_to_sm(sample(where1))+1;
            else
                sm_to_eq(i)=-1;
                Problem=[Problem; smi i sample(where1) timedist(where1) dist(where1) magdiff(where1) eq.mag(sample(where1)) magnitude(smi) eq.place(sample(where1)) region(smi) lat(smi) eq.latitude(sample(where1)) lon(smi) eq.longitude(sample(where1)) eq.year(sample(where1)) eq.month(sample(where1)) eq.day(sample(where1)) eq.hour(sample(where1)) eq.minute(sample(where1)) eq.second(sample(where1)) YMDHMS(smi,:) ];
            end
        elseif dist(where2)<1 && min2d>3
            if (dist(where2)<2 || dist(where2)>359)  && ((magdiff(where2)<2.2 && magnitude(smi)>=5.5 || timedist(where2)<2) || magdiff(where2)<0.7 )
                sm_to_eq(i)=eq.eqid(sample(where2));
                eq_to_sm(sample(where2))=eq_to_sm(sample(where2))+1;
            else
                sm_to_eq(i)=-1;
                Problem=[Problem; smi i sample(where2) timedist(where2) dist(where2) magdiff(where2) eq.mag(sample(where2)) magnitude(smi) eq.place(sample(where2)) region(smi) lat(smi) eq.latitude(sample(where2)) lon(smi) eq.longitude(sample(where2)) eq.year(sample(where2)) eq.month(sample(where2)) eq.day(sample(where2)) eq.hour(sample(where2)) eq.minute(sample(where2)) eq.second(sample(where2)) YMDHMS(smi,:) ];
            end
        else
            sm_to_eq(i,1)=-2;
        end
    end
    %if i/100==round(i/100)
    %    i/EQN
    %end
    end
end

% if event was problem (not perfect match) but match actually assigned to
% some other event, than say it wasn't assigned
i=1;
while  i<=size(Problem,1)
    if ~isempty(find(sm_to_eq==eq.eqid(Problem{i,3}), 1))
        if sm_to_eq(Problem{i,2})==-1
            sm_to_eq(Problem{i,2})=0;
        end
        Problem(i,:)=[];
        i=i-1;
    end
    if Problem{i,5}>20 && Problem{i,5}<350
        Problem(i,:)=[];
        i=i-1;
    end
    i=i+1;
end
%%
display(['Number of shakemaps assigned to eq ' num2str(sum(sm_to_eq>0))]);
display(['Number of shakemaps without eq ' num2str(sum(sm_to_eq==0))]);
display(['Number of shakemaps with error eq ' num2str(sum(sm_to_eq==-1))]);
display(['Number of shakemaps with multiple eq to figure out ' num2str(sum(sm_to_eq==-2))]);
display(['Same EQ to several Shakemaps ' num2str(sum(sm_to_eq>0)-size(unique(sm_to_eq(sm_to_eq>0)),1))]);
display(['EQ that should have ShakeMap but dont ' num2str(sum(1==(eq_to_sm==0).*(eq.shakemap==1)))]);

%%
%summarize(eq_to_sm)

sample=((eq_to_sm==0).*(eq.shakemap==1).*(eq.mag>=5.5)==1);

[eq.year(sample) eq.month(sample) eq.day(sample) eq.hour(sample)]
eq.place(sample)
[eq.latitude(sample) eq.longitude(sample)]

%find(eq_to_sm==2)
%eq.eqid(find(eq_to_sm==2))
%[eq.year(eq_to_sm==2) eq.month(eq_to_sm==2) eq.day(eq_to_sm==2) eq.hour(eq_to_sm==2) eq.minute(eq_to_sm==2)]
sm_to_eq(sm_to_eq==-1)=0;
notassigned=zeros(n,1);
assigned=zeros(n,1);
notassigned(sm(sm_to_eq==0))=1;
assigned(sm(sm_to_eq~=0))=1;
%Seems to be either duplicates or below 4.5 magnitude now
%YMDHMS(notassigned.*(magnitude>=5.9)==1,:)


temp=code_version(notassigned==1);
%%
smind=sm;
save([outpath 'Match2.mat'],'smind','sm_to_eq','-v7.3');
display('DONE with Step3a!!!')
