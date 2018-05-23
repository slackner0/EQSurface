set more off
local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/"

insheet using "`path'TempEQListFiles/ShakeMap_List.csv", clear

gen smarea=smncols*smxdim*smnrows*smydim
drop if smyear==2016 & smmonth>10
sort smminute
*br if smyear==2010 & smmonth==4 & smday==4 & smhour==22

drop if kick_out==1

* DROP because no such event in earthquake list
drop if smind==12223
*Manually confirmed duplicate
drop if smind==10103 | smind==10058 | smind==24726 |smind==11674 | smind==1431
drop if smind==15060 | smind==15231 | smind==13159 | smind==12425 | smind==12474
drop if smind==248 | smind==249 | smind==250 | smind==17719 | smind==17717 | smind==1887
drop if smind==1947 | smind==9819 | smind==10743 | smind==15424 | smind==16874 | smind==2109
drop if smind==1878 | smind==2593 | smind==2592 | smind==2594 | smind==13692 | smind==11705
drop if smind==2113 | smind==2124 | smind==2125 | smind==2141 | smind==15351 | smind==2399
drop if smind==2634 | smind==2635 | smind==21482 | smind==17902 | smind==10026 | smind==10177
drop if smind==81 | smind==13023 | smind==1365 |smind==11557 | smind==3124 | smind==1420

foreach smindval in 22272 11081 20269 19517 11839 2522 11289 15233 15305 15314 15419 15455 13895 12715 13899 15497 1842 1894 3274 1978 15849 17201 12448 2523 17202 {
drop if smind==`smindval'
}

* has mag belo 4.5 in earthquake list
drop if smind==12641 | smind==13501 | smind==107 | smind==16639 | smind==14230 | smind==12317 | smind==15959
*doesnt exist in eq list
drop if smind==16136 | smind==13485 | smind==13504 | smind==13508 | smind==13518 | smind==13533
drop if smind==13548 | smind==13550 | smind==13562 | smind==13570 | smind==13571
drop if smind==21460
*can not be clearly assigned
drop if smind==16173 | smind==13540 | smind==13541 | smind==11828 | smind==11829
*************************************
* 1) UNIQUE ID
**************************************
*codebook smid

*drop if smpeakpga==0


*table smcode_version, c(mean smtimestamp)
gen smcode=substr(smcode_version,5,4)
destring smcode, replace force
*table smcode
replace smcode=1 if smcode_version=="3.1" | smcode_version=="3.1 beta" | smcode_version=="3.1 GSM beta" | smcode_version=="3.1.1 GSM"
replace smcode=2 if smcode_version=="3.2" | smcode_version=="3.2.1 GSM"
replace smcode=. if smcode_version=="3.5" | smcode_version=="3.5.unknown revision" | smcode_version=="3.5."
*table smcode
*codebook smcode

*1.1) kick out  shakemaps before 1960
drop if smyear<1960
*codebook smid


*1.2) kick out duplicate files
sort smid smversion smtimestamp smind
bysort smid smversion smtimestamp: gen uniqueFile=_n
keep if uniqueFile==1
*codebook smid

*1.3) Same ID by version number and timestamp
gsort +smid +smyear +smmonth +smday -smversion -smtimestamp
bysort smid smyear smmonth smday: gen order_by_version=_n
gsort +smid +smyear +smmonth +smday -smtimestamp -smversion
bysort smid smyear smmonth smday: gen order_by_timestamp=_n
drop if order_by_version>1 & order_by_timestamp>1
*codebook smid

*1.4) Same ID Solve duplicate id weirdos of version 1.1
duplicates tag smid, gen(id_dup)
*codebook id_dup
*codebook smversion if id_dup==1
gsort +smid +smyear +smmonth +smday -smtimestamp
bysort smid smyear smmonth smday: gen diff_timestamp=smtimestamp[1]-smtimestamp[2] if _n==2
*codebook diff_timestamp if smversion>1.09 & smversion<1.11 & id_dup==1
drop if smversion>1.09 & smversion<1.11 & id_dup==1 & diff_timestamp>1000
*codebook smid

*1.5) Fix last two weirdos with same ID
cap drop id_dup
duplicates tag smid, gen(id_dup)
codebook id_dup

*br smregion smid smversion smtimestamp smcode_version if id_dup==1

drop if smid=="b000ilip" & smcode_version=="3.5.unknown revision"
drop if smid=="b000iv7t" & smcode_version=="3.5.unknown revision"
keep sm*

*************************************
* 2) Almost unique ID issue
*id yyyymmddhhmm vs yyyymmddhhmmss
**************************************

gen datestr1=string(smyear)+string(smmonth,"%02.0f")+string(smday,"%02.0f")+string(smhour,"%02.0f")+string(smminute,"%02.0f")
gen datestr2=string(smyear)+string(smmonth,"%02.0f")+string(smday,"%02.0f")+string(smhour,"%02.0f")+string(smminute,"%02.0f")+string(smsecond,"%02.0f")


gen isdate1=(datestr1==smid)
gen isdate2=(datestr2==smid)
gen idformat=0
replace idformat=1 if datestr2==smid
replace idformat=-1 if datestr1==smid

bysort datestr1: egen date1exists=sum(isdate1)
bysort datestr1: egen date2exists=sum(isdate2)
bysort datestr1: gen number=_N
*codebook number date*
*ta date1exists date2exists

*define lat lon of date1 observation
gen date1lat=.
gen date1lon=.
replace date1lat=smlat if isdate1==1
replace date1lon=smlon if isdate1==1

*assign that to entire category yyyymmddhhmm
bysort datestr1: egen date1latcat=max(date1lat)
bysort datestr1: egen date1loncat=max(date1lon)

*calculate difference to that lat/lon
gen dist_lat=abs(date1latcat-smlat) if isdate1~=1
gen dist_lon=abs(date1loncat-smlon) if isdate1~=1
*codebook dist_lat dist_lon if date1loncat~=.

*calculate minimum distance in category
bysort datestr1: egen dist_latcat=min(dist_lat)
bysort datestr1: egen dist_loncat=min(dist_lon)
*codebook dist_latcat dist_loncat if date1loncat~=.

*2.1) Drop if long and short exist and not further than 1 degree away
drop if isdate1==1 & dist_latcat<1 & dist_loncat<1

*codebook smid


**************************************************
*3) UNIQUE TIME and approximate location
**************************************************

*define location
gen latdegree=round(smlat,1)
gen londegree=round(smlon,1)
*codebook londegree
replace londegree=180 if londegree==-180
gen degreelocation=londegree*100+latdegree

*3.1) Manually identified duplicates with identical time and within 1degree
*Three of each are available, drop 2 oldest ones
drop if smid=="Northridge_zoom" || smid=="Northridge"
drop if smid=="2009llbc" || smid=="2009llb2"
drop if smid=="10168166" || smid=="2010zgap"
drop if smid=="c0002lpg" || smid=="040811m"
drop if smid=="082311a" || smid=="20110823175104"
drop if smid=="c0005zdn" || smid=="092211b"
drop if smid=="2012055_369378" || smid=="2012055_369384"
drop if smid=="102912a" || smid=="b000dgim"
drop if smid=="112012b" || smid=="c000dvxy"
drop if smid=="022814c" || smid=="c000mr27"
drop if smid=="00435746" || smid=="00437136"
drop if smid=="060614a" || smid=="c000rb2u"
drop if smid=="00469410" || smid=="uw60923777"
drop if smid=="uw60942017" || smid=="usc000t9b4"
drop if smid=="00475344" || smid=="usc000tbn8"
drop if smid=="usc000tbul" || smid=="00475453"
* Two of each
drop if smid=="197312012318"
drop if smid=="17219"
drop if smid=="2007czbv"
drop if smid=="25865"
drop if smid=="24501"
drop if smid=="2009qhbb"
drop if smid=="2010277_317915"
drop if smid=="2011nabh"
drop if smid=="2012fhbs"
drop if smid=="30664"
drop if smid=="00459506"
drop if smid=="14486031"
drop if smid=="c000swfq"
drop if smid=="nn00475559"
drop if smid=="usb000tq1c"
drop if smid=="00506293"

****
*codebook smtime
duplicates tag smyear smmonth smday smhour smminute smsecond degreelocation, gen(timeloc_dup)
*ta timeloc_dup

* 3.2) not in earthquake list and under magnitude 4.5
drop if timeloc_dup==11
drop if timeloc_dup==7

*3.3) Two at exact same time and same one degree, drop old if at least 300 days in between
gsort +smyear +smmonth +smday +smhour +smminute +smsecond +degreelocation -smtimestamp -smcode
bysort smyear smmonth smday smhour smminute smsecond degreelocation: gen diff_timestamp =smtimestamp[1]-smtimestamp[2] if _n==2
bysort smyear smmonth smday smhour smminute smsecond degreelocation: gen diff_code=smcode[1]-smcode[2] if _n==2
*codebook diff_time diff_code if timeloc_dup==1
drop if diff_timestamp>300 & diff_timestamp~=. & timeloc_dup==1 & diff_timestamp~=.

*3.4) Two at exact same time and same one degree, later and later code stays
drop if diff_timestamp>0 & diff_timestamp~=. & diff_code>0 & diff_code~=. & timeloc_dup==1


*3.5) At exact same time
duplicates tag smyear smmonth smday smhour smminute smsecond, gen(time_dup)
ta time_dup
gsort +smyear +smmonth +smday +smhour +smminute +smsecond -smtimestamp
*define distance for second location
bysort smyear smmonth smday smhour smminute smsecond: gen dist2=sqrt((smlat[1]-smlat[2])^2+(smlon[1]-smlon[2])^2) if _n==2 & time_dup==1
*assign distance to both locations
bysort smyear smmonth smday smhour smminute smsecond: egen dist=max(dist2) if time_dup==1
*codebook dist if time_dup==1
*all close to each other

*3.5a) as 3.3 without location
cap drop diff*
gsort +smyear +smmonth +smday +smhour +smminute +smsecond -smtimestamp -smcode
bysort smyear smmonth smday smhour smminute smsecond : gen diff_timestamp =smtimestamp[1]-smtimestamp[2] if _n==2
bysort smyear smmonth smday smhour smminute smsecond : gen diff_code=smcode[1]-smcode[2] if _n==2
drop if diff_timestamp>300 & diff_timestamp~=. & time_dup==1

*3.5b) by creation of timestamp
drop if diff_timestamp>0 & diff_timestamp~=.

cap drop time_dup
duplicates tag smyear smmonth smday smhour smminute smsecond, gen(time_dup)
ta time_dup

*3.5c) same timestamp, different code
drop if diff_timestamp==0 & diff_code>0 & diff_code~=. & time_dup==1
drop if diff_timestamp==. & diff_code>0 & diff_code~=. & time_dup==1

cap drop time_dup
duplicates tag smyear smmonth smday smhour smminute smsecond, gen(time_dup)
ta time_dup

keep sm*

***************************************************
* UNIQUE Details
***************************************************

*Manual identified as duplicates
drop if smid=="20080911002000" || smid=="20100304001851" || smid=="usc000tajk" || smid=="71086539"
drop if smid=="14607868" || smid=="14517900" || smid=="14616188" || smid=="14618300" || smid=="10585525"
drop if smid=="20060331011701" || smid=="kyae_06"


gen latr=round(smlat,0.25)
gen lonr=round(smlon,1)
gen depthr=round(smdepth, 25)
gen magr=round(smmagnitude,0.1)

duplicates tag smyear smmonth smday smhour smminute latr lonr depthr magr, gen(tagtimeloc)
*codebook tagtimeloc

gsort smyear smmonth smday smhour smminute latr lonr depthr magr -smtimestamp -smcode
bysort smyear smmonth smday smhour smminute latr lonr depthr magr: gen diff_timestamp =smtimestamp[1]-smtimestamp[2] if _n==2
bysort smyear smmonth smday smhour smminute latr lonr depthr magr: gen diff_code=smcode[1]-smcode[2] if _n==2
*codebook diff_timestamp if tagtimeloc==1
drop if diff_timestamp>0 & diff_timestamp~=.

cap drop tagtimeloc
duplicates tag smyear smmonth smday smhour smminute latr lonr depthr magr, gen(tagtimeloc)
*codebook tagtimeloc

*br if tagtimeloc==1

rename smyear year
rename smmonth month
rename smday day
rename smhour hour
rename smminute minute

save "`path'TempEQListFiles/TempListOfShakemaps.dta", replace

merge 1:1 year month day hour minute latr lonr depthr magr using "`path'ComCat/earthquakelist_withshakemap_orover4point5.dta"

ta smcode_version _merge

preserve
keep if _merge==3
keep smind eqid
count
save "`path'TempEQListFiles/ShakeMap_AND_EARTHQUAKE_List_MATCH.dta", replace
outsheet using "`path'TempEQListFiles/ShakeMap_AND_EARTHQUAKE_List_MATCH.csv", comma replace
restore

preserve
keep if _merge==1
keep smind
save "`path'TempEQListFiles/ShakeMaps_NOT_MATCHED.dta", replace
outsheet using "`path'TempEQListFiles/ShakeMaps_NOT_MATCHED.csv", comma replace
count
restore

keep if _merge==2
drop sm* _merge diff_timestamp	diff_code tagtimeloc
save "`path'TempEQListFiles/EARTHQUAKE_List_NOT_MATCHED.dta", replace
outsheet using "`path'TempEQListFiles/EARTHQUAKE_List_NOT_MATCHED.csv", comma replace
count
