 ***Note: There is a newer version gubbins (v2.3.4) which resolves the issue according to authors. Please find this post from the gubbins github page for more details.

This issue is already reported in gubbins github page for older versions, where it runs successfully for a set of fasta files and not for other set. Could not find much documentation to trace and resolve this error. This is the step which is throwing me the error:

gubbins -r -v seqnew.fa.gaps.vcf -a 100 -b 10000 -f test_gubbins/tmp/seqnew.fa -t seqnew.fa.iteration_1 -m 3 seqnew.fa.gaps.snp_sites.aln
Failed while running Gubbins. Please ensure you have enough free memory

After the parsnp alignment, i used the parsnp.fasta (seqnew.fasta here), to run the following steps. By breaking the alignment into shorter chunks I could successfully run gubbins. After the gubbins is run for all chunks, I combined them and plotted a phylogenetic tree. Commands I used are:

1) Formatting the alignment fasta file
```
$ fasta_formatter -i seqnew.fa -o seqnew.oneline.fa -w 0 ##convert multiple fasta file to single line fasta file
```

2) Split the alignment file
```
$ perl splitAlignment.pl

-rw-rw-r-- 1 ttsh ttsh 7.7M Nov  9 11:00 seqnew.oneline.fa_0
-rw-rw-r-- 1 ttsh ttsh 7.7M Nov  9 11:00 seqnew.oneline.fa_1
-rw-rw-r-- 1 ttsh ttsh 7.7M Nov  9 11:00 seqnew.oneline.fa_2
-rw-rw-r-- 1 ttsh ttsh 7.7M Nov  9 11:00 seqnew.oneline.fa_3
-rw-rw-r-- 1 ttsh ttsh 7.7M Nov  9 11:00 seqnew.oneline.fa_4
-rw-rw-r-- 1 ttsh ttsh 7.7M Nov  9 11:00 seqnew.oneline.fa_5
-rw-rw-r-- 1 ttsh ttsh 2.8M Nov  9 11:00 seqnew.oneline.fa_6
```
splitAlignment.pl can be found at this github page.

3) Run Gubbins on chunk of sequences
```
$ for d in {0..6}; do time nohup run_gubbins.py --prefix postGubbins_ecloacae_$d --thread 12 --verbose --tree_builder fasttree seqnew.oneline.fa_$d >>gubbins.log 2>&1; done
```

4) Convert the alignment file into one line fasta format using fastx_toolkit
```
$ for d in {0..6}; do fasta_formatter -i postGubbins_ecloacae_$d.filtered_polymorphic_sites.fasta -o postGubbins_ecloacae_$d.filtered_polymorphic_sites.fasta_fastx -w 0; done

-rw-rw-r-- 1 ttsh ttsh 1.2M Nov  9 11:31 postGubbins_ecloacae_0.filtered_polymorphic_sites.fasta_fastx
-rw-rw-r-- 1 ttsh ttsh 1.3M Nov  9 11:31 postGubbins_ecloacae_1.filtered_polymorphic_sites.fasta_fastx
-rw-rw-r-- 1 ttsh ttsh 1.5M Nov  9 11:31 postGubbins_ecloacae_2.filtered_polymorphic_sites.fasta_fastx
-rw-rw-r-- 1 ttsh ttsh 1.3M Nov  9 11:31 postGubbins_ecloacae_3.filtered_polymorphic_sites.fasta_fastx
-rw-rw-r-- 1 ttsh ttsh 1.3M Nov  9 11:31 postGubbins_ecloacae_4.filtered_polymorphic_sites.fasta_fastx
-rw-rw-r-- 1 ttsh ttsh 1.2M Nov  9 11:31 postGubbins_ecloacae_5.filtered_polymorphic_sites.fasta_fastx
-rw-rw-r-- 1 ttsh ttsh 397K Nov  9 11:31 postGubbins_ecloacae_6.filtered_polymorphic_sites.fasta_fastx
```
5) Combine the alignment files

```
$ perl combinedAlignedfasta.pl 
```

combinedAlignedfasta.pl  can be found at this github page.

6) You can skip to the 7th step by converting aligned fasta file to newick or .tre file using  phylogenetic tree inferring softwares like fasttree or RaxML.
```
$ FastTree -nt postGubbins_seqnew_ecloacae.filtered_polymorphic_sites.fasta > postGubbins_seqnew_ecloacae.filtered_polymorphic_sites.tre
```
7) Used MEGA software to open the .tre file and plot the phylogenetic tree.

8) To change fasta file name to phyloID names, used a script taken from biostars.
```
$ perl script.pl PhyloIDs.txt postGubbins_seqnew_ecloacae.filtered_polymorphic_sites.tre >postGubbinsChunk.filtered_polymorphic_sitesv2.tre
```
script.pl can be found here: https://www.biostars.org/p/76972/#76975

Note: *" " in the above one liner of cut command are tabs
