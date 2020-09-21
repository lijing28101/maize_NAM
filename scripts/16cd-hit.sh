#!/bin/bash

module load cufflinks
module load genometools

gffread mikado.loci.gff3 -g Zm-B73-REFERENCE-NAM-5.0.fa -y pep.fa
sed -i 's/\.$/*/' pep.fa
/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/transdecoder-3.0.1-53ns2nerx6pvd23gs4rhc35636r53x6l/util/bin/cd-hit -i pep.fa -T 0 -c 1 -M 0 -d 0 -o filter.pep.fa
grep ">" filter.pep.fa | cut -f1 -d" " | sed 's/>//' > nr-trans.txt
cut -f1-2 -d"." nr-trans.txt | sort -u > nr-gene.txt

grep -Fwf nr-trans.txt mikado.loci.gff3 > trans.gff3
awk '$3=="gene"' mikado.loci.gff3 | grep -Fwf nr-gene.txt - > gene.gff3
cat gene.gff3 trans.gff3 | sed '1 i\##gff-version 3' | gt gff3 -sort -tidy -retainids > B73_final.gff3

