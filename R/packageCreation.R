#Tutorial: https://tinyheero.github.io/jekyll/update/2015/07/26/making-your-first-R-package.html
setwd("CPgeneProfiler/")
getwd()

library(devtools)
library(roxygen2)
setwd("~/Desktop/CPE/")
devtools::create("CPgeneProfiler",open = FALSE)
  #Add the R script which you want to make it a package in the R directory created
# Added imports to the Documentation file
# Added documentation
getwd()

setwd("~/Desktop/CPE/CPgeneProfiler/")
#use_data(CPgeneProfiler)
devtools::document() # to document if you have functions
#devtools::load_all()
setwd("..")
install("CPgeneProfiler",dependencies = FALSE)
?CPgeneProfiler
??CPgeneProfiler
.rs.restartR()
library(CPgeneProfiler)

# Install from Github
devtools::install_github("ramadatta/CPgeneProfiler")
CPgeneProfiler("/home/datta/Desktop/CPE/R_package/JOSS/Team_Comments/NPAssemblies","/home/datta/Desktop/CPE/R_package/JOSS/Team_Comments")

  getAnywhere(CPgeneProfiler)
remove.packages("CPgeneProfiler")

#uploading
# echo "# CPgeneProfiler" >> README.md
# git init
# git add README.md
# git commit -m "Second commit"
# git config --global user.email "ramadatta.88@gmail.com"
# git remote add origin https://github.com/ramadatta/CPgeneProfiler.git # this did not work
# git remote set-url origin https://github.com/ramadatta/CPgeneProfiler #this works too
# git remote add origin https://github.com/ramadatta/CPgeneProfiler # this worked
# $ git remote set-url origin git@github.com:ramadatta/CPgeneProfiler.git

# git push -u origin master

####This simply worked####
# git init
# git add .
# git commit -m "Create first github package"
# git remote add origin https://github.com/ramadatta/CPgeneProfiler # this worked
# git remote set-url origin https://github.com/ramadatta/CPgeneProfiler #this works too
# git push -f origin master # Force worked for updating 
# git push origin master
# ####

https://stackoverflow.com/questions/17291995/push-existing-project-into-github


# Adding to existing project
# git add .
# git commit -m "Create first github package"
# git pull origin master
# git push origin master

#To push without conflicts both github and local should have same content.

# To delete a duplpicate directory
# In the command-line, navigate to your local repository.
# Ensure you are in the default branch:
#   git checkout master
# The rm -r command will recursively remove your folder:
#   git rm -r folder-name
# Commit the change:
#   git commit -m "Remove duplicated directory"
# Push the change to your remote repository:
#   git push origin master


##Just updating the repository online
git add .
git commit -m "my changes" 
git remote add origin https://github.com/zinmyoswe/React-and-Django-Ecommerce.git
git push -u origin master
