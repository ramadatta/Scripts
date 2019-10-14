## This shell is needed to be run of after Plasmidseeker_wrapper.pl is finished running

for directory in $(ls -1d */); do 

echo -n "$directory	"; cd $directory; sed 's/ /_/g' *_plasmidseeker_results.txt >tmp_ps_results.txt; 

for d in $(cat Plasmid_list_for_QueryContigs_withAlignment_prcnt.txt | cut -f2 -d " " | sed 's/gbk://g' | sed 's/[A-Z]*_*[A-Z]*\([0-9]\{6\}\.[0-9]\{1,\}\_\)//g'); do grep -m1 "$d" tmp_ps_results.txt;  grep -m1 "$d" Plasmid_list_for_QueryContigs_withAlignment_prcnt.txt; echo ""; done | sed '/^$/d' | paste  - - | awk '{print $9,$10,$11,$12,$11/$12,$1,$2,$3}' | sort -nrk5,5 -nrk6,6  -nrk7,7 -nrk2,2 | column -t >intermin.txt;

for d in $(cat Plasmid_list_for_QueryContigs_withAlignment_prcnt.txt | cut -f2 -d " " | sed 's/gbk://g' | sed 's/[A-Z]*_*[A-Z]*\([0-9]\{6\}\.[0-9]\{1,\}\_\)//g'); do grep -m1 "$d" tmp_ps_results.txt;  grep -m1 "$d" Plasmid_list_for_QueryContigs_withAlignment_prcnt.txt; echo ""; done | sed '/^$/d' | paste  - - | awk '{print $9,$10,$11,$12,$11/$12,$1,$2,$3}' | sort -nrk5,5 -nrk6,6 -nrk7,7 -nrk2,2 | head -1 >Top_plasmid_inhouse_CPE_Criteria-Score.txt; ##CPE Tranmission

for d in $(cat Plasmid_list_for_QueryContigs_withAlignment_prcnt.txt | cut -f2 -d " " | sed 's/gbk://g' | sed 's/[A-Z]*_*[A-Z]*\([0-9]\{6,8\}\.[0-9]\{1,\}\_\)//g'); do grep -m1 "$d" tmp_ps_results.txt;  grep -m1 "$d" Plasmid_list_for_QueryContigs_withAlignment_prcnt.txt; echo ""; done | sed -e '/^$/d' -e 's/%//g' | paste  - - | awk '{print ($9,$10,$11,$12,$11/$12,$1,$2,$3,sprintf("%.2f",$1*$3*($11/$12)))}' | sort -nrk9,9 | head -1 >Top_plasmid_W-Score.txt;

cd ..; 

done 
