#Tutorial: https://tinyheero.github.io/jekyll/update/2015/07/26/making-your-first-R-package.html
setwd("CPgeneProfiler/")
getwd()

library(devtools)
library(roxygen2)
devtools::create("CPgeneProfiler")
#Add the R script which you want to make it a package in the R directory created
# Added imports to the Documentation file
# Added documentation
setwd("CPgeneProfiler/")
#use_data(CPgeneProfiler)
devtools::document() # to document if you have functions
#devtools::load_all()
setwd("..")
install("CPgeneProfiler")





#uploading
# echo "# CPgeneProfiler" >> README.md
# git init
# git add README.md
# git config --global user.email "ramadatta.88@gmail.com"
# git remote add origin https://github.com/ramadatta/CPgeneProfiler.git # this did not work
# git remote add origin https://github.com/ramadatta/CPgeneProfiler # this worked
# git push -u origin master



