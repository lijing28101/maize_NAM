#!/bin/bash

module load cufflinks
module load emboss

gffread mikado.loci.gff3 -g Zm-B73-REFERENCE-NAM-5.0.fa -x cds.fa
transeq -sequence cds.fa -outseq pep.fa
TEsorter filter.pep.fa -p 64 -st prot
grep -v "^#" filter.pep.fa.rexdb.cls.tsv | cut -f 1 | sort | uniq |sed 's/..$//' | sort > TE-trans.txt

