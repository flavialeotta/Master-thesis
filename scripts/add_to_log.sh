#!/bin/bash
# How to use:
# ./add_to_log.sh

# This script should be run in the output folder created in the step 04_denovo_map.sh.
# The log file /called log_combinations.tsv) should be located in the parent directory (the previous one from the 04_denovo/ folder).

# Gets the parent directory name.
PREV_DIR="$(cd ../ && pwd)";

# Get the path to the log file.
LOG_FILE="$PREV_DIR/log_combinations.tsv"

line=$(sed -n '2p' denovo_map.log)
m=$(echo $line | grep -oP '(?<=-m )\d')
M=$(echo $line | grep -oP '(?<=-M )\d')
n=$(echo $line | grep -oP '(?<=-n )\d')

echo "Extracted values m=$m, M=$M, n=$n."

if [ ! -f "$LOG_FILE" ]; then
	echo -e "m\tM\tn\tmean\tsd\tSNPs\tunique\tFAIL" > "$LOG_FILE"
fi

if grep -q -P "^$m\t$M\t$n\t" "$LOG_FILE"; then
	echo "The combination m=$m, M=$M, n=$n has already been explored. Skipping it..."
	exit 0
fi

read mean sd <<< $(stacks-dist-extract gstacks.log.distribs effective_coverages_per_sample | grep -v "#" | grep -v "sample" | awk '{sum+=$4; sumsq+=$4*$4; count++} END {if (count>0) {mean=sum/count; stddev=sqrt(sumsq/count - mean*mean); print mean, stddev} else {print "0 0"}}')

SNPs=$(grep -v "#" populations.snps.vcf | wc -l)

unique=$(grep -v "#" populations.snps.vcf | cut -f 1 | sort | uniq | wc -l)

FAIL=0
if (( $(echo "$unique < 2400" | bc -l) || $(echo "$mean < 10" | bc -l) )); then
	FAIL=5
fi

echo -e "$m\t$M\t$n\t$mean\t$sd\t$SNPs\t$unique\t$FAIL" >> "$LOG_FILE"
echo "Updated $LOG_FILE."
