library(reshape2)

# Example input.txt
# Year	Species	Count
# 2012	ecoli	2
# 2012	kpneumoniae	4
# 2013	cronobacter	1
# 2013	ecloacae	1
# 2013	kpneumoniae	8
# 2014	cfreundii	2
# 2014	ecoli	2

# Matrix output
#     cfreundii cronobacter ecloacae ecoli kpneumoniae
# 2012         0           0        0     2           4
# 2013         0           1        1     0           8
# 2014         2           0        0     2           0


#Species
setwd("~/Desktop/test")
df <- read.table("input.txt",header = TRUE, sep = "\t")
head(df)
d <- acast(df, Year~Species, value.var="Count")
d[is.na(d)] <- 0
d

##Hospital
df <- read.table("input.txt",header = TRUE, sep = "\t")
head(df)
d <- acast(df, Year~Hospital, value.var="Count")
d[is.na(d)] <- 0
d

