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

    - Delete adapter sequence and do quality triming by [BBDuk](https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbduk-guide/) using script [`02bbduk.sh`](scripts/02bbduk.sh)
    
```bash
#Clean RNA-Seq fastq file by SRR ID in the SRR_list.txt
while read line; do
    ./02bbduk.sh ${line};
done<SRR_list.txt
```

3. Prepare genome sequence:

    - We used RefGen_v5 assembly for B73 downloaded from [MaizeGDB B73_v5](https://download.maizegdb.org/Zm-B73-REFERENCE-NAM-5.0/Zm-B73-REFERENCE-NAM-5.0.fa.gz). 
    - Other genome sequence for 25 NAM lines also downloaded from [MaizeGDB NAM-genomes](https://www.maizegdb.org/NAM_project).
    
4. RNA-Seq alignment:
    - We used Hisat2 to align RNA-Seq data to the genome sequence.
    - We used samtools to convert sam file to bam file and sort bam file by location (by script [`03alignment.sh`](scripts/03alignment.sh)).
    
 ```bash
 # RNA-Seq alignment by SRR ID in the SRR_list.txt
while read line; do
    ./03alignment.sh ${line};
done<SRR_list.txt
 ```
 
 5. Determine the stranded information:
 
    - Many public data don't have detailed strand information for the RNA-Seq samples. We need to use different option for stranded-specific and unstranded libraries.
    - In order to determine an RNA-Seq library stranded or not, we used `infer_experiment.py` in [RSeQC](http://rseqc.sourceforge.net/#infer-experiment-py) to check the strand specification for each library (by script [`04strand.sh`](scripts/04strand.sh)).
    
 ```bash
# Determine strand specific by SRR ID in the SRR_list.txt, keep the strand information in the strand_info.txt.
while read line; do
    ./04strand.sh ${line};
done<SRR_list.txt > strand_info.txt
```

      In the strand_info.txt, --fr means read 1 comes from the forward strand, --rf means read 1 comes from the reverse strand. 
  
 6. De novo transcriptome assembly:
  
    - Use the sorted BAM files with multiple transcript assemblers for genome guided transcript assembly:
        - [StringTie](https://ccb.jhu.edu/software/stringtie/index.shtml): [`05stringtie.sh`](scripts/05stringtie.sh)
        - [Cufflinks](http://cole-trapnell-lab.github.io/cufflinks/cuffdiff/): [`06cufflinks.sh`](scripts/06cufflinks.sh)
        - [Class2](https://github.com/mourisl/CLASS): [`07class2.sh`](scripts/07class2.sh)
        - [Strawberry](https://github.com/ruolin/strawberry): [`08strawberry.sh`](scripts/08strawberry.sh)
        - [Trinity](https://github.com/trinityrnaseq/trinityrnaseq/wiki): [`09trinity.sh`](scripts/09trinity.sh)
   
    
    
