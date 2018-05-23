%Step4a - Determine grid cell country
%Runs ~14 minutes.
clear
tic
Step4a_DetermineGridcellCountry
toc

%Step4b - Create Event Shaking Data
%Runs ~29 minutes.
clear
tic
Step4b_CreateEventShakingData
toc


%Step4c - Create World shaking history
%Runs ~59 minutes.
clear
tic
Step4c_create_world_shakinghistory
toc


%Step4d - Event PGA to Stata
%Runs ~2 minutes.
clear
tic
Step4d_EventPGAtoStata
toc
