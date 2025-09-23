20250923

This directory contains code and data used to produce the analysis for the LCDE 2026 paper.

The code "main1_computeCityData.R" is used to process EDGAR gridded data, to compute total emissions by city, year, sector, pollutant.

The code "main2_visualizeResults.R" is used to analyse the results and create figures.

Please note that the EDGAR gridded data are not shared in this repository, as too big. 

Also the shp files (standard polygons for cities and countries) are not provided here, as too big.

Also please note that the CSV file in the output directory named "EDGAR_GHG_2000_2024_TLCeu_20250703_CO2_GHG.csv" contains the aggregated data, as computed by "main1_computeCityData.R".