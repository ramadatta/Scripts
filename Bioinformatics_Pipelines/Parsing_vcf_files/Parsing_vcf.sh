

grep -v '^##' varGolden-read-map.flt.vcf ## Will ignore all the sequence names at the top 

grep -v '^##' varGolden-read-map.flt.vcf | awk '$6 >= 30' ## Sort the quality value in the 6th column

#=========#
#Now in DP#
#=========#

grep -v '^##' varGolden-read-map.flt.vcf | awk '$6 >= 30' | awk 'FS = ":" { if ($(NF-1) >= 10) print $0 }' >varGolden-read-map.Quality_filtered.txt

#ignores lines those with seq names#

					#quality >= 30#
							   #Field Sepeartor is ":"
								# take last but one column, check if quality >=10

														##Writing to a new file

#==============#
#Now in DPTotal#
#==============#

grep -v '^##' test.vcf | awk '$6 >= 30' | awk ' $8 ~ /DP=/ {split($0,tmp,/[=;]/); if(tmp[2]>10) print $0}'

grep -v '^##' varGolden_Green_Red-read-map.flt.vcf \|
awk '$6 >= 30' \| 
awk ' $8 ~ /DP=/ {split($0,tmp,/[=;]/); if(tmp[2]>10) print $0}' >varGolden_Green_Red-read-map_Quality_filtered.txt

Check if 8th column contains DP and check if its value >=10

grep -v '^##' varGolden_Green-read-map.flt.vcf | head -1 >varGolden_Green-read-map_Quality_filtered.txt
grep -v '^##' varGolden_Green-read-map.flt.vcf | awk '$6 >= 30' | awk ' $8 ~ /DP=/ {split($0,tmp,/[=;]/); if(tmp[2]>=10) print $0}' >>varGolden_Green-read-map_Quality_filtered.txt

grep -v '^##' varRed_Golden-read-map.flt.vcf  | head -1 >varRed_Golden-read-map_Quality_filtered.txt
grep -v '^##' varRed_Golden-read-map.flt.vcf | awk '$6 >= 30' | awk ' $8 ~ /DP=/ {split($0,tmp,/[=;]/); if(tmp[2]>=10) print $0}' >>varRed_Golden-read-map_Quality_filtered.txt

grep -v '^##' varRed_Green-read-map.flt.vcf | head -1 >varRed_Green-read-map_Quality_filtered.txt
grep -v '^##' varRed_Green-read-map.flt.vcf | awk '$6 >= 30' | awk ' $8 ~ /DP=/ {split($0,tmp,/[=;]/); if(tmp[2]>=10) print $0}' >>varRed_Green-read-map_Quality_filtered.txt

grep -v '^##' varGolden_Green_Red-read-map.flt.vcf | head -1 >varGolden_Green_Red-read-map_Quality_filtered.txt
grep -v '^##' varGolden_Green_Red-read-map.flt.vcf | awk '$6 >= 30' | awk ' $8 ~ /DP=/ {split($0,tmp,/[=;]/); if(tmp[2]>=10) print $0}' >>varGolden_Green_Red-read-map_Quality_filtered.txt


##Preprending a line in the file
sed -i '1i #CHROM     POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT   Golden-read-map.sort.bam        Green-read-map.sort.bam Red-read-map.sort.bam' *Col*
