#!/bin/bash

module load aspera

if [ $# -lt 1 ] ; then
        echo ""
        echo "usage: downloadSRA_ebi.sh <FILE> "
        echo ""
        echo "FILE should contain list of SRR ids, one per line"
        echo "downloads the SRR file from the ebi server"
        echo "considers if the file is single-end or paired-end and downloads"
        echo ""
exit 0
fi

file="$1"
while read line; do
num=$(echo "${line: -1}")
part=$(echo "${line::6}")

if [[ $(echo -n $line | wc -m) -eq 10 ]]; then
  folder=$(echo "era-fasp@fasp.sra.ebi.ac.uk:/vol1/fastq/${part}/00${num}/${line}")
else
  folder=$(echo "era-fasp@fasp.sra.ebi.ac.uk:/vol1/fastq/${part}/${line}")
fi


if [[ -e ${line}_1.fastq.gz && ${line}_1.fastq.gz ]]; then
    echo "${line} already exits"
else
    ascp -i /shared/hpc/aspera/cli/3.7.7/etc/asperaweb_id_dsa.openssh -P33001 -QT -l 500m $folder/${line}_1.fastq.gz $folder/${line}_2.fastq.gz .
    echo "${line} download finish"
fi
done<$file
