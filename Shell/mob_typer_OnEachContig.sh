# This bash script will run mob_typer on each of the contig in the assembly file.

# Author: Prakki Sai Rama Sridatta

# May 06, 2020

#!/bin/bash

for filename in $(ls *.fasta); do 

echo $filename; #Contains fasta filename

mkdir "$filename"_Mob;

	cd "$filename"_Mob;

	while read line
		do
		    if [[ ${line:0:1} == '>' ]]
		    then
			outfile=${line#>}.fa
			echo $line > $outfile
		    else
			echo $line >> $outfile
		    fi
		done < ../$filename;

	for contigs in $(ls *.fa); 
	
		do
		echo "##########------Working on $filename and $contigs-----------------############"
		mob_typer --infile $contigs --outdir "$contigs"_out_dir;
		done

	cat */*report* >"$filename".Mob_report.txt

	awk '!unique[$1$2$3$4]++' "$filename".Mob_report.txt > tmp && mv tmp "$filename".Mob_report.txt

	cd ..;

done
