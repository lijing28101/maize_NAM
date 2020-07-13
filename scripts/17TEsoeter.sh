#!/bin/bash

TEsorter filter.pep.fa -p 64 -st prot
grep -v "^#" filter.pep.fa.rexdb.cls.tsv | cut -f 1 | sort | uniq |sed 's/..$//' | sort > TE-trans.txt

