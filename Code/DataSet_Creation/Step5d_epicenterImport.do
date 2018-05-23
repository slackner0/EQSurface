local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/"

set more off

insheet using "`path'ShakeMapPGA.csv", clear name

keep if kick_them==0
drop kick_them

* Create Epicenter dataset
keep id ec_tod_pga ec_ylat_pga ec_xlon_pga ec_country_pga

rename ec_tod_pga ec_tod
rename ec_ylat_pga ec_ylat
rename ec_xlon_pga ec_xlon

label var ec_tod "Time of Day at Epicenter"
label var ec_ylat "Epicenter Latitude"
label var ec_xlon "Epicenter Longitude"
label var ec_country "Epicenter Country"

save "`path'epicenter.dta", replace
