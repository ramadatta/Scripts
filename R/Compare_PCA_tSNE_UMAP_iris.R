# Packages

library(umap)
library(Rtsne)

library(ggplot2)
library(plotly)
library(factoextra)

library(tibble)
library(dplyr)
library(data.table)
library(DT)
library(crosstalk)

data(iris)

head(iris)

# Choose the numerical columns in the data
data_numcols <- iris %>% 
                select(where(is.numeric)) %>% 
                select_if(~ !any(is.na(.))) 

dim(data_numcols)

# Select the Species column

data_Species_col <-  iris %>% select(Species) %>% tibble::rowid_to_column("ID")
data_Species_col$ID <- as.factor(data_Species_col$ID) 
  
# Perform PCA with prcomp
pca_result = prcomp(data_numcols, scale = TRUE)
dim(pca_result$x)

#######------------Multiple labels---------###########
basic_plot <- fviz_pca_ind(pca_result, label="var") # Adding var gives nicer legend symbols than none

# Combine the Matrix with Metadata
basic_plot_with_meta <- left_join(basic_plot$data, data_Species_col, by = c("name" = "ID"))

head(basic_plot_with_meta)

p1_pca <- ggplot(basic_plot_with_meta,
                 aes(x=x,y=y,col=Species)) + geom_point(size=2, alpha = 0.6) +
  theme_bw() +
  #stat_ellipse(level=0.95,linetype=2) +
  ggtitle(paste0("PCA plot of iris species based on their sepal and petal width and lengths")) +
  xlab("PC1") +
  ylab("PC2")

p1_pca

ggplotly(p1_pca)
############################################# PCA DONE ##############################################################

############################################# TSNE ##############################################################
## Run the t-SNE algorithm and store the results into an object called tsne_results

tsne.norm <- Rtsne(data_numcols, check_duplicates = FALSE)
#View(tsne.norm)

tsne.norm2 <- as.data.frame(tsne.norm$Y[, 1:2]) %>% tibble::rowid_to_column("ID") %>% 
  rename(tsne1 = V1, tsne2 = V2) 

tsne.norm2$ID <- as.factor(tsne.norm2$ID)

basic_plot_with_meta_tSNE <- left_join(tsne.norm2, data_Species_col, by = c("ID"))

p2_tsne <- ggplot(basic_plot_with_meta_tSNE, aes(x = tsne1, y = tsne2, colour = Species)) + 
  geom_point(alpha = 0.3) + theme_bw()

ggplotly(p2_tsne)

##UMAP

umap_fit <- data_numcols %>% 
  scale() %>% 
  umap()


umap_fit2 <- as.data.frame(umap_fit$layout[, 1:2]) %>% tibble::rowid_to_column("ID") %>% 
  rename(umap1 = V1, umap2 = V2) 

umap_fit2$ID <- as.factor(umap_fit2$ID)

basic_plot_with_meta_umap <- left_join(umap_fit2, data_Species_col, by = c("ID")) #%>%  head()


p3_umap <- ggplot(basic_plot_with_meta_umap, aes(x = umap1, y = umap2, colour = Species)) + 
  geom_point(alpha = 0.3) + theme_bw()

ggplotly(p3_umap)

d <- highlight_key(basic_plot_with_meta_umap , ~ID)   

dataplot <- ggplotly(ggplot(d, aes(x = umap1, y = umap2, colour = Species)) + 
                       geom_point(alpha = 0.3) + theme_bw(), tooltip = "text" ) %>%
  highlight("plotly_selected", dynamic = TRUE)

#options(persistent = FALSE)
# 
library(DT) # data table
dataplot_dt <- datatable(d, extensions = 'Buttons', options = list(
  dom = 'Blfrtip',
  buttons = c('copy', 'csv', 'excel', 'pdf'),
  lengthMenu = list(c(10,30, 50, -1), 
                    c('10', '30', '50', 'All')),
  paging = T) )
  

bscols(widths = c(8,1),  list(dataplot, dataplot_dt))

library(patchwork)
 
p1_pca + p2_tsne + p3_umap + plot_layout(guides = "collect")


library(ggpubr)
ggarrange(p1_pca, p2_tsne, p3_umap, ncol=1, nrow=3, common.legend = TRUE, legend="right")
ggarrange(p1_pca, p2_tsne, p3_umap, ncol=3, nrow=1, common.legend = TRUE, legend="right")


