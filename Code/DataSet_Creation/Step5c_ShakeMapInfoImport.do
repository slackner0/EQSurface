local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/"

set more off

insheet using "`path'ShakeMapInfo.csv", clear
keep if kick_them==0
drop kick_them

gen magnitude_1D=round(magnitude,0.1)
gen mag10=10^magnitude

label var mag10 "10^Magnitude"
label var magnitude "Magnitude"
label var magnitude_1D "Magnitude"
label var year "Year"
label var month "Month"

save "`path'ShakeMapInfo.dta", replace
