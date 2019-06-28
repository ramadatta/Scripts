# Author: David Eyre
# Generate Variable SNP Sites from an Alignment file


from Bio import SeqIO

infile = '/Users/davideyre/Downloads/PreGubbins_Aln_ST131_65_SamplesSubset.fasta'

seqlist = [s for s in SeqIO.parse(infile, 'fasta')]

seq_generator = zip( *seqlist  )
nonshared_pos =[ i for ( i, a ) in enumerate( seq_generator ) 
                   if len( set( [ ai for ai in a if ai in 'ACGT' ] ) ) >  1 ]

outfile = '/Users/davideyre/Downloads/PreGubbins_Aln_ST131_65_SamplesSubset_varsites.fasta'

for seq in seqlist:
    nonshared_bases = ''.join( seq.seq[ i ] for i in nonshared_pos )
    seq.seq._data = nonshared_bases

SeqIO.write( seqlist , outfile, 'fasta' )
