# Gene prediction, orphan identification and analysis for maize NAM line workflow:

## Direct Inference prediction:

**Direct Inference (DI)**: Gene predictions inferred directly from alignment of RNA-Seq evidence to the genome.

1. Prepare RNA-Seq dataset:

    - Use RNA-Seq dataset with known metadata from our collabrated lab for 25 NAM founder lines and B73.
    - Download more RNA-Seq data for B73 from NCBI-SRA:
        - Search RNA-Seq datasets for Zea mays subsp. mays (taxid:381124), filter Runs for Illumina, paired-end, B73, and exclude samples with miRNA-Seq, ncRNA-Seq, or RIP-Seq library strategies.
        - Download metadata and SRR IDs from SRA Run Selector.
        - Download RNA-Seq samples by [`01downloadSRR.sh`](scripts/01downloadSRR.sh).
        
```bash
# Download RNA-Seq data by SRR ID in the SRR_list.txt
while read line; do
    ./01downloadSRR.sh ${line};
done<SRR_list.txt
```

2. Preprocess for RNA-Seq data:

    - Delete adapter sequence and do quality triming by [bbduk](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbduk-guide/) using script [`02bbduk.sh`](scripts/02bbduk.sh)
    
```bash
#Clean RNA-Seq fastq file by SRR ID in the SRR_list.txt
while read line; do
    ./02bbduk.sh ${line};
done<SRR_list.txt
```

3. Prepare genome sequence:

    - We used RefGen_v5 assembly for B73 downloaded from [MaizeGDB B73_v5](https://download.maizegdb.org/Zm-B73-REFERENCE-NAM-5.0/Zm-B73-REFERENCE-NAM-5.0.fa.gz). 
    - Other genome sequence for 25 NAM lines also downloaded from [MaizeGDB NAM-genomes](https://www.maizegdb.org/NAM_project).
    
