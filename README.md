## Accessing NCBI’s Entrez databases

Accessing genome assemblies and info using NCBI's EDirect command line utility.

```bash 
#!/bin/bash

#Extract column with genome assembly's accession_Nr in GenBank
cut pnas.2109019118.sd01.csv -f10 | tail -n+2 > GenbankAcc.txt

# Retrieve Biosample (BS) accesion for a given genome assembly's accession_Nr in GenBank

for value in $(cat GenbankAcc.txt); do

## Retrieve Biosample (BS) accesion for a given genome assembly's accession_Nr in GenBank
BS=$(esearch -db assembly -query "$value" |efetch -format docsum | grep BioSampleAccn | cut -f2 -d ">" |cut -f1 -d "<")
esearch -db biosample -query "$BS" | efetch -format native | grep location | cut -f2 -d "=" >> countries.txt

done

## Cleaning: remove ":", and "|"
sed 's/\"//g' countries.txt | sed 's/:/,/g'|  sed 's/|/,/g' > countries_genomes.txt 

```

### Comments:

- The geographic location of DNA sample is not consistent in NCBI  Biosamples entries. Some are missing, other have only geographic coordinate
-  Another issue is that instead of contries, we have lake or river names.
   For example, mojorty of genomes were sampled in LakeTanganyika. Which countrz shou;d assoicated with this location?
   It could be Burundi, DR Congo, Tanzania, or Zambia. TTherefor I have created a list of miscelinaous countrz names including all places which are not contrz names.
   
  ### Data cleaning and wrangling with R
  
 ```R
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
          
```
