<<<<<<< HEAD
rm(list=ls())
library(tidyverse)

# reading results and perform factorizaion
df <- read_csv('output_v4/EDGAR_GHG_2000_2024_TLCeu_20251106_areabased.csv')
df2 <- df %>%
  select(URAU_CODE, CNTR_CODE, URAU_NAME, 
         Pollutant,  Sector,  Year,  Emissions, Population,
         `European sub-region (UN geoscheme)`,
         `Population size`) 
df2$`Population size` <- factor(df2$`Population size`, levels=c("S","M","L","XL", "XXL", "Global city"))

#collapse XXL and Global City
df2$`Population size` <- fct_collapse(df2$`Population size`, "XXL+Global" = c("XXL", "Global city"))

#in case multiple pollutants are analyzed
poll = "EMI_GWP_100_AR5_GHG"
if (poll=="EMI_GWP_100_AR5_GHG") {
  poll_tag='GHG' } else if (poll=="EMI_CO2") {
    poll_tag='CO2'
  }

#add 2024 population, as 2023
df3 <- df2 %>%
  group_by(URAU_NAME) %>%
  mutate(Population = case_when(
    Year == 2024 & is.na(Population) ~ first(Population[Year == 2023]),
    TRUE ~ Population
  )) %>%
  ungroup()
write_csv(df3, 'output_v4/EDGAR_GHG_2000_2024_TLCeu_20251106_areabased_v2.csv')

pop <- df3 %>% filter(Sector=='Agriculture') %>% select(URAU_CODE, Year, Population) 

#save results aggregated by area-populationSize, and by Sector
df4 <- df3 %>%
  filter(Pollutant==poll) %>%
  group_by(Year, `European sub-region (UN geoscheme)`,`Population size`, URAU_CODE) %>%
  summarize(emi_tonnes_2 = sum(Emissions)) %>%
  left_join(pop, by=c('Year', 'URAU_CODE')) %>%
  group_by(Year, `European sub-region (UN geoscheme)`,`Population size`) %>%
  summarize(emi_tonnes_per_capita=sum(emi_tonnes_2)/sum(Population)) %>%
  filter(Year %in% c('2000', '2024')) %>%
  pivot_wider(names_from = Year, values_from = emi_tonnes_per_capita)
write_csv(df4, 'output_v4/results_by_EUregion_popSize_year_areabased.csv')

df5 <- df3 %>%
  filter(Pollutant==poll) %>%
  group_by(Year, Sector, URAU_CODE) %>%
  summarize(emi_tonnes_2 = sum(Emissions)) %>%
  left_join(pop, by=c('Year', 'URAU_CODE')) %>%
  group_by(Year, Sector) %>%
  summarize(emi_tonnes_per_capita=sum(emi_tonnes_2)/sum(Population)) %>%
  filter(Year %in% c('2000', '2024')) %>%
  pivot_wider(names_from = Year, values_from = emi_tonnes_per_capita)
write_csv(df5, 'output_v4/results_by_sector_year_areabased.csv')
=======
rm(list=ls())
library(tidyverse)

# reading results and perform factorizaion
df <- read_csv('output_v4/EDGAR_GHG_2000_2024_TLCeu_20251106_areabased.csv')
df2 <- df %>%
  select(URAU_CODE, CNTR_CODE, URAU_NAME, 
         Pollutant,  Sector,  Year,  Emissions, Population,
         `European sub-region (UN geoscheme)`,
         `Population size`) 
df2$`Population size` <- factor(df2$`Population size`, levels=c("S","M","L","XL", "XXL", "Global city"))

#collapse XXL and Global City
df2$`Population size` <- fct_collapse(df2$`Population size`, "XXL+Global" = c("XXL", "Global city"))

#in case multiple pollutants are analyzed
poll = "EMI_GWP_100_AR5_GHG"
if (poll=="EMI_GWP_100_AR5_GHG") {
  poll_tag='GHG' } else if (poll=="EMI_CO2") {
    poll_tag='CO2'
  }

#add 2024 population, as 2023
df3 <- df2 %>%
  group_by(URAU_NAME) %>%
  mutate(Population = case_when(
    Year == 2024 & is.na(Population) ~ first(Population[Year == 2023]),
    TRUE ~ Population
  )) %>%
  ungroup()
write_csv(df3, 'output_v4/EDGAR_GHG_2000_2024_TLCeu_20251106_areabased_v2.csv')

pop <- df3 %>% filter(Sector=='Agriculture') %>% select(URAU_CODE, Year, Population) 

#save results aggregated by area-populationSize, and by Sector
df4 <- df3 %>%
  filter(Pollutant==poll) %>%
  group_by(Year, `European sub-region (UN geoscheme)`,`Population size`, URAU_CODE) %>%
  summarize(emi_tonnes_2 = sum(Emissions)) %>%
  left_join(pop, by=c('Year', 'URAU_CODE')) %>%
  group_by(Year, `European sub-region (UN geoscheme)`,`Population size`) %>%
  summarize(emi_tonnes_per_capita=sum(emi_tonnes_2)/sum(Population)) %>%
  filter(Year %in% c('2000', '2024')) %>%
  pivot_wider(names_from = Year, values_from = emi_tonnes_per_capita)
write_csv(df4, 'output_v4/results_by_EUregion_popSize_year_areabased.csv')

df5 <- df3 %>%
  filter(Pollutant==poll) %>%
  group_by(Year, Sector, URAU_CODE) %>%
  summarize(emi_tonnes_2 = sum(Emissions)) %>%
  left_join(pop, by=c('Year', 'URAU_CODE')) %>%
  group_by(Year, Sector) %>%
  summarize(emi_tonnes_per_capita=sum(emi_tonnes_2)/sum(Population)) %>%
  filter(Year %in% c('2000', '2024')) %>%
  pivot_wider(names_from = Year, values_from = emi_tonnes_per_capita)
write_csv(df5, 'output_v4/results_by_sector_year_areabased.csv')
>>>>>>> cd1580de99d11a7c8a56c618004c3588e377f20c
