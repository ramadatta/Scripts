### 1) Q20_Q30_Stats_wo_functions.pl

A simple script to calculate Total Bases, Q20 bases, Q30 bases, Mean Read Length of a fastq file (only unzipped fastq or fq)

```shell
perl Q20_Q30_Stats_wo_functions.pl <fastq_file_name>
```
#### output

```
time perl Q20_Q30_Stats_wo_functions.pl test.fq | column -t
fastq_file  Total_Reads  Total_Bases  Total_Q20_Bases  Total_Q30_Bases  Mean_ReadLen
test.fq     5            750          736              707              150
```

### 2) ClustrPairs_v3.pl

##### A perl script to find the connected components. Data Should look like and should be delimted by tab and passed from a file:

```
Simon John
Simon Paul
Steve Simon
Graham Dave
Dave Jason
Paul Simon
Peter Derek
```

```shell
perl ClustrPairs_v3.pl <pairsFile.list>
```
#### output

```
-----Cluster:1-------
John
Simon
Paul
Steve
-----Cluster:2-------
Jason
Dave
Graham
-----Cluster:3-------
Peter
Derek

```
3) arrangeCol2row.pl
4) intersect_lists.pl
readme.md
5) replaceAmbigousBases2N.pl
6) skipOverlappingIntervals3.pl
7) splitFiles_incrementally.pl
8) uniq_Intersection_elements.pl
