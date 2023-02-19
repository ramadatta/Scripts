# Let's take our ggplot to  next level!!

library(tidyverse)
library(ggplot2)
# Need a dataset
data()

data(islands)

head(islands)

df <- as.data.frame(islands)

# Basic ggplot --------------------------------------------------------------

df %>% tibble::rownames_to_column(var="island") %>% 
  rename(Landmasses=islands) %>% 
  ggplot(aes(island,Landmasses)) + 
  geom_point()


# Copying to a different dataframe ---------------------------------------

df2 <- df %>% tibble::rownames_to_column(var="island") %>% 
  rename(Landmasses=islands) %>% 
  rename(Island=island)

head(df2)



# Lets beautify -----------------------------------------------------------

ggplot(df2,aes(Island,Landmasses)) +
  geom_point() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


# Bar plot ----------------------------------------------------------------


# Change labels angle

ggplot(df2,aes(Island,Landmasses)) +
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) 

# Order the x axis by counts

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# Axis and Plot title

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by Islands", x ="Islands", y = "Landmasses")


# Change theme

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by Islands", x ="Islands", y = "Landmasses") +
  theme_classic()

# More resources for different themes:
# https://r-charts.com/ggplot2/themes/
# https://www.shanelynn.ie/themes-and-colours-for-r-ggplots-with-ggthemr/
# https://rfortherestofus.com/2019/08/themes-to-improve-your-ggplot-figures/
# https://datarootsio.github.io/artyfarty/articles/introduction.html  

#devtools::install_github('Mikata-Project/ggthemr')

library(ggthemr)

ggthemr('pale')

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by Islands", x ="Islands", y = "Landmasses")

#Let's try another of themes more

ggthemr('dust')

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by Islands", x ="Islands", y = "Landmasses") 


# Change the font of the ggplot
# install.packages("extrafont")
# install.packages("showtext")

library(extrafont)
extrafont::loadfonts(device="win")
#font_import()
loadfonts(device = "postscript")

library(showtext)

font_add_google("Roboto Condensed", ## name of Google font
                "roboto") ## name that will be used in R
font_add_google("Schoolbell", "bell")
#font_add_google("Gochi Hand", "gochi")

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  theme(#plot.title.position = "plot",
    plot.title = element_text(family = "bell", hjust = .5, size = 25),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by islands", x ="Islands", y = "Landmasses")

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  theme(#plot.title.position = "plot",
        plot.title = element_text(family = "roboto", hjust = .5, size = 25),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by islands", x ="Islands", y = "Landmasses") 

# Changing font of all text in the whole ggplot

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  theme(
    plot.title.position = "plot",
    text=element_text(size=16,  family="roboto"),
    plot.title = element_text(size = 25),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by islands", x ="Islands", y = "Landmasses") 

# Let change the values on Y-axis to Log

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  scale_y_continuous(trans='log10') +
  theme(
    plot.title.position = "plot",
    text=element_text(size=16,  family="roboto"),
    plot.title = element_text(size = 25),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by islands", x ="Islands", y = "Landmasses") 

# Add label on top of each bar

ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  scale_y_continuous(trans='log10') +
  theme(
    plot.title.position = "plot",
    text=element_text(size=16,  family="roboto"),
    plot.title = element_text(size = 25),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by islands", x ="Islands", y = "Landmasses") +
 geom_text(aes(label=Landmasses), position=position_dodge(width=0.9), vjust=-0.25)

# Let's clip off
ggplot(df2,aes(reorder(Island,Landmasses), Landmasses)) + 
  geom_bar(stat="identity") +
  scale_y_continuous(trans='log10') +
  theme(
    plot.title.position = "plot",
    text=element_text(size=16,  family="roboto"),
    plot.title = element_text(size = 25),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by islands", x ="Islands", y = "Landmasses") +
  geom_text(aes(label=Landmasses), position=position_dodge(width=0.9), vjust=-0.25) +
  coord_cartesian(clip="off")

# Highlight a single bar

# df3 <- df2 %>% mutate(cg = case_when(Landmasses > 100 & Landmasses < 184 ~ "Special",
#                             TRUE ~ "NotSpecial"))

df2 %>% mutate(Case = case_when(Landmasses > 100 & Landmasses < 184 ~ "Special",
                                                           TRUE ~ "NotSpecial")) %>% 
ggplot(aes(reorder(Island,Landmasses), Landmasses, fill=Case)) + 
  geom_bar(stat="identity") +
  scale_y_continuous(trans='log10') +
  theme(
    plot.title.position = "plot",
    text=element_text(size=16,  family="roboto"),
    plot.title = element_text(size = 25),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by islands", x ="Islands", y = "Landmasses") +
  geom_text(aes(label=Landmasses), position=position_dodge(width=0.9), vjust=-0.25) +
  coord_cartesian(clip="off")

df2 %>% mutate(Case = case_when(Landmasses > 100 & Landmasses < 184 ~ "Special",
                                TRUE ~ "NotSpecial")) %>% 
  ggplot(aes(reorder(Island,Landmasses), Landmasses, fill=Case)) + 
  geom_bar(stat="identity") +
  scale_y_continuous(trans='log10') +
  scale_fill_manual(values = c("NotSpecial"="tomato3", "Special"="#008080")) +
  theme(
    plot.title.position = "plot",
    text=element_text(size=16,  family="roboto"),
    plot.title = element_text(size = 25),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  labs(title="Plot of landmasses by islands", x ="Islands", y = "Landmasses") +
  geom_text(aes(label=Landmasses), position=position_dodge(width=0.9), vjust=-0.25) +
  coord_cartesian(clip="off")

# Place legend on top/bottom

df2 %>% mutate(Case = case_when(Landmasses > 100 & Landmasses < 184 ~ "Special",
                                TRUE ~ "NotSpecial")) %>% 
  ggplot(aes(reorder(Island,Landmasses), Landmasses, fill=Case)) + 
  geom_bar(stat="identity") +
  scale_y_continuous(trans='log10') +
  scale_fill_manual(values = c("NotSpecial"="tomato3", "Special"="#008080")) +
  theme(
    plot.title.position = "plot",
    text=element_text(size=16,  family="roboto"),
    plot.title = element_text(size = 25),
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
    legend.position = "top") +
  labs(title="Plot of landmasses by islands", x ="Islands", y = "Landmasses") +
  geom_text(aes(label=Landmasses), position=position_dodge(width=0.9), vjust=-0.25) +
  coord_cartesian(clip="off") 

# Annotate with text
# Show arrows
# Color the title
# Place a note/caption



# Data visualization resources
# https://www.cedricscherer.com/2019/08/05/a-ggplot2-tutorial-for-beautiful-plotting-in-r/
