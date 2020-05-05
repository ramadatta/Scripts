# Script to loop mlplasmids prediction tool for all the genome assemblies

# Prakki Sai Rama Sridatta
# May 05, 2020

#List of all the fasta files
files <- list.files(pattern = "*.fasta$", recursive = F)
#files

## Read in all files using a for loop and perform mlplasmids and save the results in a output

for (i in 1:length(files)) {
 
  tmp_fasta <- files[i]
 # ml_prediction <- plasmid_classification(path_input_file = tmp_fasta, full_output = TRUE, species = 'Escherichia coli', min_length = 0)
   ml_prediction <- plasmid_classification(path_input_file = tmp_fasta, full_output = TRUE, species = 'Klebsiella pneumoniae', min_length = 0)
  
  ml_prediction$AssemblyName <- tmp_fasta
  
  # Assigning column names
  names(ml_prediction) <- c("Prob_Chromosome","Prob_Plasmid","Prediction","Contig_name","Contig_length","AssemblyName")
  
  # reorder by column name
  ml_prediction <- ml_prediction[c("AssemblyName","Prob_Chromosome","Prob_Plasmid","Prediction","Contig_name","Contig_length")]
  
  write.table(ml_prediction,"kpneumoniae_mlprediction.out",row.names = FALSE, col.names = FALSE, append = TRUE, quote = FALSE, sep = "\t")
}
