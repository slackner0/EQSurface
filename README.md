# Earthquakes on the surface: earthquake location and area based on more than 14500 ShakeMaps
Code and data details for my paper [Earthquakes on the surface: earthquake location and area based on more than 14500 ShakeMaps](https://www.nat-hazards-earth-syst-sci.net/18/1665/2018/nhess-18-1665-2018.html).

The paper as well as this repository are published under the [Creative Commons Attribution 4.0 License](https://creativecommons.org/licenses/by/4.0/). If you are using this repository for any purposes, please cite the paper. The suggested citation is:

Lackner, S.: Earthquakes on the surface: earthquake location and area based on more than 14 500 ShakeMaps, Nat. Hazards Earth Syst. Sci., 18, 1665-1679, https://doi.org/10.5194/nhess-18-1665-2018, 2018. 

## Raw Data
The raw data for this paper came from the following sources and is freely available. Since I do not own the data, I only provide links to the sources.
- **ShakeMaps** from the [USGS Website](https://earthquake.usgs.gov/data/shakemap/) were saved as individual `.xml` files in the folder `/EQSurface/Data/Raw/ShakeMaps_XML/`. More than 25000 individual ShakeMap XML files were downloaded, but only 14608 were included in the analysis after the cleaning stages (included in the code below).
- The **GPWv4** [land area data](http://sedac.ciesin.columbia.edu/data/set/gpw-v4-national-identifier-grid) [national identifier data](http://sedac.ciesin.columbia.edu/data/set/gpw-v4-land-water-area) was downloaded from the [CIESIN Website](http://sedac.ciesin.columbia.edu/data/collection/gpw-v4) and saved in the following directories: `/EQSurface/Data/Raw/gpw-v4-land-water-area-land/` and `/EQSurface/Data/Raw/gpw-v4-national-identifier-grid/`.
- The **ANSS Comprehensive Earthquake Catalog (ComCat)** was downloaded with the [search tool](https://earthquake.usgs.gov/earthquakes/search/) on the USGS Website. Since the number of events that can be outputed is limited, it was necessary to do 16 separate requests for raw data as csv files. These requests were for global earthquakes with the following magnitude an time period restrictons: (1) Mag 4.5-4.5099 for 1960-2004 (2) Mag 4.5-4.5099 for 2005-2016 (3) Mag 4.51-4.6099 for 1960-2000 (4) Mag 4.51-4.6099 for 2001-2016 (5) Mag 4.61-4.7099 for 1960-2000 (6) Mag 4.61-4.7099 for 2001-2016 (7) Mag 4.71-4.8099 for 1960-2000 (8) Mag 4.71-4.8099 for 2001-2016 (9) Mag 4.81-4.9099 for 1960-2016 (10) Mag 4.91-5.0099 for 1960-2016 (11) Mag 5.01-5.1099 for 1960-2016 (12) Mag 5.11-5.2099 for 1960-2016 (13) Mag 5.21-5.4999 for 1960-2016 (14) Mag >5.5 for 1960-2000 (15) Mag >5.5 for 2001-2016 (16) all earthquakes with ShakeMap for 1960-2016. The 16 CSV files were save under `/EQSurface/Data/Raw/ComCat/`.
[Screenshot of the file names.](/Documentation/ComCat_Screenshot.png)
- The **NGDC Significant Earthquake Database** was downloaded from the [NGDC website](https://www.ngdc.noaa.gov/hazard/earthqk.shtml) and saved under `/EQSurface/Data/Raw/NOAA/NOAA_Raw_CSV.csv`
- The **GSHAP** data was downloaded from the [GSHAP website](http://static.seismo.ethz.ch/GSHAP/global/) and saved under `/EQSurface/Data/Raw/GSHAP/GSHPUB.DAT`.

## Running Code (runall.sh)
`runall.sh` runs everything. Before running it the path to the project folder has to be changed in many files. The current path is `/Users/slackner/Google Drive/Research/Publications/EQSurface/`. Also the path to the Matlab packages has to be changed in many files (right now they are either `/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_mine` or `/Users/slackner/Google Drive/Research/General_Code/Matlab/Packages_from_Sources`). If you are using Atom as editor this can easily be done by using "Find in Project".

The entire code runs for about 14 hours on the system described below.

1. `Run_Cleaning1.m` (*runs ~11h min*)
  - Step1a - Raw data import (*runs ~10 hours*)
  - Step1b - Make land grids (*runs ~20 min*)
  - Step1c - Make land shake maps (*runs ~15 min*)
  - Step1d - Export Shakemaps to Stata (*runs ~10 min*)
2. `Run_Cleaning2.do` (*runs ~2 min*)
  - Step2a - Clean USGS Earthquake List (used to be named s0a) (*runs ~1 min*)
  - Step2b - Partially clean ShakeMap list, match with USGS EQ list and output remaining EQlist and Shakemaps (*runs ~1 min*)
3. `Run_Cleaning3.m` (*runs ~5 min*)
  - Step3a - Match unmatched ShakeMaps and EQlist (*runs ~1 min*)
  - Step3b - Create Matching file for SM/EQ (*runs ~1 min*)
  - Step3c - MatchNOAA impact events with USGS EQlist  (*runs ~1 min*)
  - Step3d - Match remaining NOAA impact events with unmatched shakemaps (*runs ~1 min*)
  - Step3e - Create Shakemap level impact output and kick_them data (*runs ~1 min*)
4. `Run_Cleaning4.m` (*runs ~104 min*)
  - Step4a - Determine grid cell country (*runs ~14 min*)
  - Step4b - Create Event Shaking Data (*runs ~29 min*)
  - Step4c - Create World shaking history (*runs ~59 min*)
  - Step4d - Event PGA to Stata (*runs ~2 min*)
5. `Run_Cleaning5.do` (*runs ~5 min*)
  - Step5a - Combine EQ Data Sets (*runs ~1 min*)
  - Step5b - PGA Import (*runs ~1 min*)
  - Step5c - ShakeMap Info Import (*runs ~1 min*)
  - Step5d - Epicenter Info Import (*runs ~1 min*)
  - Step5e - Return To Matlab (*runs ~1 min*)
6. `Analysis1.m` (*runs ~28 min*)
  - `ShakeMap_Example.m` (*runs ~2 min*)
  - `WorldShakingMap.m` (*runs ~12 min*)
  - `Location_numbers.m` (*runs 1 min*)
  - `WorldMap_EventsAndArea.m` (*runs ~12 min*)
  - `Areacomparison.m` (*runs ~1 min*)
7. `Analysis2.do` (*runs ~4 min*)
  - `Data_Overview.do` (*runs ~1 min*)
  - `Area_summary.do` (*runs ~1 min*)
  - `Center_Distance.do` (*runs ~1 min*)
  - `CompareEQ_data_Sets.do` (*runs ~1 min*)

### Flowcharts
Below are two flowcharts that illustrate the different files that are called and created by running the `runall.sh` file.

![Diagram](/Documentation/Flowchart_eqs17.png)

<a href="https://www.draw.io/?mode=github#Hslackner0%2FEQSurface%2Fmaster%2FDocumentation%2FFlowchart_eqs17.png">Edit</a>

![Diagram](/Documentation/Flowchart_eqs17_Analysis.png)

<a href="https://www.draw.io/?mode=github#Hslackner0%2FEQSurface%2Fmaster%2FDocumentation%2FFlowchart_eqs17_Analysis.png">Edit</a>

### Figure02 - Sketch of Fault
`Figure02.png` is not created by the `runall.sh` file, but it has been created by `Make_sketch_of_fault.m` (*runs ~1 min*) and it has been manually saved and changed.

## Requirements

### System
The code was run on the following system.

    Model Name:	MacBook Pro
    Model Identifier:	MacBookPro14,1
    Processor Name:	Intel Core i7
    Processor Speed:	2.5 GHz
    Number of Processors:	1
    Total Number of Cores:	2
    Memory:	16 GB

### Matlab
The code was run with Matlab 2017a. The following additional packages/libraries are required. They can be downloaded from the links. As already mentioned above the Matlab code needs to be updated to link to the location of these packages.
- [`cbrewer`](https://www.mathworks.com/matlabcentral/fileexchange/34087-cbrewer---colorbrewer-schemes-for-matlab)
- [`stata_translation`](http://www.fight-entropy.com/2010/05/data-transfer-from-matlab-to-stata-and.html) by Solomon Hsiang.
- [`matlab_libgrid`](https://github.com/slackner0/matlab_libgrid) is a collection of Matlab code that was shared with me by Mike Hearne. I have uploaded it to GitHub with his permission. (This is only used for importing the raw data.)
- [`matlab_shakemaptools`](https://github.com/slackner0/matlab_shakemaptools)
- [`matlab_scale`](https://github.com/slackner0/matlab_scale)
- [`matlab_importcsv`](https://github.com/slackner0/matlab_importcsv)
- [`matlab_logcolor`](https://github.com/slackner0/matlab_logcolor)
- [`matlab_scatterheat`](https://github.com/slackner0/matlab_scatterheat)
- [`matlab_summarize`](https://github.com/slackner0/matlab_summarize)
- [`matlab_distance`](https://github.com/slackner0/matlab_distance) (only needed for `Make_sketch_of_fault.m`)

### Stata
The code was run with Stata 15. The following additional packages/libraries are required and can be installed via Stata.
- [`tabout`](http://fmwww.bc.edu/repec/bocode/t/tabout.html)

### ImageMagick
Converting the individual Figures into one Figure with panels was done with [ImageMagick](https://www.imagemagick.org/script/index.php).
