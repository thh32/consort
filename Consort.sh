

#############################################
#											#
#                User options				#
#											#
#############################################
# Sequences must be named with their taxonomy as such; Bacteria;Bacteroidetes;Bacteroidia;Bacteroidales;Muribaculaceae;Muribaculum;Muribaculum intestinale
reference_file='Reference_Files/OligoMM10_plus2.fa' 



I1='OligoMM-rwth_Jan18-I1.fastq'
I2='OligoMM-rwth_Jan18-I2.fastq'
R1='OligoMM-rwth_Jan18-R1.fastq'
R2='OligoMM-rwth_Jan18-R2.fastq'
forward_trim='250'
reverse_trim='250'
Mapping_file='Mapping_file.tab' #Contains the barcodes mapping (carefull for the barcodes orientation)
barcode_mismatch=2 #the number of allowed missmatches in the barcodes (<=2)
index='2'
prevalence='30.0' # prevalence used for RSV filtering
abundance='10' # number of reads required for an RSV within a sample to count as positive




##################################################
#
#   De-multiplex sample
#
##################################################



if [ -d ./demultiplexed ]; then
	rm -r ./demultiplexed
fi

if [ -d ./Filtered ]; then
	rm -r ./Filtered
fi

echo 'Begin; Demultiplexing samples'
if [ $index == '1' ]; then
	echo 'Files for analysis;'
	echo $I1
	echo $R1
	echo $R2
	echo $Mapping_file



	PWD=`pwd`


	# This step demultiplxes the main folders to create files specific for each sample, named based on the samples ID from the mapping file
	perl Bin/runDeMux.pl --study ./ --paired  --map $Mapping_file --I1 $I1 --R1 $R1 --R2 $R2 --accept $barcode_mismatch
fi





if [ $index == '2' ]; then
	echo 'Files for analysis;'
	echo $I1
	echo $I2
	echo $R1
	echo $R2
	echo $Mapping_file



	PWD=`pwd`

	##################################################
	#
	#   De-multiplex sample
	#
	##################################################
	# This step demultiplxes the main folders to create files specific for each sample, named based on the samples ID from the mapping file
	perl Bin/runDeMux.pl --study ./ --paired --2index --map $Mapping_file --I1 $I1 --I2 $I2 --R1 $R1 --R2 $R2 --accept $barcode_mismatch
fi

echo 'End; Demultiplexing samples'





#################################
#
#   Run DADA2 analysis
#
################################
echo 'Begin; DADA2 analysis'
echo 'Forward read length; ', $forward_trim
echo 'Reverse read length; ', $reverse_trim
Rscript Bin/DADA2_analysis.R $forward_trim $reverse_trim
# This step does the majpr DADA2 ASV analysis and provides a sequence table 

echo 'End; DADA2 analysis'



###########################################################################################################
#
#
#
#                     								Basic analysis
#
#
#
###########################################################################################################




################################
#
#   FASTA file creation
#
################################
echo 'Begin; FASTA creation'

python Bin/FASTA_creation.py $PWD 
# This step convets the output DADA2 files
echo 'End; FASTA creation'


#################################
#
#   Create phylogenetic tree
#
#################################
#Rerun FastTree to recreate using only the new OTUs
echo "Begin; Phylogenetic tree creation."
echo "Aligning RSVs."
Bin/muscle -in ${PWD}/RSV_sequences.fasta -out ${PWD}/RSV_seq_alignment.afa -maxiters 10 -quiet
echo "Creating Tree."
Bin/FastTree -quiet -nosupport -gtr -nt ${PWD}/RSV_seq_alignment.afa > ${PWD}/RSV_tree.tre 

echo "End; Phylogenetic tree creation."

##################################
#
#   Annotation against reference consortium dataset
#
##################################
echo "Begin; Consortium annotation."

blastn -subject $reference_file -qcov_hsp_perc 80.0 -evalue 0.0000000000000000000000001 -perc_identity 97.0 -strand both -max_target_seqs 1 -outfmt 6 -query ${PWD}/RSV_sequences.fasta -out ${PWD}/Consortium_aligned_seqs.m8


echo "End; Consortium annotation."

#################################
#
#   Annotation selection
#
#################################
echo "Begin; Taxonomic assigner."

# This step assigns taxonomy to each RSV  
python Bin/Taxonomy_assigner.py $PWD
echo "End; Taxonomic assigner."


echo "Begin; Combining taxonomic and RSV abundance information"

#This step merges the taxonomy and abundance information to form a single file for analysis
python Bin/Combination_Abund_Taxon.py $PWD
echo "End; Combining taxonomic and RSV abundance information"











###########################################################################################################
#
#
#
#                     							Filtered output
#
#
#
###########################################################################################################

################################
#
#   Filter the RSVs
#
################################
echo 'Begin; RSV filtering'
# This step produces both the filtered FASTA file and combined abundance table
python Bin/Filter_RSVs.py $PWD $prevalence $abundance
echo 'End; RSV filtering '

#Rerun FastTree to recreate using only the new OTUs
echo "Begin; Phylogenetic tree creation."
echo "Aligning RSVs."
Bin/muscle -in ${PWD}/RSV_filtered.fasta -out ${PWD}/RSV_filtered_alignment.afa -maxiters 10 -quiet
echo "Creating Tree."
Bin/FastTree -quiet -nosupport -gtr -nt ${PWD}/RSV_filtered_alignment.afa > ${PWD}/RSV_filtered_tree.tre 

echo "End; Phylogenetic tree creation."




















###########################################################################################################
#
#
#
#                     							Combined output
#
#
#
###########################################################################################################





#Create summed up abundances
echo "Begin; Summing up abundances for each taxonomic lineage for seperate analysis"
python Bin/Summing_up.py $PWD
Bin/muscle -in ${PWD}/RSV_taxonomic_groups.fa -out ${PWD}/RSV_taxonomic_groups.afa -maxiters 10 -quiet
Bin/FastTree -quiet -nosupport -gtr -nt ${PWD}/RSV_taxonomic_groups.afa > ${PWD}/RSV_taxonomic_groups.tre 
echo "End; Summing up abundances for each taxonomic lineage for seperate analysis"








###########################################################################################################################################################
#
#
#
#
#
#
#
#                                                                 Produce summery of results
#
#
#
#
#
#
#
###########################################################################################################################################################

python Bin/Summery_maker.py $PWD
