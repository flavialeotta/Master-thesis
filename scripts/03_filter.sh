#!/bin/bash
# How to use:
# ./03_filter.sh 02_clean_fastp/ readpairs.txt

# This script should be run in the 'Home' folder.

mypath=$1; # The first element provided is the path to the cleaned reads (previous step).
readpairs=$2; # The second element provided is the .txt file containing the individuals IDs.

# Create the name of the folder that contains the cleaned reads.
myfolder="$(echo $mypath | rev | cut -d "/" -f 2 | rev)";

# Creates the output folder if it wasn't already created.
mkdir -p 03_filter

# For loop that parses through all individuals ID. The ID is called "pair".
for pair in $(cat "$readpairs")
do
    echo "filtering $pair...";

    # Creates the name of the forward and reverse reads. 
    # This expects that files weren't renamed after the previous step.
    forward="$pair"".1_clean_fastp.fq.gz";
    reverse="$pair"".2_clean_fastp.fq.gz";

    # Calls stacks: process_radtags for each individual. The sequences of the personalised adapters are provided.
    process_radtags -1 "$mypath""$forward" -2 "$mypath""$reverse" -o ./03_filter/ -e apeKI -r -c -q \
      --adapter-1 AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGTCTGATCGTAGATCTCGGTGGTCGCCGTATCATT \
      --adapter-2 AGATCGGAAGAGCACACGTCTGAACTCCAGTCACGCGCATATATCTCGTATGCCGTCTTCTGCTTG --threads 20;
    
    # Move to the output folder.
    cd 03_filter;

    # Rename the log, adding the individual ID.
    mv "process_radtags.log" "process_radtags.""$pair"".log";

    # Move back to the home folder, and repeat.
    cd ../;
done

# Move to the output folder and, if it's not present, create a folder for the unpaired reads.
cd 03_filter;
if [ ! -d unpaired_reads ]; then
    mkdir unpaired_reads;
fi

# If there's no folder for the logs, create it.
if [ ! -d logs ]; then
    mkdir logs;
fi

# Move all the files containing "rem" in their name, to the folder for the unpaited reads.
mv *rem* unpaired_reads/;


for pair in $(cat "../""$readpairs")
do
    touch "summary_""$pair";
    echo "$pair" > "summary_""$pair";
    stacks-dist-extract "process_radtags.""$pair"".log" total_raw_read_counts | cut -f 1,3 --complement >> "summary_""$pair";
done
mv process_radtags* logs/;
mv summary_* logs/;
paste logs/summary_* > summary_total.txt;
cd ..;

