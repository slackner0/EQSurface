%Step3a - Match unmatched ShakeMaps and EQlist
%Runs ~1 minute.
clear
tic
Step3a_MATCH_UNMATCHED_SHAKEMAP_AND_EARTHQUAKES
toc

%Step3b - CreateMatching file for SM/EQ
%Runs ~? minutes.
clear
tic
Step3b_Final_SM_EQ_Match
toc

%Step3c - MatchNOAA impact events with USGS EQlist
%Runs ~? minutes.
clear
tic
Step3c_FindMatchesImpwithEQlist
toc

%Step3d - Match remaining NOAA impact events with unmatched shakemaps
%Runs ~? minutes.
clear
tic
Step3d_FindMatchesImpwithSM_forunmatchedWithEQlist
toc


%Step3e - Create Shakemap level impact output and kick_them data
%Runs ~? minutes.
clear
tic
Step3e_AssignImpacts_CreateKickThem
toc
