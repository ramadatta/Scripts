# This bash script will split a fasta file and rename each individual filename with AssemblyName and ContigName

# Example: A ENT001.fasta has 3 contigs 1,2,3. Running this script will generate ENT001_Contig1.fasta, ENT001_Contig2.fasta, ENT001_Contig3.fasta

# Author: Prakki Sai Rama Sridatta

# Aug 20, 2020

# Usage
# Go to the folder location with .fasta files
# ./splitNanoporeFasta.sh

#!/bin/bash

if [ "$1" == "-h" ]; then

  echo "Example:"
  echo ""		
  echo "Move to fasta file folder. A ENT001.fasta has 3 contigs 1,2,3. Running this script will generate:"
  echo "ENT001_Contig1.fasta"
  echo "ENT001_Contig2.fasta"
  echo "ENT001_Contig3.fasta"
  echo ""		
  echo "Usage: ./splitNanoporeFasta.ah"
  exit 0
fi

for filebase in $(ls *.fasta | sed 's/.fasta//g'); do 

SECONDS=0

cp "$filebase".fasta "$filebase"_renamed.fasta;

echo "Renaming $filebase.fasta"; 

mkdir "$filebase"_Contigs;

	mv "$filebase"_renamed.fasta "$filebase"_Contigs;
	
	cd "$filebase"_Contigs

	sed -i 's/>/>Ctg/g' "$filebase"_renamed.fasta &
	wait $(jobs -rp)

	sed -i  's/ /_/g' "$filebase"_renamed.fasta &
	wait $(jobs -rp)

	sed -i 's/length=/len_/g' "$filebase"_renamed.fasta &
	wait $(jobs -rp)

	sed -i 's/_circular=true/_circ/g' "$filebase"_renamed.fasta &
	wait $(jobs -rp)

	sed -i 's/_depth=/_depth_/g' "$filebase"_renamed.fasta &
	wait $(jobs -rp)

	echo "Done with renaming $filebase.fasta"; 
	echo "";
	echo "Splitting "$filebase"_renamed.fasta"; 

	counter=0;

	while read line
		do
		    if [[ ${line:0:1} == '>' ]] # If a line contains '>' (header)
		    then
			counter=`expr $counter + 1`
			outfile=$counter.fa 			
			echo $line > "$filebase"_"$outfile"
		    else
			echo $line >> "$filebase"_"$outfile"
		    fi
		done < "$filebase"_renamed.fasta 

	rm "$filebase"_renamed.fasta

	#echo "";
	#echo "Done with splitting "$filebase".fasta"; 

	cd ..;

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed for splitting "$filebase".fasta."
echo "";

done
