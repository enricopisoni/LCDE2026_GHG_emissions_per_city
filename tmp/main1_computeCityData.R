#clean workspace
rm(list=ls())

#load libraries
library(tmap)
library(exactextractr)     
library(sf)
library(tidyverse)
library(readxl)
library(lubridate)
library(terra)

#load population by city
pop <- read_csv('input/DROPBOX/Report Guidance/Population and Mortality/population_cities_lcde.csv') %>%
  select(URAU_CODE, Year, country, URAU_NAME, nuts3, pop_total)

#load city features, as size and geographical area
listcities <- read_xlsx('input/DROPBOX/Report Guidance/List_cities.xlsx') %>%
  rename("URAU_CODE"=CODE) %>%
  select(Country_name, URAU_CODE, `EEA sub-region division`, `European sub-region (UN geoscheme)`, `Population size` )

#use 1 for population based aggregation, 0 for area based aggregation
weightsPW=1

#load generic EDGAR raster to have some info on CRS
path <- 'DATASET_NOT_SHARED_AS_TOO_BIG'
path_1st_file <- paste0(path, 'GWP_100_AR5_GHG/Agriculture/emi_nc/EDGAR_2025_GHG_GWP_100_AR5_GHG_2000_Agriculture_emi.nc')
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

#loop over all EDGAR files, considering available pollutants, sectors, and years
polls <- list.files(path)
sects <- list.files(paste0(path,'/GWP_100_AR5_GHG/'))
years <- seq(2000,2024)
for (poll in polls) {
  for (sect in sects) {
    for (year in years) {
      #load edgar file
      edgar_file <- paste0(path,poll,'/',sect,'/emi_nc/EDGAR_2025_GHG_',poll,'_',year,'_',sect,'_emi.nc')
      print(edgar_file)
      edgar_rast <- rast(edgar_file)
      
      #extract data - normal area weighted approach VS pop-based (Diego weights) approach
      #area based approach - not used here
      if (weightsPW==0) {
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

#final daa wrangling
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

#save final results
nfout <- paste0('./output/EDGAR_GHG_2000_2024_TLCeu_20250703_CO2_GHG.csv')
write_csv(cities_wgs_td_v2, nfout)
   
