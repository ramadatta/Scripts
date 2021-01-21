library(ape)
library(dplyr)
library(reshape2)


## Read in fasta file
    data <- read.FASTA(file = "postGubbins.filtered_polymorphic_sites.fasta") # Read input multiple fasta file

## Calculate the pair-wise distance

    out <-  dist.dna(data,model="N",pairwise.deletion=TRUE,as.matrix=T) ## Full matrix
    out[lower.tri(out,diag=T)] <- NA ## take upper triangular matrix, when needed
   # out

D_out_melt = melt(as.matrix(out), varnames = c("row", "col"))
#D_out_melt

names(D_out_melt) <- c("Isolate1","Isolate2","SNPDiff")

D_out_melt_sorted = arrange(D_out_melt, SNPDiff)
#head(D_out_melt_sorted)

write.csv(D_out_melt_sorted, "postGubbins.filtered_polymorphic_sites_melt_sorted.csv")
