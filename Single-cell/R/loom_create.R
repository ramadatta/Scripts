library(loomR)
library(Matrix)
library(data.table)
library(Seurat)

folder="/home/ramadatta/Analysis/1_Schiller_Lab/Projects/1_scGenomics_hPCLS/1_raw_data/human/FC_12h/count_matrices/raw_feature_bc_matrix/"
mtx = Matrix::readMM(paste0(folder,"/matrix.mtx"))

# add the row and column names from the tsv files
# Read features.tsv.gz
features <- fread(paste0(folder,"/features.tsv"), header = FALSE)
# Assuming the first column contains feature names
feature_names <- features$V1

# Read barcodes.tsv.gz
barcodes <- fread(paste0(folder,"/barcodes.tsv"), header = FALSE)
# Assuming the first column contains barcode names
barcode_names <- barcodes$V1

# Set row and column names in the sparse matrix
rownames(mtx) <- feature_names
colnames(mtx) <- barcode_names

loomR::create("~/Desktop/test_unfiltered.loom", mtx, transpose = TRUE, overwrite = TRUE)

# Connect to the loom file in read/write mode
lfile <- connect(filename = "~/Desktop/test_unfiltered.loom", mode = "r+")
lfile
