#!/bin/bash
# How to use:
# ./demultiplex.sh path/to/read1.fq.gz èath/to/read2.fq.gz barcodes.txt

# This script should be run in the 'Home' folder.

read1=$1; # The first element provided is read 1.
read2=$2; # The second element provided is read 2.
barcode_file=$3; # The third element provided is the individual-specific barcodes.

# Create the output folder if it wasn't already present.
mkdir -p 01_demulti

# Stacks: process_radtags is called on the files that are provided, with /01_demulti/ as output folder.
process_radtags -1 "$1" -2 "$2" -o ./01_demulti/ -b "$barcode_file" -e apeKI -r --threads 4 -y 'gzfastq';

# After running process_radtags, we move to the output folder.
cd 01_demulti

# If the directory containing unpaired reads is not there, it is created.
if [ ! -d unpaired_reads ]; then
    mkdir unpaired_reads;
fi

# Moves all files that contain 'rem' in their name (which are the unpaired reads) in that folder.
mv *rem* unpaired_reads/;

# Prints a finishing message.
echo "Finished de-multiplexing."
