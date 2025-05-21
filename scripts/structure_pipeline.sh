#!/bin/bash

# Script to run structure

for K in {1..20}; do
	for rep in {1..5}; do
		mkdir -p structure_K${K}
		structure -i noheader.structure -K $K -N 103 -L 3896 \
		-m mainparams.txt -e extraparams.txt \
		-B 20000 -M 80000 -D $RANDOM -o structure_K${K}/run${rep}
	done
done

