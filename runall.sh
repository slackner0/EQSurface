###########################
# Data Cleaning
###########################

cd "/Users/slackner/Google Drive/Research/Publications/EQSurface/Code/DataSet_Creation"

#runs ~11 hours
matlab -nosplash -nodisplay -nodesktop -r "run Run_Cleaning1.m; quit" > matoutfile_clean1

#runs ~2 min
StataMP -b do Run_Cleaning2.do

#runs ~5 min
matlab -nosplash -nodisplay -nodesktop -r "run Run_Cleaning3.m; quit" > matoutfile_clean3

#runs ~104 min
matlab -nosplash -nodisplay -nodesktop -r "run Run_Cleaning4.m; quit" > matoutfile_clean4

#runs ~5 min
StataMP -b do Run_Cleaning5.do

###########################
# Data Analysis
###########################

cd "/Users/slackner/Google Drive/Research/Publications/EQSurface/Code/DataAnalysis"

#runs ~28 min
#Without -nodisplay
#Otherwise image resolution is lowered. See some information about this here: https://www.mathworks.com/matlabcentral/answers/64408-use-of-parallel-computing-function-lowers-quality-of-saved-image?s_tid=answers_rc1-3_p3_Topic
matlab  -nosplash -nodesktop -r "run Analysis1.m; quit" > matoutfile_analysis1

#runs ~4 min
StataMP -b do Analysis2.do

###########################
# Creating Panel Figures
###########################
cd "/Users/slackner/Google Drive/Research/Publications/EQSurface/Output/Figures/"
convert -density 300 EQHistory.pdf EQHistory.png
convert -density 300 EQNum.pdf EQNum.png
convert -append EQHistory.png EQNum.png Figure01.png
#Alternative approach, but file size is much larger
#montage -density 300 EQHistory.pdf EQNum.pdf -tile 1x2 -geometry +0+0 Figure01.pdf

convert -density 300 History_GSHAP.pdf History_GSHAP.png
convert -density 300 EQMax.pdf EQMax.png
convert -density 300 GSHAP.pdf GSHAP.png
convert +append EQMax.png GSHAP.png Figure12temp.png
#Alternative approach, but file size is much larger
#montage -density 300 EQMax.pdf GSHAP.pdf -tile 2x1 -geometry +0+0 Figure12temp.pdf
convert -append -gravity center Figure12temp.png History_GSHAP.png Figure12.png

convert +append Year3DataSets.png Year3DataSets45.png Figure09.png

convert -crop 1424x1036+0+900 RatioShakeMapsLegend.png RatioShakeMapsLegendcrop.png
convert  RatioShakeMaps.png NorthAmericaShare.png +append RatioShakeMapsLegendcrop.png -append Figure11.png

###########################
# Renaming some Figures
###########################
cd "/Users/slackner/Google Drive/Research/Publications/EQSurface/Output/Figures/"
mv meanarea_90percent45_1point25.pdf Figure05.pdf
mv worldnumABOVE4point5_1point25.pdf Figure07.pdf
mv only6_1point25.pdf Figure08.pdf
