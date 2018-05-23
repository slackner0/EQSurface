set more off
local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/"

use "`path'Data/Built/ThreeEQSets_combined.dta", clear
gen mag1D=round(magnitude,0.1)
label var mag1D "Magnitude"
label var year "Year"
drop if year>=2016 & month>=11
drop if mag1D<2

gen smeq=1 if smind~=.
replace smeq=0 if smeq==.

gen death=1 if impdeaths>0 & impdeaths~=.
*hist impdeaths if death==1 & smeq~=1, frequency
set scheme s1color
preserve
* NORTH AMERICA VS NOT NORTH AMERICA RATIO OF SHAKEMAPS
drop if smeq==.
drop if year<1973
gen NorthAmerica=0
replace NorthAmerica=1 if lat<=70 & lat>=25 & lon<=-60 & lon>=-170

ta NorthAmerica

gen mag_ref=.
gen ratioNNA=.
gen ratioNA=.
label var ratioNNA "Not North America"
label var ratioNA "North America"
label var mag_ref "Magnitude"

local k=1
forval i=4.5(0.1)9 {
	replace mag_ref=`i' in `k'
	disp `i'
	count if NorthAmerica==0 & mag1D>=`i'-0.01 & mag1D<=`i'+0.01
	local numNNA=`r(N)'
	count if NorthAmerica==1 & mag1D>=`i'-0.01 & mag1D<=`i'+0.01
	local numNA=`r(N)'
	count if NorthAmerica==0 & mag1D>=`i'-0.01 & mag1D<=`i'+0.01 & smeq==1
	local numNNA_sm=`r(N)'
	count if NorthAmerica==1 & mag1D>=`i'-0.01 & mag1D<=`i'+0.01 & smeq==1
	local numNA_sm=`r(N)'

	replace ratioNNA=`numNNA_sm'/`numNNA' in `k'
	replace ratioNA=`numNA_sm'/`numNA' in `k'
	local k=`k'+1
}
*br mag_ref ratio*
drop if mag_ref==.
twoway (scatter ratioNA mag_ref, msymbol(d) color(red) xlabel(4(0.5)9)) ///
       (scatter ratioNNA mag_ref, msymbol(d) color(navy) xlabel(4(0.5)9)), title("(a)") ytitle("Share of events with ShakeMap") legend(off)
graph export "`path'Output/Figures/RatioShakeMaps.png", replace
twoway (scatter ratioNA mag_ref, msymbol(d) color(red) xlabel(4(0.5)9)) ///
       (scatter ratioNNA mag_ref, msymbol(d) color(navy) xlabel(4(0.5)9)), ytitle("Share of events with ShakeMap")
graph export "`path'Output/Figures/RatioShakeMapsLegend.png", replace

restore

preserve
* NORTH AMERICA VS NOT NORTH AMERICA IN SHAKEMAPS
keep if smeq==1
gen NorthAmerica=0
replace NorthAmerica=1 if lat<=70 & lat>=25 & lon<=-60 & lon>=-170

gen mag_ref=.
gen ratioNNA=.
gen ratioNA=.
label var ratioNA "Share of North American ShakeMaps"
label var mag_ref "Magnitude"

local k=1
forval i=0(0.1)9.5 {
	replace mag_ref=`i' in `k'
	disp `i'
	count if mag1D>=`i'-0.01 & mag1D<=`i'+0.01
	local num_all=`r(N)'
	count if NorthAmerica==1 & mag1D>=`i'-0.01 & mag1D<=`i'+0.01
	local numNA=`r(N)'

	replace ratioNA=`numNA'/`num_all' in `k'
	local k=`k'+1
}
*br mag_ref ratio*
drop if mag_ref==.
drop if mag_ref<2
twoway (scatter ratioNA mag_ref, msymbol(d) xscale(range(2 9)) xlabel(2(0.5)9.5) title("(b)"))
graph export "`path'Output/Figures/NorthAmericaShare.png", replace
restore


preserve
*EARTHQUAKES OVER MAGNITUDE
drop if mag1D<5.5 & smind==.
drop if year<1973
twoway (hist mag1D if smeq~=., frequency width(0.1) start(1.95) xscale(range(1.9 9)) xlabel(2(0.5)9)) ///
       (hist mag1D if smeq==1, frequency width(0.1) start(1.95) xscale(range(1.9 9)) xlabel(2(0.5)9) lcolor(teal) fcolor(emerald)) ///
	   (hist mag1D if smeq==1 & death==1, frequency width(0.1) xscale(range(1.9 9)) xlabel(2(0.5)9) start(1.95) color(maroon)), ytitle("Number of Earthquakes") legend(order(1 "with Magnitude >= 5.5" 2 "with ShakeMap" 3 "with ShakeMap and Fatalities") )
graph export "`path'Output/Figures/Figure10.pdf", replace
restore

preserve
* EARTHQUAKES OVER YEARS
drop if mag1D<4.5
drop if mag1D>=5.5
drop if year>2015
twoway (hist year if smeq~=., frequency width(1) start(1959.5) xscale(range(1960 2015)) xlabel(1960(5)2015) ) ///
       (hist year if smeq==1, frequency width(1) start(1959.5) xscale(range(1960 2015)) xlabel(1960(5)2015) lcolor(teal) fcolor(emerald)) ///
	   (hist year if smeq==1 & death==1, frequency width(1) start(1959.5) xscale(range(1960 2015)) xlabel(1960(5)2015) color(maroon)), ytitle("Number of Earthquakes with 4.5 <= Mag < 5.5") legend(order(1 "All Earthquakes" 2 "with ShakeMap" 3 "with ShakeMap and Fatalities")) title("(b)")
graph export "`path'Output/Figures/Year3DataSets45.png", replace

restore
drop if mag1D<5.5
drop if year>2015
twoway (hist year if smeq~=., frequency width(1) start(1959.5) xscale(range(1960 2015)) xlabel(1960(5)2015) ) ///
       (hist year if smeq==1, frequency width(1) start(1959.5) xscale(range(1960 2015)) xlabel(1960(5)2015) lcolor(teal) fcolor(emerald)) ///
	   (hist year if smeq==1 & death==1, frequency width(1) start(1959.5) xscale(range(1960 2015)) xlabel(1960(5)2015) color(maroon)), ytitle("Number of Earthquakes with Mag >= 5.5") legend(order(1 "All Earthquakes" 2 "with ShakeMap" 3 "with ShakeMap and Fatalities")) title("(a)")
graph export "`path'Output/Figures/Year3DataSets.png", replace
