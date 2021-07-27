# Extract Putative Circular Plasmids from Unicycler Assemblies.sh

mkdir putativePlasmids_fromStudy

for filename in $(ls *.fasta); 

do 


	base=`echo $filename | sed 's/_unicycler.gte1kb.contigs.fasta//g'`; #Contains fasta filename
	echo -e "----Step1/5 working on "$base" sample to extract putative plasmids------\n\n"


	time awk 'BEGIN {RS=">"} /circular/ {print ">"$0}' "$base"_unicycler.gte1kb.contigs.fasta | reformat.sh in=stdin.fa out="$base"_plasmids.fa minlen=3000 maxlen=1000000
	echo -e "----Step2/5 filtering for plasmids in "$base"_putativePlasmid------\n\n"
	
	mkdir "$base"_putativePlasmid;
	echo -e "----Step3/5 making directory "$base"_putativePlasmid------\n\n"

	cd "$base"_putativePlasmid;

	echo -e "----Step4/5 writing plasmids into "$base"_putativePlasmid------\n\n"
	while read line
		do
		    if [[ ${line:0:1} == '>' ]]
		    then
			#outfile=${line#>}.fa
			modLine=`echo $line | sed -e "s/>/>"$base"_/g" -e 's/_depth=.*x_/_/g' -e 's/=/_/g' -e 's/_circular_true/_circ_plasmid/g' -e 's/length/len/g'`
			outfile=${modLine#>}.fa
			#echo $line > $outfile
			echo $modLine > $outfile
		    else
			echo $line >> $outfile
		    fi
		done < ../"$base"_plasmids.fa;

		rm ../"$base"_plasmids.fa;

		echo -e "----Step5/ moved plasmids "$base" sample to putativePlasmids_fromStudy------\n\n"
		mv *plasmid.fa ../putativePlasmids_fromStudy
		cd ..;
		rmdir "$base"_putativePlasmid
done		
