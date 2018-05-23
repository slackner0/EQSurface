clear matrix
set more off
local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/"

use "`path'Data/Built/ShakeMapInfo.dta", clear

merge 1:1 id using "`path'Data/Built/PGA.dta", nogen
merge 1:1 id using "`path'Data/Built/epicenter.dta", nogen

drop if year>=2016 & month>=11

*i=32 in Matlab is an example of epicenter not in shakemap, confirmed with data

*replace ec_pga=0 if ec_pga==-1
gen ecinwater=1
replace ecinwater=0 if ec_pga>0 & ec_pga~=.
ta ecinwater if magnitude>=4.5

drop if dist_ec_sc_pga==. | magnitude<4.5
ta ecinwater if magnitude>=4.5

gen sameecsc=0
replace sameecsc=1 if ec_pga==sc_pga & ec_pga>0 & ec_pga~=.
gen sameecsct=0
replace sameecsct=1 if ec_pga==sct_pga & ec_pga>0 & ec_pga~=.

gen samescsct=0
replace samescsct=1 if sc_pga==sct_pga & sct_pga>0 & sct_pga~=.

replace dist_ec_sc_pga=0 if sameecsc==1
replace dist_ec_sct_pga=0 if sameecsct==1
replace dist_sc_sct_pga=0 if samescsct==1

tabout ecinwater using "`path'Output/Tables/tab01.txt", replace bt c(mean dist_ec_sc_pga sd dist_ec_sc_pga max dist_ec_sc_pga mean dist_ec_sct_pga sd dist_ec_sct_pga max dist_ec_sct_pga mean dist_sc_sct_pga sd dist_sc_sct_pga max dist_sc_sct_pga) f(0) npos(tufte) style(tex) sum

gen ldist=log10(dist_ec_sc_pga+0.1)
label var ldist "km"

set scheme s1color
twoway (histogram ldist if ecinwater==0 & magnitude>=4.5, frequency width(0.2) start(-1.1) lcolor(brown) xtick(-1 0 1 2 3) xlabel(-1 "0" 0 "1" 1 "10" 2 "100" 3 "1000") ) ///
       (histogram ldist if ecinwater==1 & magnitude>=4.5, frequency width(0.2) start(-1.1) fcolor(none) lcolor(blue)), legend(order(1 "Epicenter on land" 2 "Epicenter in water" )) title("Distribution of distance between SC and EC")
graph export "`path'Output/Figures/Figure04.pdf", replace


count if magnitude>=4.5 & ec_pga>0 &  ec_pga~=.

cap drop relPGA_EC_SC
gen relPGA_EC_SC=(sc_pga-ec_pga)/sc_pga

sum relPGA_EC_SC if ecinwater==0

ta sameecsc
