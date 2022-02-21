#!/bin/bash

#Extract column with genome assembly's accession_Nr in GenBank
cut pnas.2109019118.sd01.csv -f10 | tail -n+2 > GenbankAcc.txt

## Retrieve Biosample (BS) accesion for a given genome assembly's accession_Nr in GenBank

for value in $(cat GenbankAcc.txt); do

## Retrieve Biosample (BS) accesion for a given genome assembly's accession_Nr in GenBank
BS=$(esearch -db assembly -query "$value" |efetch -format docsum | grep BioSampleAccn | cut -f2 -d ">" |cut -f1 -d "<")
esearch -db biosample -query "$BS" | efetch -format native | grep location | cut -f2 -d "=" >> countries.txt

done

## Primary cleaning: remove ":", and "|"
sed 's/\"//g' countries.txt | sed 's/:/,/g'|  sed 's/|/,/g' > countries_genomes.txt 

#!/home/fb3/nguinkal/anaconda3/envs/purgedupEnv/bin/python
from Bio import Entrez

# Read the accessions from a file
accessions_file = 'accessions.txt'
with open(accessions_file) as f:
    ids = f.read().split('\n')

# Fetch the entries from Entrez
Entrez.email = 'balogog87@gmail.com'  # Insert your email here
handle = Entrez.efetch('nuccore', id=ids, retmode='xml')
response = Entrez.read(handle)

# Parse the entries to get the country
def extract_countries(entry):
    sources = [feature for feature in entry['GBSeq_feature-table']
               if feature['GBFeature_key'] == 'source']

    for source in sources:
        qualifiers = [qual for qual in source['GBFeature_quals']
                      if qual['GBQualifier_name'] == 'country']
        
        for qualifier in qualifiers:
            yield qualifier['GBQualifier_value']

for entry in response:
    accession = entry['GBSeq_primary-accession']
    for country in extract_countries(entry):
        print(accession, country, sep=',')