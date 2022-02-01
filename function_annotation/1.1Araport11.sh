module load blast-plus/2.11.0

makeblastdb -in Araport11.faa -dbtype prot -out Araport11.db -title Araport11.db -hash_index
blastp -outfmt 6 qseqid sseqid qlen qstart qend slen sstart send evalue bitscore score length pident nident gaps \
       -db Araport11.db \
       -query B73.faa \
       -out Araport11.bl.out \
       -num_threads 64
