module load blast-plus/2.11.0

makeblastdb -in Plant.Uniprot.fa -dbtype prot -out Uniptot.db -title Uniptot.db -hash_index
blastp -outfmt 6 qseqid sseqid qlen qstart qend slen sstart send evalue bitscore score length pident nident gaps \
       -db Uniptot.db \
       -query B73.faa \
       -out Araport11.bl.out \
       -num_threads 64
