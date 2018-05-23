addpath('/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine/matlab_shakemaptools')

sm_i=25008;
outpath='/Users/slackner/Google Drive/Research/Publications/EQSurface/Output/Figures/';
name='Figure03';
zoom=[150 490 180 490];
legpos=[0.53 0.77 0.19 0.12];


shakeplot(sm_i, outpath, 'fname', name, 'posleg', legpos, 'zoom', zoom);
close(gcf)

display('DONE with ShakeMap_Example!!!')
