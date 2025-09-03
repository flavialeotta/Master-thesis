#!/bin/bash
# expects a path in the form a/b/c/folder_with_files/, a reference for bwa,
# and a file with names of read pairs
mypath=$1;
reference=$2;
readpairs=$3;
myfolder="$(echo $mypath | rev | cut -d "/" -f 2 | rev)";
#echo $myfolder;
for pair in $(cat "$3")
do
    echo "mapping $pair...";
    forward="$pair"".1_clean.1.fq.gz";
    reverse="$pair"".2_clean.2.fq.gz";
  #  echo "$forward";
  #  echo "$reverse";
    bwa mem -t 24 "$reference" "$mypath""$forward" "$mypath""$reverse" \
       | samtools view -Sb -o "$pair"".bam" -

    samtools flagstat "$pair"".bam" > "$pair"".flag";
    samtools stats "$pair"".bam" > "$pair"".stats";
done
