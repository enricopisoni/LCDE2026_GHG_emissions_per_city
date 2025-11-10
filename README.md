# Data and code for the LCDE 2026 paper

This directory contains code and data used to produce the analysis for the LCDE 2026 paper.

The code "step1_edgar_20251106_1km_areaBased.R" is used to process EDGAR gridded data, to compute total emissions by city, year, sector, pollutant.
It basically overlaps grids and polygons, and sum up EDGAR gridded emissions on the different cities' polygons.

The code "step2_aggregatedResults_adding_2024pop_20251106.R" is used to add 2024 population to the dataset, and to compute some summary statistics used in the paper.

The code "step3_visualizeResults_20251106_v4.R" it is used to visualize results.

Please note that:

* the EDGAR gridded data (at roughly 1km) are not shared in this repository, as too big. 

* the shp files (standard polygons for cities and countries) are not provided here, as too big.

* the CSV file in the output directory named "EDGAR_GHG_2000_2024_TLCeu_20251106_areabased_v2.csv" contains the aggregated data, as computed by the R code.