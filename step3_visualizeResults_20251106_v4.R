rm(list=ls())
library(tidyverse)

# load data
df <- read_csv('output_v4/EDGAR_GHG_2000_2024_TLCeu_20251106_areabased_v2.csv')
# df$`Population size` <- fct_collapse(df$`Population size`, "XXL+Global" = c("XXL", "Global city"))
df2 <- df
df2$`Population size` <- factor(df2$`Population size`, levels=c("S","M","L","XL", "XXL+Global"))
df2$`European sub-region (UN geoscheme)` <- factor(df2$`European sub-region (UN geoscheme)`, 
                                                   levels=c("Northern Europe",
                                                            "Western Europe",
                                                            "Southern Europe",
                                                            "Eastern Europe", 
                                                            "Western Asia"))


# df2 <- df %>%
#   select(URAU_CODE, CNTR_CODE, URAU_NAME,
#               Pollutant,  Sector,  Year,  Emissions, Population,
#               `European sub-region (UN geoscheme)`,
#               `Population size`)
# df2$`Population size` <- factor(df2$`Population size`, levels=c("S","M","L","XL", "XXL", "Global city"))
# #collapse XXL and Global City
# df2$`Population size` <- fct_collapse(df2$`Population size`, "XXL+Global" = c("XXL", "Global city"))

#create graphs
for (poll in c("EMI_GWP_100_AR5_GHG")) {

  if (poll=="EMI_GWP_100_AR5_GHG") {
    poll_tag='GHG' } else if (poll=="EMI_CO2") {
      poll_tag='CO2'
  }
  
  title=paste0('Trend in ',poll_tag,' emission per capita, sum of all cities emissions divided by sum of population, \n groupd by city size and geographical area')
  df2 %>%
    filter(Pollutant==poll) %>%
    group_by(Sector, Year, `European sub-region (UN geoscheme)`,`Population size`) %>%
    summarize(emi_tonnes_2 = sum(Emissions), pop_total_2=sum(Population)) %>%
    mutate(emi_tonnes_per_capita=emi_tonnes_2/pop_total_2) %>%
    ggplot(aes(x=Year, y=emi_tonnes_per_capita, fill=Sector)) + 
    geom_bar(position="stack", stat = "identity") +
    facet_grid(`European sub-region (UN geoscheme)` ~ `Population size`) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    xlab('') +
    ylab('Emissions per capita [tonnes/cap]') +
    ggtitle(title)
  ggsave(paste0('output_v4/trend_',poll,'_emi_per_capita_byAreaCity_v4_areabased.png'), width=10, height = 8)
}

#check numerosity
df2 %>%
  distinct(URAU_NAME, .keep_all=TRUE) %>%
  count(`Population size`)

df2 %>%
  distinct(URAU_NAME, .keep_all=TRUE) %>%
  count(`European sub-region (UN geoscheme)`)

df2 %>%
  distinct(URAU_NAME, .keep_all=TRUE) %>%
  count(`Population size`, `European sub-region (UN geoscheme)`) %>%
  ggplot(aes(x=`European sub-region (UN geoscheme)`, y=n, fill=`Population size`)) +
  geom_bar(stat = 'identity') +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  ylab('Number of cities') 
ggsave('output_v4/cities_numerosity_v4_areabased.png', width=8, height=8)  

df2 %>%
  distinct(URAU_NAME, .keep_all=TRUE) %>%
  count(CNTR_CODE ) 
