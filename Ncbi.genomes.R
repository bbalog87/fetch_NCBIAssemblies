#!/bin/bash

#Extract column with genome assembly's accession_Nr in GenBank
#cut pnas.2109019118.sd01.csv -f10 | tail -n+2 > GenbankAcc.txt

## Retrieve Biosample (BS) accesion for a given genome assembly's accession_Nr in GenBank

#for value in $(cat GenbankAcc.txt); do

## Retrieve Biosample (BS) accesion for a given genome assembly's accession_Nr in GenBank
#BS=$(esearch -db assembly -query "$value" |efetch -format docsum | grep BioSampleAccn | cut -f2 -d ">" |cut -f1 -d "<")
#esearch -db biosample -query "$BS" | efetch -format native | grep location | cut -f2 -d "=" >> countries.txt

#done

## Primary cleaning: remove ":", and "|"
#sed 's/\"//g' countries.txt | sed 's/:/,/g'|  sed 's/|/,/g' > countries_genomes.txt 



require(pacman)
pacman::p_load(dplyr, data.table, ggplot2, RColorBrewer, patchwork, ggspatial, 
               ggrepel, raster,colorspace, ggpubr,sf,openxlsx, rnaturalearth,
               rnaturalearthdata,scatterpie)


###############################
## data wrangling nd cleaning #
################################


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

  ## Filtering African countries 
 African_speciesNCNBI<- Countries.Continents %>% filter(Continent=="Africa") %>%
   full_join(y=countriesNCBI,by="Country") %>% filter(!is.na(Continent)) %>%
    select(Continent, Country)
 
 ## group by country
speciesByCountry<-African_speciesNCNBI %>% group_by(Country) %>%                           
   summarise(Total = length(Country))
str(speciesByCountry)
head(speciesByCountry)
