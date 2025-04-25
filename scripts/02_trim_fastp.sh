#!/bin/bash
# How to use: 
# ./02_trim_fastp.sh path_to_reads/ readpairs.txt adapters.txt

# This script should be run in the 'Home' folder.

mypath=$1; # The first element provided is the path to the de-multiplexed reads (previous step).
adapters=$3; # The second element provided is the .txt file containing the fasta sequences of adapters.
readpairs=$2; # The third element provided is the .txt file containing the individuals IDs.

# Creates the output directory if not present already.
mkdir -p 02_clean_fastp

# For loop that parses through all individuals ID. The ID is called "pair".
for pair in $(cat "$readpairs")
do
    # Messages for, if necessary, debugging.
    echo "";
    echo "Trimming $pair...";

    # Creates the names of the read pairs.
    forward="$pair"".1.fq.gz";
    reverse="$pair"".2.fq.gz";
    
    # Creates the new names for the cleaned pairs.
    fwname="$(basename -s .fq.gz "$forward")""_clean_fastp.fq.gz";
    rvname="$(basename -s .fq.gz "$reverse")""_clean_fastp.fq.gz";
    
    # Calls fastp on each individual.
    fastp --in1 "$mypath""$forward" --in2 "$mypath""$reverse" --out1 "02_clean_fastp/""$fwname" --out2 "02_clean_fastp/""$rvname" \
    --thread 16 --dont_eval_duplication --length_required 50 --trim_poly_g --poly_g_min_len 5 --cut_tail --cut_tail_window_size 2 \
    --cut_tail_mean_quality 30 --cut_front --cut_front_window_size 2 --cut_front_mean_quality 30 --adapter_fasta "$adapters";

    # Prints a message when it's finished.
    echo "Finished ""$pair"".";
done

# Prints a finishing message.
echo "Finished cleaning."