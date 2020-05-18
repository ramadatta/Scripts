# Prakki Sai Rama Sridatta

# May 18th, 2020

# Create dendrogram using r functions

# 1) plot.hclust(): R base function
# 2) ggdendrogram

df <- read.csv("EColiSt131.csv",sep = ",", header = TRUE, row.names = 1)
head(df)

# Compute distances and hierarchical clustering
dd <- dist(scale(df), method = "euclidean")
hc <- hclust(dd, method = "ward.D2")

# Default plot
plot(hc)

plot(hc, hang = -1, cex = 0.6)

# Using dendrogram
q <- ggdendrogram(hc, rotate = TRUE, theme_dendro = FALSE)
pdf(file = "st131_My_Plot_binary.pdf",   # The directory you want to save the file in
    width = 10, # The width of the plot in inches
    height = 40) #
q

dev.off()
