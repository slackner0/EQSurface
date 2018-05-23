clear
clear matrix
local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/"
set more off

use "`path'Data/Built/ShakeMapInfo.dta", clear

merge 1:1 id using "`path'Data/Built/PGA.dta", nogen
merge 1:1 id using "`path'Data/Built/epicenter.dta", nogen

drop if year>=2016 & month>=11


gen mag_cat="4.5" if magnitude<4.5
replace mag_cat="4.5-5.5" if magnitude>=4.5 &magnitude<5.5
replace mag_cat="5.5-6" if magnitude>=5.5 &magnitude<6
replace mag_cat="6-6.5" if magnitude>=6 &magnitude<6.5
replace mag_cat="6.5-7" if magnitude>=6.5 &magnitude<7
replace mag_cat="7-7.5" if magnitude>=7 &magnitude<7.5
replace mag_cat="7.5-8" if magnitude>=7.5 &magnitude<8
replace mag_cat="8" if magnitude>=8

replace peak_pga=0 if peak_pga==.
gen pga="0"
replace pga="0-10" if peak_pga>0 & peak_pga<=10
replace pga="10-20" if peak_pga>10 & peak_pga<=20
replace pga="20-40" if peak_pga>20 & peak_pga<=40
replace pga="40-80" if peak_pga>40 & peak_pga<=80
replace pga=">80" if peak_pga>80

replace area_above1000pga=area_above1000pga/100



tabout mag_cat pga using "`path'Output/Tables/tab03.txt" if peak_pga>10, replace c(mean area_above1000pga) f(0) style(tex) sum

tabout mag_cat pga using "`path'Output/Tables/tab04.txt", replace c(N peak_pga) f(0) style(tex) sum

keep if peak_pga>0

tabout mag_cat pga using "`path'Output/Tables/tab02.txt", replace c(mean area_with09percentpeakpga) f(0) style(tex) sum
