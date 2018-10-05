# September 13, 2018

# Find connected components from connected pairs

# This script takes in "Pair1\tPair2\tSimilarity_score" and cluster the pairs which have threshold similirity cutoff
# The final output contains unique list of pairs and their corresponding cluster number


library(igraph)
library(ggplot2)

data <- read.table("connected_pairs.list")
head(data)

colnames(data) <- c("Pair1","Pair2","Similarity")
head(data)

Pairs_gteq80 <- subset(data,data$Similarity >= 80, select = Pair1:Pair2) ##Minimum 80% 

head(Pairs_gteq80) 

g1 <- graph.data.frame(Pairs_gteq80, directed = FALSE)
g1
plot(g1)
cl1 <- clusters(g1)

tbl1 <- cbind( V(g1)$name, cl1$membership )
tbl1
write.table(tbl1,file="Samples_ClusterNumber.txt",row.names=FALSE) # drops the rownames and write to text file
