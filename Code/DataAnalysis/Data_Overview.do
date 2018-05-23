local path "/Users/slackner/Google Drive/Research/Publications/EQSurface/Data/Built/"

use "`path'ThreeEQSets_combined.dta", clear

*eqlshakemap is 1 when a shakemap is supposed to exist according to ComCat. It is zerro if a ShakeMap could be found even though ComCat doesn't indicate that it has one. And -1 if there is no ShakeMap for that event.
replace eqlshakemap=-1 if eqlshakemap==.
gen shakemapyes=(smind~=.)

ta shakemapyes eqlshakemap if year<2016 | month<11

codebook magnitude if shakemapyes==1 & eqlshakemap==1 & (year<2016 | month<11)
codebook magnitude if shakemapyes==1 & eqlshakemap==0 & (year<2016 | month<11)

codebook magnitude if shakemapyes==0 & eqlshakemap==1 & (year<2016 | month<11)
count if magnitude<4.5 & shakemapyes==0 & eqlshakemap==1 & (year<2016 | month<11)

***********************************************
codebook impi_d if (year<2016 | month<11)

count if shakemapyes==1 & (year<2016 | month<11)
count if shakemapyes==1 & eqlshakemap==-1 & impi_d~=. & (year<2016 | month<11)
count if shakemapyes==1 & eqlshakemap~=-1 & impi_d~=. & (year<2016 | month<11)
count if shakemapyes==1 & eqlshakemap~=-1 & impi_d==. & (year<2016 | month<11)

count if magnitude>=4.5 & shakemapyes==1 & (year<2016 | month<11)

ta shakemapyes eqlshakemap if (year<2016 | month<11) & impi_d==.
ta shakemapyes eqlshakemap if (year<2016 | month<11) & impi_d~=.

codebook magnitude impdeaths if eqlshakemap==-1 & impi_d~=. & (year<2016 | month<11)
count if magnitude<=5.5 & eqlshakemap==-1 & impi_d~=. & (year<2016 | month<11)

codebook impdeaths if shakemapyes==0 & eqlshakemap==-1 & impi_d~=. & (year<2016 | month<11)
*scatter year impdeaths if shakemapyes==0 & eqlshakemap==-1 & impi_d~=. & (year<2016 | month<11)

codebook magnitude if shakemapyes==1 & eqlshakemap==-1 & impi_d~=. & (year<2016 | month<11)

sort magnitude
*br magnitude impintensity impcountry impstate implocation_name impregion_code impdeaths impdamage_millions_dollars if  year>1972 & magnitude>5.5 & shakemapyes==0 & eqlshakemap~=-1 & impi_d~=. & (year<2016 | month<11)

count if magnitude>=4.5 & year>1972 & shakemapyes==0 & eqlshakemap~=-1 & impi_d~=. & (year<2016 | month<11)

codebook impintensity if year>1972 & shakemapyes==0 & eqlshakemap~=-1 & impi_d~=. & (year<2016 | month<11)


sort magnitude
gen eql=(eqlshakemap>-1)
bysort shakemapyes eql: summarize impdeaths if  year<1970 & (year<2016 | month<11)

*hist impdeaths if  year<1970 & (year<2016 | month<11) & shakemapyes==1 & eql==1

count if eql==1 & shakemapyes==0 & impdeaths>0 & impdeaths~=.
count if eql==1 & shakemapyes==0 & impdeaths>0 & impdeaths~=. & year<=1972

sum impdeaths if eql==1 & shakemapyes==0 & impdeaths>0 & impdeaths~=. & year>1972

count if eql==1 & shakemapyes==0 & year<=1972 & impi_d~=.
count if eql==1 & shakemapyes==0 & year>1972 & impi_d~=. & magnitude>=5.5
count if shakemapyes==1 & magnitude>=5.5 & (year<2016 | month<11)

*scatter impdeaths year if shakemapyes==0 & eqlshakemap~=-1 & impi_d~=. & (year<2016 | month<11)

*br imp* year month day smregion if impi_d~=. & (year<2016 | month<11) & eqlshakemap==1 & shakemapyes==0
