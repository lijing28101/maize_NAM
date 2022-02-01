module load interproscan

#Assign GO term from diverse database in interpro by domain similarity
#Output is B73.faa.tsv
interproscan.sh -goterms -pa -i B73.faa -dp -f tsv -cpu 36
