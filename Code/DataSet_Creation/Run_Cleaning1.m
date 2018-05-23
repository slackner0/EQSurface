%Step1a - Raw data import
%Runs ~10 Hours.
clear
tic
Step1a_RawDataImport
toc

%Step1b - Make land grids
%Runs ~20 minutes.
clear
tic
Step1b_MakeLandGrids
toc

%Step1c - Make land shake maps
%Runs ~15 minutes.
clear
tic
Step1c_MakeLandShakeMaps
toc

%Step1d - Export Shakemaps to Stata
%Runs ~10 minutes.
clear
tic
Step1d_Create_ShakeMapList
toc
