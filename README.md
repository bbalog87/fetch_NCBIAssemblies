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
-  Another issue is that instead of contries we have lake or river names.
   For example, mojorty of genomes were sampled in LakeTanganyika. Which countrz shou;d assoicated with this location?
   It could be Burundi, DR Congo, Tanzania, or Zambia. TTherefor I have created a list of miscelinaous countrz names including all places which are not contrz names.

