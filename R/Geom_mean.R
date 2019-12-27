## Finding Geometric mean

library("dplyr")

dd <- read.table("KP_Mash_Dist_Geom.out")
head(dd)

summarydf <- dd %>% group_by(V1) %>% summarise(Geo.MashMean=exp(mean(log(V3))))
head(summarydf)

write.table(summarydf, file = "KP_Mash_Dist_Geom_v2.out",row.names = FALSE)
                    
                         