
###############################
## data wrangling and cleaning #
################################

library(readxl)
library(dplyr)
library(tidyverse)
library(knitr)

## Load NCBI geographic locations
countriesNCBI <- read_excel("countriesNCBI.xlsx", col_names = FALSE)
colnames(countriesNCBI)<-c("Country", LETTERS[1:6]) ## colnames
str(countriesNCBI)
head(countriesNCBI, 3)
tail(countriesNCBI, 3)


## Load ISO countries
Countries.Continents<- read.csv("Countries-Continents.csv")
str(Countries.Continents)
head(Countries.Continents,3)

misc_locations<-c("Zambezi River","Congo River",
                  "Lake Tanganyika", "Lake Fwa",
                  "Kafue River", "Lake Chila",
                  "Western Africa","Lake Barombi Mbo",
                  "Lake Tanganyika affluent",
                  "Ruaha River")

misc_locations.df<-countriesNCBI[countriesNCBI$Country %in% misc_locations,] %>%
  dplyr::select(Country) %>%
  mutate(Continent=rep("Africa", nrow(.))) 
  


## Filtering African countries 
African_speciesNCNBI<- Countries.Continents %>% 
  filter(Continent=="Africa") %>%
  full_join(y=countriesNCBI,by="Country") %>% 
  filter(!is.na(Continent))  %>%
  dplyr::select(1:2) %>% 
  rbind(., misc_locations.df[, 1:2])



## group by country
speciesByCountry<-African_speciesNCNBI %>% group_by(Country) %>%                           
  summarise(Total = length(Country)) %>% arrange(Country)
str(speciesByCountry)
head(speciesByCountry)



write.csv(speciesByCountry,"speciesByCountry_Africa.csv",
          row.names = F)