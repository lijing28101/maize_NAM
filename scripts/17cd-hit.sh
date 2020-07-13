#!/bin/bash

/opt/rit/spack-app/linux-rhel7-x86_64/gcc-4.8.5/transdecoder-3.0.1-53ns2nerx6pvd23gs4rhc35636r53x6l/util/bin/cd-hit -i pep.fa -T 0 -c 1 -M 0 -d 0 -o filter.pep.fa
grep ">" filter.pep.fa | cut -f1 -d" " | sed 's/>//' | sed 's/..$//' | sort > nr-trans.txt
