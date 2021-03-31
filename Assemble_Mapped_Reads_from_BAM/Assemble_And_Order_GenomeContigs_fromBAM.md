##### Run SRST2 to generate sorted BAM file for the specific region "ICETn43716385"

```bash
srst2 --input_pe C00027_S1_L001_R1_001.fq C00027_S1_L001_R2_001.fq --output test_srst2 --log --gene_db ICETn43716385.fasta --threads 64
```
##### List 

``` bash
$ ls -1 test*
test_srst2__C00027.ICETn43716385.pileup
test_srst2__C00027.ICETn43716385.sorted.bam
test_srst2__fullgenes__ICETn43716385__results.txt
test_srst2__genes__ICETn43716385__results.txt
test_srst2.log
```

##### Subset BAM file

```
# R1 & R2 mapped
samtools view -u -f 1 -F 12 test_srst2__C00027.ICETn43716385.sorted.bam > test_srst2__C00027.ICETn43716385_R1_R2_properlymapped.bam

# R1 unmapped, R2 mapped

samtools view -u -f 4 -F 264 test_srst2__C00027.ICETn43716385.sorted.bam > test_srst2__C00027.ICETn43716385_R1_unmapped_R2_mapped.bam

# R1 mapped, R2 unmapped
samtools view -u -f 8 -F 260 test_srst2__C00027.ICETn43716385.sorted.bam > test_srst2__C00027.ICETn43716385_R1_mapped_R2_unmapped.bam
```
##### Merge the improperly mapped reads

Now, we merge the two files that contain at least one unmapped pair.

```bash
samtools merge -u test_srst2__C00027.ICETn43716385_R1_R2_improperlymapped.bam test_srst2__C00027.ICETn43716385_R1_unmapped_R2_mapped.bam test_srst2__C00027.ICETn43716385_R1_mapped_R2_unmapped.bam 
```
##### Sort BAM file

```bash
samtools sort -n test_srst2__C00027.ICETn43716385_R1_R2_properlymapped.bam test_srst2__C00027.ICETn43716385_R1_R2_properlymapped.sorted
samtools sort -n test_srst2__C00027.ICETn43716385_R1_R2_improperlymapped.bam test_srst2__C00027.ICETn43716385_R1_R2_improperlymapped.sorted
```
##### Extract Reads

```bash
bamToFastq -i test_srst2__C00027.ICETn43716385_R1_R2_properlymapped.sorted.bam -fq test_srst2__C00027.ICETn43716385_mapped.1.fastq -fq2 test_srst2__C00027.ICETn43716385_mapped.2.fastq 
bamToFastq -i test_srst2__C00027.ICETn43716385_R1_R2_improperlymapped.bam -fq test_srst2__C00027.ICETn43716385_unmapped.1.fastq -fq2 test_srst2__C00027.ICETn43716385_unmapped.2.fastq 
```

##### Repair the R1 and R2 in the from mapped.1.fastq and mapped.2.fastq

```bash
repair.sh in=test_srst2__C00027.ICETn43716385_mapped.1.fastq in2=test_srst2__C00027.ICETn43716385_mapped.2.fastq out=test_srst2__C00027.ICETn43716385_mapped.1.fastq.gz out2=test_srst2__C00027.ICETn43716385_mapped.2.fastq.gz repair
```

##### Assemble with Spades

```bash
time spades.py --pe1-1 test_srst2__C00027.ICETn43716385_mapped.1.fastq.gz --pe1-2 test_srst2__C00027.ICETn43716385_mapped.2.fastq.gz -o test_srst2__C00027_spades --careful -t 48 >>log_spades
```

##### Analyse
```bash
$ cd test_srst2__C00027_spades

$ grep '>' contigs.fasta
>NODE_1_length_39395_cov_57.560227
>NODE_2_length_20753_cov_58.547882
>NODE_3_length_4693_cov_65.703423
>NODE_4_length_3100_cov_75.803506
>NODE_5_length_2753_cov_111.396487
>NODE_6_length_695_cov_225.980583
>NODE_7_length_428_cov_126.928775
>NODE_8_length_362_cov_55.028070
>NODE_9_length_297_cov_3.054545
>NODE_10_length_252_cov_454.091429
>NODE_11_length_243_cov_3.975904
>NODE_12_length_241_cov_1.500000
>NODE_13_length_155_cov_97.692308

$ unicycler -1 test_srst2__C00027.ICETn43716385_mapped.1.fastq.gz -2 test_srst2__C00027.ICETn43716385_mapped.2.fastq.gz -o test_srst2__C00027_unicycler

$ grep '>' assembly.fasta
>1 length=39261 depth=1.00x
>2 length=20619 depth=1.02x
>3 length=4539 depth=1.11x
>4 length=2787 depth=1.08x
>5 length=2325 depth=1.33x
>6 length=695 depth=3.97x
>7 length=661 depth=4.29x
>8 length=297 depth=1.17x
>9 length=252 depth=8.14x
>10 length=159 depth=5.32x
```

##### Order the Contigs

```bash
perl ~/sw/abacas.1.3.1.pl -r ICETn43716385.fasta -q test_srst2__C00027_spades/contigs.fasta -p nucmer
```

Add BLAST image - between ICETn43716385.fasta and ordered contigs


