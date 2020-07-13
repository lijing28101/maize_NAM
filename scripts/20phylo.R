#!/usr/bin/env Rscript

library(reshape2)
library(taxizedb)
library(dplyr)
library(readr)
library(phylostratr)
library(magrittr)
require(knitr)
require(ape)

# add good prokaryote taxa from pacakge
prokaryote_sample <- readRDS(system.file("extdata","prokaryote_sample.rda", package = "phylostratr"))
prokaryotes_toadd<-prokaryote_sample$tip.label
# remove 1008392, there is no file for this species in NCBI now
toremove<-as.character(c(1008392)) #this has empty faa file
prokaryotes_toadd<-prokaryotes_toadd [! prokaryotes_toadd %in% toremove]
# add some species with good geome and gene models
more <- as.character(c(9598,10090,9031,7955,7227,6239,4932,33169,4896,3702,39946,
                                39947,4533,15368,4577,4615,3711,109376,50452,81985,29730,3983,
                                3555,317936,166314,1647413,9606,4576,3702,4932,76912,4579))

# focal species: Zea mays subsp. mays B73
focal_taxid <- '381124'

# build a strata project, using B73 as focal species, 
# choose 10 species for each nodes and download protein sequence from uniprot

strata <-
  uniprot_strata(focal_taxid, from=2) %>%
  add_taxa('381124') %>%
  strata_apply(f=diverse_subtree, n=10, weights=uniprot_weight_by_ref()) %>%
  add_taxa(prokaryotes_toadd) %>%
  add_taxa(more) %>% 
  uniprot_fill_strata

# add tree of NAM lines in strata
new_node <- Strata(
  tree = ape::read.tree("NAM.tree"),
  data = list(faa=list(
    B73='uniprot-seqs/B73.faa',
    B97='uniprot-seqs/B97.faa',
    CML103='uniprot-seqs/CML103.faa',
    CML228='uniprot-seqs/CML228.faa',
    CML247='uniprot-seqs/CML247.faa',
    CML277='uniprot-seqs/CML277.faa',
    CML322='uniprot-seqs/CML322.faa',
    CML333='uniprot-seqs/CML333.faa',
    CML52='uniprot-seqs/CML52.faa',
    CML69='uniprot-seqs/CML69.faa',
    HP301='uniprot-seqs/HP301.faa',
    IL14H='uniprot-seqs/IL14H.faa',
    Ki11='uniprot-seqs/Ki11.faa',
    Ki3='uniprot-seqs/Ki3.faa',
    Ky21='uniprot-seqs/Ky21.faa',
    M162W='uniprot-seqs/M162W.faa',
    M37W='uniprot-seqs/M37W.faa',
    Mo18W='uniprot-seqs/Mo18W.faa',
    MS71='uniprot-seqs/MS71.faa',
    NC350='uniprot-seqs/NC350.faa',
    NC358='uniprot-seqs/NC358.faa',
    Oh43='uniprot-seqs/Oh43.faa',
    Oh7b='uniprot-seqs/Oh7b.faa',
    P39='uniprot-seqs/P39.faa',
    Tx303='uniprot-seqs/Tx303.faa',
    Tzi8='uniprot-seqs/Tzi8.faa',
    parviglumis='uniprot-seqs/76912.faa'
  )),
  focal_species = '381124'
)

strata <- replace_branch(strata, y=new_node, node='4577')
strata@focal_species="B73"

strata <- strata_diamond(strata, blast_args=list(nthreads=64)) %>% strata_besthits
results <- merge_besthits(strata)
age <- stratify(results)

save.image("phylo.RData")
