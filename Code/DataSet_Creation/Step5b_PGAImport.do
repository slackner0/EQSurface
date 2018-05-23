set more off
local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/"


insheet using "`path'ShakeMapPGA.csv", clear name

keep if kick_them==0
drop kick_them
drop ec_tod_pga ec_ylat_pga ec_xlon_pga ec_country_pga

rename ec_value_pga ec_pga
rename sc_value_pga sc_pga
rename sctroid_value_pga sct_pga
rename sctroid_tod_pga sct_tod_pga
rename sctroid_country_pga sct_country_pga
rename sctroid_xlon_pga sct_xlon_pga
rename sctroid_ylat_pga sct_ylat_pga
rename dist_ec_sctroid_pga dist_ec_sct_pga
rename dist_sc_sctroid_pga dist_sc_sct_pga

label var peak_pga "Maximum PGA in %g"
label var ec_pga "PGA at epicenter"
label var sc_pga "PGA at shaking center"
label var sct_pga "PGA at shaking centroid"
label var sc_tod_pga "Time of Day at PGA shaking center"
label var sct_tod_pga "Time of Day at PGA shaking centroid"
label var sc_country_pga "Country of PGA shaking center"
label var sct_country_pga "Country of PGA shaking centroid"
label var dist_ec_sc_pga "Distance between epicenter and shaking center in km"
label var dist_ec_sct_pga "Distance between epicenter and shaking centroid in km"
label var dist_sc_sct_pga "Distance between shaking center and shaking centroid in km"

save "`path'PGA.dta", replace
