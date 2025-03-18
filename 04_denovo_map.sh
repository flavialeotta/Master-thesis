#!/bin/bash
# How to use:
# ./04_denovo_map.sh 03_filter/ populations.txt

# This script should be run in the 'Home' folder.

mypath=$1; # The first element provided is the path to the filtered reads (previous step).
populations=$2; # The second element provided is a .txt file containing two colomns: the invidual ID and the populations ID. 
# Example:
# ALP1_clean_fastp  ALP
# ALP2_clean_fastp  ALP
# CAN5_clean_fastp  CAN

# Creates the output folder if not already present.
mkdir -p 04_denovo; 

# Calls stacks: denovo_map.pl function on each population with optimal parameters found throught optimization.
denovo_map.pl --samples "$mypath" --popmap ./"$populations" --out-path 04_denovo/ --paired -m 4 -M 1 -n 1 -X "ustacks: --force-diff-len" \
-X "populations: --vcf" --threads 20 --min-samples-per-pop 0.80;

