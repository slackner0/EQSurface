cd "/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Raw/ComCat"
local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/ComCat/"

* Create Stata Data files
insheet using "withshakemap1960to2016allmag.csv", clear
gen shakemap=1
save "`path'withshakemap1960to2016allmag.dta", replace

insheet using "1960to2000over5point5.csv", clear
save "`path'1960to2000over5point5.dta", replace

insheet using "2001to2016over5point5.csv", clear
save "`path'2001to2016over5point5.dta", replace

insheet using "5point21_t_5point4999_1960to2016.csv", clear
save "`path'5point21_t_5point4999_1960to2016.dta", replace

insheet using "5point11_t_5point2099_1960to2016.csv", clear
save "`path'5point11_t_5point2099_1960to2016.dta", replace

insheet using "5point01_t_5point1099_1960to2016.csv", clear
save "`path'5point01_t_5point1099_1960to2016.dta", replace

insheet using "4point91_t_5point0099_1960to2016.csv", clear
save "`path'4point91_t_5point0099_1960to2016.dta", replace

insheet using "4point81_t_4point9099_1960to2016.csv", clear
save "`path'4point81_t_4point9099_1960to2016.dta", replace

insheet using "4point71_t_4point8099_1960to2000.csv", clear
save "`path'4point71_t_4point8099_1960to2000.dta", replace
insheet using "4point71_t_4point8099_2001to2016.csv", clear
save "`path'4point71_t_4point8099_2001to2016.dta", replace
insheet using "4point61_t_4point7099_2001to2016.csv", clear
save "`path'4point61_t_4point7099_2001to2016.dta", replace
insheet using "4point51_t_4point6099_2001to2016.csv", clear
save "`path'4point51_t_4point6099_2001to2016.dta", replace
insheet using "4point61_t_4point7099_1960to2000.csv", clear
save "`path'4point61_t_4point7099_1960to2000.dta", replace
insheet using "4point51_t_4point6099_1960to2000.csv", clear
save "`path'4point51_t_4point6099_1960to2000.dta", replace
insheet using "4point5_t_4point5099_1960to2004.csv", clear
save "`path'4point5_t_4point5099_1960to2004.dta", replace
insheet using "4point5_t_4point5099_2005to2016.csv", clear
save "`path'4point5_t_4point5099_2005to2016.dta", replace

*combine files
use "`path'2001to2016over5point5.dta", clear
append using "`path'1960to2000over5point5.dta",
append using "`path'5point21_t_5point4999_1960to2016.dta"
append using "`path'5point11_t_5point2099_1960to2016.dta"
append using "`path'5point01_t_5point1099_1960to2016.dta"
append using "`path'4point91_t_5point0099_1960to2016.dta"
append using "`path'4point81_t_4point9099_1960to2016.dta"

append using "`path'4point71_t_4point8099_1960to2000.dta"
append using "`path'4point71_t_4point8099_2001to2016.dta"
append using "`path'4point61_t_4point7099_2001to2016.dta"
append using "`path'4point51_t_4point6099_2001to2016.dta"
append using "`path'4point61_t_4point7099_1960to2000.dta"
append using "`path'4point51_t_4point6099_1960to2000.dta"
append using "`path'4point5_t_4point5099_1960to2004.dta"
append using "`path'4point5_t_4point5099_2005to2016.dta"

merge 1:1 time latitude longitude mag depth id using "`path'withshakemap1960to2016allmag.dta"

*codebook time
gen year=substr(time,1,4)
gen month=substr(time,6,2)
gen day=substr(time,9,2)
gen hour=substr(time,12,2)
gen minute=substr(time,15,2)
gen second=substr(time,18,6)

destring year, replace
destring month, replace
destring day, replace
destring hour, replace
destring minute, replace
destring second, replace

drop _merge
replace shakemap=0 if shakemap==.

drop if year==2016 & month>10

*codebook time id
duplicates tag time, gen(tagtime)
*br if tagtime>0

*Identified duplicates
drop if id=="gcmtc021694d" | id=="nc72307731" | id=="ci9966449" | id=="gcmtb041799a" | id=="at00o7cs70" | id=="nc21207275"


* Figure out duplicate ids
gen gcmt=1 if locationsource=="gcmt"
sort year month day hour minute second
bysort year month day hour minute: egen hasgcmt=max(gcmt)
bysort year month day hour minute: gen number=_N
bysort year month day hour minute: gen distance2=sqrt((lat[2]-lat[1])^2+(lon[2]-lon[1])^2) if _n==2
bysort year month day hour minute: gen seconddiff2=abs(second[2]-second[1])  if _n==2
bysort year month day hour minute: egen distance=max(distance2)
bysort year month day hour minute: egen seconddiff=max(seconddiff2)

*codebook number
*codebook distance if number==2
*br id time mag latitude longitude status shakemap if hasgcmt==1 & seconddiff<=1.5 & number==2 & distance<3

drop if seconddiff<=1 & number==2 & distance<3 & gcmt==1
drop secondd* distance* gcmt hasgcmt number

gen latr=round(lat,0.25)
gen lonr=round(lon,1)
gen depthr=round(depth, 25)
gen magr=round(mag,0.1)

duplicates tag year month day hour minute latr lonr depthr magr, gen(tagtimeloc)
*codebook tagtimeloc
*br if tagtimeloc>0

bysort year month day hour minute latr lonr depthr magr: gen vardup=_n

*To make them unique adjust depthr
replace depthr=-1 if vardup==1 & tagtimeloc==1
replace depthr=-2 if vardup==2 & tagtimeloc==1
drop vardup tagtime*

gen eqid=_n

*br if year==2015 & month==11 & day==24

save "`path'earthquakelist_withshakemap_orover4point5.dta", replace
outsheet using "`path'earthquakelist_withshakemap_orover4point5.csv", comma replace
count
