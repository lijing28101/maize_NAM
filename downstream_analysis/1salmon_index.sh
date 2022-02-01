#!/bin/bash

# filter.cds.fa is the CDS sequence of non-redundant trascripts.
salmon index -t filter.cds.fa -p 96 -i salmon_index
