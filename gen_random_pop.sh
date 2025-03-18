#!/bin/bash

LOG_FILE="$HOME/flavia_leotta/GBS_DATA/log_combinations.tsv"


for i in {1..1}; do
	m=$((RANDOM % 5 + 2)) # In bash, RANDOM generates a number between 0 and 32767, you can add an offset and you can also give a range using %
	M=$((RANDOM % 5))
	n=$((RANDOM % 5))

	echo "Checking if the combination $m $M $n has already been evaluated..."
	if grep -q -P "^$m\t$M\t$n\t" "$LOG_FILE"; then
        	echo "The combination m=$m, M=$M, n=$n has already been explored. Skipping it..."
        	continue
	else
		echo "Proceeding with combination m=$m, M=$M, n=$n."
		mkdir -p 04_denovo
		denovo_map.pl --samples 03_filter/ --popmap ./populations.txt --out-path 04_denovo/ --paired -m "$m" -M "$M" -n "$n" -X "ustacks: --force-diff-len" -X "populations: --vcf" --threads 30 --min-samples-per-pop 0.80
		cd 04_denovo/
		"$HOME"/flavia_leotta/GBS_DATA/add_to_log.sh
		cp denovo_map.log denovo_map_$m_$M_$n.log
		mv denovo_map_$m_$M_$n.log "$HOME"/flavia_leotta/GBS_DATA/log_denovo/
		cd ..
		rm -rf 04_denovo
	fi
done
