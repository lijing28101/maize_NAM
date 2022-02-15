#!/bin/bash

# filter.cds.fa is the cDNA sequence of non-redundant trascripts.
cat filter.cdna.fa Zm-B73-REFERENCE-NAM-5.0.fa> B73.gentrome.fa
salmon index -t B73.gentrome.fa -p 96 -i salmon_index --keepDuplicates
