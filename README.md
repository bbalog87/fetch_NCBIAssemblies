## Accessing NCBI’s Entrez databases

Accessing genome assemblies and info using NCBI's Entrez Direct (EDirect) command line utilities.

```bash 
#!/bin/bash

#Extract column with genome assembly's accession_Nr in GenBank
cut pnas.2109019118.sd01.csv -f10 | tail -n+2 > GenbankAcc.txt

# Retrieve Biosample (BS) accesion for a given genome assembly's accession_Nr in GenBank

for value in $(cat GenbankAcc.txt); do

## Retrieve Biosample (BS) accesion for a given genome assembly's accession_Nr in GenBank
BS=$(esearch -db assembly -query "$value" |efetch -format docsum | grep BioSampleAccn | cut -f2 -d ">" |cut -f1 -d "<")
esearch -db biosample -query "$BS" | efetch -format native | grep location | cut -f2 -d "=" >> locations.txt

done

## Cleaning: remove ":", and "|"
sed 's/\"//g' locations.txt | sed 's/:/,/g'|  sed 's/|/,/g' > countries_genomes.txt 

```

### Comments:

 1- The geographic location of DNA samples is not consistent in NCBI  Biosamples entries. Some are missing, other have only geographic coordinates.

2-  Another issue was that, instead of country names, we had lake or river names.
   For example, the majority of genomes were sampled in Lake Tanganyika. Which country (ies) should be associated with that lake? It could be Burundi, DR Congo, Tanzania, or Zambia. Therefore I have created a list of "miscellaneous" locations including all places which are not country names.
   
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

- **Final list of species aggregated by African countries or locations.**

| Country                       | Count |
|-------------------------------|-------|
| Algeria                       | 1     |
| Angola                        | 1     |
| Benin                         | 1     |
| Botswana                      | 1     |
| Burkina                       | 1     |
| Burundi                       | 1     |
| Cameroon                      | 12    |
| Cape Verde                    | 1     |
| Central African Republic      | 1     |
| Chad                          | 1     |
| Comoros                       | 1     |
| Congo                         | 1     |
| Congo River                   | 2     |
| Congo, Democratic Republic of | 1     |
| Djibouti                      | 1     |
| Egypt                         | 2     |
| Equatorial Guinea             | 1     |
| Eritrea                       | 1     |
| Ethiopia                      | 2     |
| Gabon                         | 12    |
| Gambia                        | 1     |
| Ghana                         | 5     |
| Guinea                        | 1     |
| Guinea-Bissau                 | 1     |
| Ivory Coast                   | 1     |
| Kafue River                   | 1     |
| Kenya                         | 6     |
| Lake Barombi Mbo              | 1     |
| Lake Chila                    | 1     |
| Lake Fwa                      | 1     |
| Lake Tanganyika               | 243   |
| Lake Tanganyika affluent      | 9     |
| Lesotho                       | 1     |
| Liberia                       | 1     |
| Libya                         | 1     |
| Madagascar                    | 14    |
| Malawi                        | 6     |
| Mali                          | 1     |
| Mauritania                    | 1     |
| Mauritius                     | 1     |
| Morocco                       | 1     |
| Mozambique                    | 1     |
| Namibia                       | 15    |
| Niger                         | 1     |
| Nigeria                       | 1     |
| Ruaha River                   | 1     |
| Rwanda                        | 1     |
| Sao Tome and Principe         | 3     |
| Senegal                       | 1     |
| Seychelles                    | 2     |
| Sierra Leone                  | 1     |
| Somalia                       | 1     |
| South Africa                  | 22    |
| South Sudan                   | 1     |
| Sudan                         | 1     |
| Swaziland                     | 1     |
| Tanzania                      | 7     |
| Togo                          | 1     |
| Tunisia                       | 1     |
| Uganda                        | 4     |
| Western Africa                | 2     |
| Zambezi River                 | 2     |
| Zambia                        | 2     |
| Zimbabwe                      | 3     |
| Total                         | 418   |
