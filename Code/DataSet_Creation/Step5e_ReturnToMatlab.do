
local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/"

use "`path'ThreeEQSets_combined.dta", clear

rename smid id

replace id=string(-_n) if id==""

codebook id

merge 1:1 id using "`path'PGA.dta", nogen

drop if year>=2016 & month>=11
drop if eqid==. & smind==.

keep smind year lat lon magnitude area_with09percentpeakpga area_with05percentpeakpga

outsheet using "`path'ForWorldMap.csv", comma replace
