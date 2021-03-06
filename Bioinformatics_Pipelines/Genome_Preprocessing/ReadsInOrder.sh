##put the reads in order

#Usage: ReadsInOrder.sh forward.sh reverse.sh

#Source: Used a part of code from online scripts found in seqanswers.com and modified according to my need.

##Map common reads

#basename1=` echo $1 | sed s/.fastq// `
#basename2=` echo $2 | sed s/.fastq// `
basename1=` echo $1 `
basename2=` echo $2 `

adapter1=`head -1 $basename1 | grep -o '.\:.\:.\:......'`
adapter2=`head -1 $basename2 | grep -o '.\:.\:.\:......'`
echo "$adapter1 $adapter2"

#`echo $adapter1`
awk '{if($0~/@HISEQ/){if(i>0){printf "\n"$0}else{printf $0}}else{printf "\t"$0};i++}END{printf "\n"}' $1 > $basename1"_tab.tab"
awk '{if($0~/@HISEQ/){if(i>0){printf "\n"$0}else{printf $0}}else{printf "\t"$0};i++}END{printf "\n"}' $2 > $basename2"_tab.tab"
#sort $basename1"_tab.txt" > $basename1"_sorted_tab.txt"
#sort $basename2"_tab.txt" > $basename2"_sorted_tab.txt"

#sed -i "s/ 1.*//g" $basename1"_tab.txt"
#sed -i "s/ 2.*//g" $basename2"_tab.txt"

awk -F "\t" '{split($1,a," ");print a[1]"\t"$2"\t"$3"\t"$4;}' $basename1"_tab.tab" >$basename1"_tab.txt"
#adapter1=${a[2]} 
awk -F "\t" '{split($1,a," ");print a[1]"\t"$2"\t"$3"\t"$4;}' $basename2"_tab.tab" >$basename2"_tab.txt"
#adapter2=${a[2]} 

sort -t "`echo  $'\t'`" -f -k 1,1 $basename1"_tab.txt" > $basename1"_sorted_tab.txt"
sort -t "`echo  $'\t'`" -f -k 1,1 $basename2"_tab.txt" > $basename2"_sorted_tab.txt"

#sed -i "s/ 1.*//g" $basename1"_sorted_tab.txt" \"${x}_${y}\"}
#sed -i "s/ 2.*//g" $basename2"_sorted_tab.txt"

join -t "`echo $'\t'`" -1 1 -2 1 $basename1"_sorted_tab.txt" $basename2"_sorted_tab.txt" | awk -F "\t" -v basename1=$basename1 -v basename2=$basename2  -v adapter1=$adapter1 -v adapter2=$adapter2 '{print $1" "adapter1"\n"$2"\n"$3"\n"$4 > basename1"_matched.fastq"; print $1" "adapter2"\n"$5"\n"$6"\n"$7 > basename2"_matched.fastq"}'

join -t "`echo $'\t'`" -v 1 -1 1 -2 1 $basename1"_sorted_tab.txt" $basename2"_sorted_tab.txt" | awk -F "\t" -v basename1=$basename1 -v adapter1=$adapter1 '{print $1" "adapter1"\n"$2"\n"$3"\n"$4 > basename1"_ORPHAN.fastq"}'

join -t "`echo $'\t'`" -v 2 -1 1 -2 1 $basename1"_sorted_tab.txt" $basename2"_sorted_tab.txt" | awk -F "\t" -v basename2=$basename2 -v adapter2=$adapter2 '{print $1" " adapter2"\n"$2"\n"$3"\n"$4 > basename2"_ORPHAN.fastq"}'

rm $basename1"_tab.tab"
rm $basename2"_tab.tab"
rm $basename1"_tab.txt"
rm $basename2"_tab.txt"
rm $basename1"_sorted_tab.txt"
rm $basename2"_sorted_tab.txt"


