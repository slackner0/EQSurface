addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_summarize')
mappath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/';


load([mappath 'ShakeMap_Info.mat']);
load([mappath 'kick_them.mat']);
load([mappath 'ShakeMap_Grid_PGALand.mat']);
load([mappath 'ShakeMapLand_VarShake_PGA.mat']);

%% Check if non-PGA maps are in there - no there are none
temp=zeros(n,1);
for i=1:n
    if kick_them(i)==0 && isfield(PGALand,['id' num2str(i)])==0
        temp(i)=1;
    end
end

disp('Number of events with specific criteria');
disp('All events until (incl) 10/2016');
sum((kick_them==0).*((YMDHMS(:,1)==2016).*(YMDHMS(:,2)>=11)==0))
disp('All events until (incl) 10/2016 with non-zero shaking');
sum((kick_them==0).*(Peak_PGALand>0).*((YMDHMS(:,1)==2016).*(YMDHMS(:,2)>=11)==0))
disp('All events until (incl) 10/2016 with Magnitude greater or equal 4.5');
sum((kick_them==0).*(magnitude>=4.5).*((YMDHMS(:,1)==2016).*(YMDHMS(:,2)>=11)==0))
disp('All events until (incl) 10/2016 with with non-zero shaking and Magnitude greater or equal 4.5');
sum((kick_them==0).*(magnitude>=4.5).*(Peak_PGALand>0).*((YMDHMS(:,1)==2016).*(YMDHMS(:,2)>=11)==0))
%% Define SAMPLE
sample=(kick_them==0).*(magnitude>=4.5).*(Peak_PGALand>0).*((YMDHMS(:,1)==2016).*(YMDHMS(:,2)>=11)==0);

disp('Number of events with unique or multiple shaking centers');
Num_peak_sample=SC_PGALand.Num_peak;

Num_peak_sample(sample==0)=[];
summarize(Num_peak_sample)

disp('Algorithm outcome');
out_sample=SC_PGALand.out;

out_sample(sample==0)=[];
summarize(out_sample)

disp('Look at events where no unique shaking center can be found by extending radius');
find((sample==1).*(SC_PGALand.out==-1)==1)
%imagesc(PGALand.id17891)
%colorbar
mean(maxarea_PGALand((sample==1).*(SC_PGALand.out==-1)==1))
Peak_PGALand((sample==1).*(SC_PGALand.out==-1)==1)
res_event((sample==1).*(SC_PGALand.out==-1)==1)

find((kick_them==0).*(SC_PGALand.out==1)==1)
%imagesc(PGALand.id23594)
%colorbar

display('DONE with Location_numbers!!!')
