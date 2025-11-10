<<<<<<< HEAD
#clean workspace
rm(list=ls())

#load libraries
# library(tmap)
library(exactextractr)     
library(sf)
library(tidyverse)
library(readxl)
library(lubridate)
library(terra)
library(dplyr)
library(xml2)

#load population by city
pop <- read_csv('../DROPBOX/Report Guidance/Population and Mortality/population_cities_lcde.csv') %>%
  select(URAU_CODE, Year, country, URAU_NAME, nuts3, pop_total)

#load city features, as size and geographical area
listcities <- read_xlsx('../DROPBOX/Report Guidance/List_cities.xlsx') %>%
  rename("URAU_CODE"=CODE) %>%
  select(Country_name, URAU_CODE, `EEA sub-region division`, `European sub-region (UN geoscheme)`, `Population size` )

#use 1 for population based aggregation, 0 for area based aggregation
weightsPW=0

#load generic EDGAR raster to have some info on CRS
path <- 'V:/EDGAR/MAPS/proxies/2025/1km_project/output/emi/31oct2025/'
path_1st_file <- paste0(path, 'GWP_100_AR5_GHG/MERGED/GWP_100_AR5_GHG_2024_Agriculture.tif')
edgar <- rast(path_1st_file)

#load weights for 1km aggregation ... these are population weighted weights, for cells partly overlapping polygons
#0 means cell is not urban
#1 is fully urban
#between 0 and 1 is cell overlapping polygon, with weight related to pop in urban
pWeightsFile <- './input/2025smodPOPnew.csv'
pWeights <- read_csv(pWeightsFile)

#move weights from SW corner to centre-cell
pWeights$lat <- pWeights$lat+0.05 
pWeights$lon <- pWeights$lon+0.05
pWeights_raster <- edgar

#write a raster with weights
values(pWeights_raster) <- 0
points <- vect(pWeights, geom=c("lon", "lat"), crs=crs(edgar))
rasterized <- rasterize(points, pWeights_raster, field="smod30", fun=max, touches=TRUE)
rasterized <- subst(rasterized, NA, 0)

#load required polygons
nnff <- paste0('./Shapefiles/Cities_boundaries/cities_lcde.shp')
cities <- vect(st_read(nnff))
cities_wgs <-project(cities, edgar)
# writeVector(cities_wgs, 'TLCD_in_WGS84_v20251105.gpkg', overwrite=TRUE)

#loop over all EDGAR files, considering available pollutants, sectors, and years
polls <- c('GWP_100_AR5_GHG')
sects <- c('Agriculture', 'Energy', 'Industry', 'Residential', 'Transport', 'Waste', "International")
years <- seq(2000,2024)
for (poll in polls) {
  for (sect in sects) {
    for (year in years) {
      #load edgar file
      edgar_file <- paste0(path,'GWP_100_AR5_GHG/MERGED/',poll,'_',year,'_',sect,'.tif')
      print(edgar_file)
      edgar_rast <- rast(edgar_file)
      
      #extract data - normal area weighted approach VS pop-based (Diego weights) approach
      #area based approach - not used here
      if (weightsPW==0) {
        # edgar_sum_city <- exact_extract(edgar_rast, st_as_sf(cities_wgs), fun='sum')
        edgar_sum_city <- exact_extract(edgar_rast, st_as_sf(cities_wgs), fun='sum')
        
        } else {
        #new approach disregarding area fraction for partly overlapping cells, but using weights
        #if the cell is completely in the polygon use weight=1, if the cell is partly in polygon use weights
        edgar_sum_city <- exact_extract(edgar_rast, st_as_sf(cities_wgs), 
                                          fun = function(values, coverage_fraction, weights) 
                                          {sum(values * weights) }, weights = rasterized)
      }
      #store results
      label <- paste0('EMI_', poll, '-', sect, '-',year)
      cities_wgs[[label]] <- edgar_sum_city
    }
  }
}

#final daa wranglign
cities_wgs_td <- cities_wgs %>%
  as_tibble() %>%
  pivot_longer(starts_with('EMI'),  names_to = c("Pollutant", "Sector", "Year"), names_sep = "-", values_to = "Emissions") %>% 
  mutate(Year=as.numeric(Year)) %>%
  left_join(pop, by=c("URAU_CODE", "Year"))

cities_wgs_td_v2 <- cities_wgs_td %>%
  left_join(listcities , by=c("URAU_CODE")) %>%
  select(CNTR_CODE, URAU_CODE, URAU_NAME.x, Pollutant, Sector, Year, Emissions, pop_total, 
         `European sub-region (UN geoscheme)`, `Population size`) %>%
  rename("URAU_NAME"=URAU_NAME.x) %>%
  rename("Population"=pop_total)

#save final results - with 2024 missing population
nfout <- paste0('./output_v4/EDGAR_GHG_2000_2024_TLCeu_20251106_areabased.csv')
write_csv(cities_wgs_td_v2, nfout)
   
=======
#clean workspace
rm(list=ls())

#load libraries
# library(tmap)
library(exactextractr)     
library(sf)
library(tidyverse)
library(readxl)
library(lubridate)
library(terra)
library(dplyr)
library(xml2)

#load population by city
pop <- read_csv('../DROPBOX/Report Guidance/Population and Mortality/population_cities_lcde.csv') %>%
  select(URAU_CODE, Year, country, URAU_NAME, nuts3, pop_total)

#load city features, as size and geographical area
listcities <- read_xlsx('../DROPBOX/Report Guidance/List_cities.xlsx') %>%
  rename("URAU_CODE"=CODE) %>%
  select(Country_name, URAU_CODE, `EEA sub-region division`, `European sub-region (UN geoscheme)`, `Population size` )

#use 1 for population based aggregation, 0 for area based aggregation
weightsPW=0

#load generic EDGAR raster to have some info on CRS
path <- 'V:/EDGAR/MAPS/proxies/2025/1km_project/output/emi/31oct2025/'
path_1st_file <- paste0(path, 'GWP_100_AR5_GHG/MERGED/GWP_100_AR5_GHG_2024_Agriculture.tif')
edgar <- rast(path_1st_file)

#load weights for 1km aggregation ... these are population weighted weights, for cells partly overlapping polygons
#0 means cell is not urban
#1 is fully urban
#between 0 and 1 is cell overlapping polygon, with weight related to pop in urban
pWeightsFile <- './input/2025smodPOPnew.csv'
pWeights <- read_csv(pWeightsFile)

#move weights from SW corner to centre-cell
pWeights$lat <- pWeights$lat+0.05 
pWeights$lon <- pWeights$lon+0.05
pWeights_raster <- edgar

#write a raster with weights
values(pWeights_raster) <- 0
points <- vect(pWeights, geom=c("lon", "lat"), crs=crs(edgar))
rasterized <- rasterize(points, pWeights_raster, field="smod30", fun=max, touches=TRUE)
rasterized <- subst(rasterized, NA, 0)

#load required polygons
nnff <- paste0('./Shapefiles/Cities_boundaries/cities_lcde.shp')
cities <- vect(st_read(nnff))
cities_wgs <-project(cities, edgar)
# writeVector(cities_wgs, 'TLCD_in_WGS84_v20251105.gpkg', overwrite=TRUE)

#loop over all EDGAR files, considering available pollutants, sectors, and years
polls <- c('GWP_100_AR5_GHG')
sects <- c('Agriculture', 'Energy', 'Industry', 'Residential', 'Transport', 'Waste', "International")
years <- seq(2000,2024)
for (poll in polls) {
  for (sect in sects) {
    for (year in years) {
      #load edgar file
      edgar_file <- paste0(path,'GWP_100_AR5_GHG/MERGED/',poll,'_',year,'_',sect,'.tif')
      print(edgar_file)
      edgar_rast <- rast(edgar_file)
      
      #extract data - normal area weighted approach VS pop-based (Diego weights) approach
      #area based approach - not used here
      if (weightsPW==0) {
        # edgar_sum_city <- exact_extract(edgar_rast, st_as_sf(cities_wgs), fun='sum')
        edgar_sum_city <- exact_extract(edgar_rast, st_as_sf(cities_wgs), fun='sum')
        
        } else {
        #new approach disregarding area fraction for partly overlapping cells, but using weights
        #if the cell is completely in the polygon use weight=1, if the cell is partly in polygon use weights
        edgar_sum_city <- exact_extract(edgar_rast, st_as_sf(cities_wgs), 
                                          fun = function(values, coverage_fraction, weights) 
                                          {sum(values * weights) }, weights = rasterized)
      }
      #store results
      label <- paste0('EMI_', poll, '-', sect, '-',year)
      cities_wgs[[label]] <- edgar_sum_city
    }
  }
}

#final daa wranglign
cities_wgs_td <- cities_wgs %>%
  as_tibble() %>%
  pivot_longer(starts_with('EMI'),  names_to = c("Pollutant", "Sector", "Year"), names_sep = "-", values_to = "Emissions") %>% 
  mutate(Year=as.numeric(Year)) %>%
  left_join(pop, by=c("URAU_CODE", "Year"))

cities_wgs_td_v2 <- cities_wgs_td %>%
  left_join(listcities , by=c("URAU_CODE")) %>%
  select(CNTR_CODE, URAU_CODE, URAU_NAME.x, Pollutant, Sector, Year, Emissions, pop_total, 
         `European sub-region (UN geoscheme)`, `Population size`) %>%
  rename("URAU_NAME"=URAU_NAME.x) %>%
  rename("Population"=pop_total)

#save final results - with 2024 missing population
nfout <- paste0('./output_v4/EDGAR_GHG_2000_2024_TLCeu_20251106_areabased.csv')
write_csv(cities_wgs_td_v2, nfout)
   
>>>>>>> cd1580de99d11a7c8a56c618004c3588e377f20c
