#!/bin/bash

# Randomly select a one plasmid from Nanopore database
# $ grep -Po "\|.*\|" NDM_NP_Plasmids.txt  | sed 's/|//g' | shuf -n 1 pulls out a random NP plasmid from list

#This many random Nanopore plasmids are allowed to be in the plasmidseeker results, Rest all plasmids are masked. The higher number we give, the call rate should be better because more isolates will be called with some plasmids
`rm Random_NP.*Assignments.txt`;

for PickPlasmids in {1..3} # Total Plasmids
do
echo "--------Picking_Plasmids_$PickPlasmids---------";
#PickPlasmids=60; 
for iteration in {1..3} #100 iteration for each plasmid pick
do

	if [ $PickPlasmids == 1 ]
	then
	Random_NP=`grep -Po "\|.*\|" NDM_NP_Plasmids.txt  | sed 's/|//g' | shuf -n $PickPlasmids`;
	echo "$Random_NP";
	#`rm PickPlasmids.txt`;
	#`grep -Po "\|.*\|" NDM_NP_Plasmids.txt  | sed 's/|//g' | shuf -n $PickPlasmids >PickPlasmids.txt`;

	elif [ $PickPlasmids -gt 1 ]
	then
	Random_NP=`grep -Po "\|.*\|" NDM_NP_Plasmids.txt  | sed 's/|//g' | shuf -n $PickPlasmids | tr '\n' '|' | sed 's/.$//'`;
	echo "$Random_NP";
	#`rm PickPlasmids.txt`;
	#`grep -Po "\|.*\|" NDM_NP_Plasmids.txt  | sed 's/|//g' | shuf -n $PickPlasmids >PickPlasmids.txt`;
	#echo "$Random_NP";

	else
	   echo "You entered a zero plasmid pick up which is not valid. Sorry";
	   exit 1;
	fi

	total_Isolates=`ls *_CPContig_Plasmid_KCov_OCoef_W-Score.txt | wc -l`;



	`rm *parsed*`;



	for d in $(ls *_CPContig_Plasmid_KCov_OCoef_W-Score.txt);

	do

	baseName=`echo $d | sed 's/_CPContig_Plasmid_KCov_OCoef_W-Score.txt//g'`;
	echo -n "$baseName	";

	# Mask all other Nanopore plasmids in the W-score file except the randomly selected plasmid
	LC_ALL=C fgrep -v 'DU_DU' "$baseName"_CPContig_Plasmid_KCov_OCoef_W-Score.txt >"$baseName"_W-Score_parsed.txt #Genbank plasmids
	echo "$Random_NP"
	egrep "$Random_NP" "$baseName"_CPContig_Plasmid_KCov_OCoef_W-Score.txt >>"$baseName"_W-Score_parsed.txt #Random plasmids added

	## This sorts the added Nanopore plasmid according to W-score
	cat "$baseName"_W-Score_parsed.txt | sort -grk8,8 >"$baseName"_W-Score_parsed_sorted.txt 

	# Select the best possible hit for a sample 
	perl Plasmidseeker_W-score_v12_Ocoeff_enhancement.pl "$baseName"_W-Score_parsed_sorted.txt

	echo "";

	done | sed '/^$/d' >Random_NP_"$PickPlasmids"_Iteration"$iteration"_Assignments.txt

	awk '$6>=90 && $7>=90' Random_NP_"$PickPlasmids"_Iteration"$iteration"_Assignments.txt >Random_NP_"$PickPlasmids"_Iteration"$iteration"_90kcov_90ocoeff_Assignments.txt
	Isolates_called=`awk '$6>=90 && $7>=90' Random_NP_"$PickPlasmids"_Iteration"$iteration"_Assignments.txt | wc -l`; #KMER cutoff & Qverlapping Coefficient
	#callrate=$(($Isolates_called*100/$total_Isolates))
	callrate=`echo "scale=7; $Isolates_called*100/$total_Isolates" | bc -l | awk '{printf "%.4f\n", $0}'`;
	#echo "call rate: $callrate, Isolates_called: $Isolates_called, Total_Isolates: $total_Isolates";
	echo "$callrate";

	`rm *_W-Score_parsed.txt`;

done

done

#For formatting
#cat bs_values.txt | pr -ts" " --columns 3 | column -t

