
#H2 KEGG-KAAS Table Generator

# H3 Intro

Many times, I had to submit either Nucleotide pr Protein sequence to KEGG KAAS and felt immense pain arranging the data in the usable and understandable format.
Here is the script I wrote to understand and generate the Results, more easily, quickly in seconds.!!
Hope this is useful for the community!!

# H3 Descrption:

This script makes a table taking collapsed file, query.ko files as the inputs after Kegg-KAAS run	and generates a table	

# H3 Dependencies: 

The folder running this script should also have the sister files

# H3 OUTPUT
Two output files are generated;

# H3 Final_General_Table.txt 
# H3 ============================

PATHWAY|QUERY_SEQUENCES_WIT_HIT|MAPID|TOTAL_GENES_IN_PATHWAY|GENES_WITH_HIT|ENZYME_HIT

1. Metabolism					

1.0 Global map

Metabolic_pathways  13  map01100  2411  12  10

Biosynthesis_of_secondary_metabolites 4 map01110  1058  4 4

Microbial_metabolism_in_diverse_environments  2 map01120  853 2 2

# H3 Final_Specific_Table.txt 
# H3 ============================

PATHWAY	QUERY_SEQUENCES_WIT_HIT	MAPID	TOTAL_GENES_IN_PATHWAY	GENES_WITH_HIT	ENZYME_HIT

ABC_transporters	1	map02010	426	1	0

Acute_myeloid_leukemia	5	map05221	45	5	1

Adherens_junction	3	map04520	60	3	1

Adrenergic_signaling_in_cardiomyocytes	3	map04261	91	3	2

Alcoholism	1	map05034	82	1	0

Alzheimers_disease	3	map05010	141	3	1

Antigen_processing_and_presentation	1	map04612	41	1	1

Arrhythmogenic_right_ventricular_cardiomyopathy__ARVC_	2	map05412	65	2	0

Basal_cell_carcinoma	2	map05217	42	2	0

Basal_transcription_factors	1	map03022	35	1	0

Bile_secretion	3	map04976	58	2	1


# H3 Table Header Descriptions 
* PATHWAY - Pathway 

QUERY_SEQUENCES_WIT_HIT	MAPID - How many sequences from the query had hit to this pathway?

TOTAL_GENES_IN_PATHWAY - Actual number of genes in the pathway?

GENES_WITH_HIT - How many of the genes out of total genes in the patway had got hit (by the query sequences)?

ENZYME_HIT - How many of the genes which had hit were enzyme?

