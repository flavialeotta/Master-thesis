#!/bin/bash
# How to use:
# ./03bis_renaming.sh 03_filter/ readpairs.txt

# This script should be run in the 'Home' folder.

mypath=$1; # The first element provided is the path to the filtered reads (previous step).
readpairs=$2; # The second element provided is the .txt file containing the individuals IDs.

# Debugging messages in case the directory or the file provided don't exist.
if [ ! -d "$mypath" ]; then
    echo "Directory $mypath not found.";
    exit 1;
fi
if [ ! -f "$readpairs" ]; then
    echo "File $readpairs not found.";
    exit 1;
fi

# For loop that parses through all individuals ID. The ID is called "pair".
for pair in $(cat "$readpairs")
do
    # Moves to the filtered reads folder.
    cd $mypath;

    # Prints a message when the renaming process starts.
    echo "Renaming $pair...";

    # Creates the "old" name for the files.
    forward="$pair"".1_clean_fastp.1.fq.gz";
    reverse="$pair"".2_clean_fastp.2.fq.gz";

    # Creates the new name as stacks: denovo_map.pl (next step) expectes them to be
    new_forward="$pair""_clean_fastp.1.fq.gz";
    new_reverse="$pair""_clean_fastp.2.fq.gz";
    
    # If both files exist, they are renamed.
    if [ -f "$forward" ] && [ -f "$reverse" ]; then
        mv $forward $new_forward;
        mv $reverse $new_reverse;

        echo "Files renamed successfully:";
        echo "$forward"" -> ""$new_forward";
        echo "$reverse"" -> ""$new_reverse";
    else
        # Else the reads pair is skipped.
        echo "One or both files for $pair do not exist, skipping $pair altogether..";
    fi
done

# When everything is done, it moves back to the home folder.
cd ..;