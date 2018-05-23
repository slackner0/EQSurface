set more off
local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/"

*get smind <-> eq list indicator match
insheet using "`path'Built/TempEQListFiles/SM_EQ.csv", clear

*add smind indicator to eq list
merge 1:1 eqid using "`path'Built/ComCat/earthquakelist_withshakemap_orover4point5.dta"
drop _merge latr lonr depthr magr

ds

foreach var in `r(varlist)' {
	rename `var' eql`var'
}

rename eqleqid eqid
rename eqlsmind smind

*save combined file
save "`path'Built/TempEQListFiles/EQlist_with_smind.dta", replace


*Get and save impact data
insheet using "`path'Raw/NOAA/NOAA_Raw_CSV.csv", clear
gen id=_n
destring second, replace
rename total_houses_destroyed_descripti total_houses_destoryed_des
rename total_houses_damaged_description total_houses_damaged_des

ds
foreach var in `r(varlist)' {
	rename `var' imp`var'
}

save "`path'Built/TempEQListFiles/Impactraw.dta", replace


*Get eqid <-> impact inicator match and save it
insheet using "`path'Built/TempEQListFiles/IMP_EQ.csv", clear
save "`path'Built/TempEQListFiles/IMP_EQ.dta", replace
*Get sm <-> impact inicator match and save it
insheet using "`path'Built/TempEQListFiles/IMP_SM.csv", clear
save "`path'Built/TempEQListFiles/IMP_SM.dta", replace

*Get raw shakemap data and save as stata
insheet using "`path'Built/TempEQListFiles/ShakeMap_List.csv", clear
save "`path'Built/TempEQListFiles/RawSM.dta", replace

*Combine Impact with all its indicators
use "`path'Built/TempEQListFiles/Impactraw.dta", clear

merge 1:1 impi_d using "`path'Built/TempEQListFiles/IMP_SM.dta", nogen
merge 1:1 impi_d using "`path'Built/TempEQListFiles/IMP_EQ.dta", nogen

replace eqid=-_n if eqid==.

codebook smind eqid

merge 1:1 eqid using "`path'Built/TempEQListFiles/EQlist_with_smind.dta", update
drop _merge
replace eqid=. if eqid<0
count if smind~=.

replace smind=-_n if smind==.

merge 1:1 smind using "`path'Built/TempEQListFiles/RawSM.dta"
drop if _merge==2
drop _merge

replace smind=. if smind<0
drop kick_out

gen magnitude=smmagnitude
replace magnitude=eqlmag if magnitude==.
replace magnitude=impeq_primary if magnitude==.
drop if magnitude==.

foreach var in year month day hour minute second lat lon{
gen `var'=sm`var'
replace `var'=eql`var' if `var'==.
replace `var'=imp`var' if `var'==.
}

*gen lat=smlat
*replace lat=eqlat if lat==.
*replace lat=imp`var' if lat==.

save "`path'Built/ThreeEQSets_combined.dta", replace
