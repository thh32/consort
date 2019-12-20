#!/bin/bash

echo Consort location = ${BASH_SOURCE%/*}









usage1="Consort is designed to conduct amplicon sequence varient analysis on 16S rRNA datasets from minimal consortium studied."

usage2="Options:"
usage3="    -h  show this help text"

usage4="Required:"
usage5="    -r  [FILE]   Reference file containing full length 16S rRNA sequences of each consortium member"
usage6="    -i  [1/2]    State if dataset is double or single indexed"
usage7="    -i1 [FILE]   Index 1 file"
usage8="    -i2 [FILE]   Index 2 file if double indexed"
usage9="    -r1 [FILE]   Read file 1"
usage10="    -r2 [FILE]   Read file 2"
usage11="    -tf [INT]    Forward read length wanted after trimming"
usage12="    -tr [INT]    Reverse read length wanted after trimming"
usage13="    -m  [FILE]   Mapping file linking index sequences to sample names"
usage14="    -p [FLOAT]   Percentage of files that must be positive for a RSV for it to pass filtering; suggested is 30"
usage15="    -a [INT]     Number of reads an RSV must have within a sample to be deemed present; suggested is 1"
usage16="    -b [INT]     Number of mismatches to allow within the barcode during demultiplexing; suggested is 2"


#############################################
#                                           #
#                User options               #
#                                           #
#############################################

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -r|--reference)
    reference_file="$2"
    shift # past argument
    shift # past value
    ;;
    -i1|--index1)
    I1="$2"
    shift # past argument
    shift # past value
    ;;
    -i2|--index2)
    I2="$2"
    shift # past argument
    shift # past value
    ;;
    -r1|--readfile1)
    R1="$2"
    shift # past argument
    shift # past value
    ;;
    -r2|--readfile2)
    R2="$2"
    shift # past argument
    shift # past value
    ;;
    -tf|--trimforward)
    forward_trim="$2"
    shift # past argument
    shift # past value
    ;;
    -tr|--trimreverse)
    reverse_trim="$2"
    shift # past argument
    shift # past value
    ;;
    -m|--mappingfile)
    Mapping_file="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--index)
    index="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--prevalence)
    prevalence="$2"
    shift # past argument
    shift # past value
    ;;
    -a|--abundance)
    abundance="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--barcodemismatches)
    barcode_mismatch="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    echo $usage1
    echo $usage2
    echo $usage3
    echo $usage4
    echo $usage5
    echo $usage6
    echo $usage7
    echo $usage8
    echo $usage9
    echo $usage10
    echo $usage11
    echo $usage12
    echo $usage13
    echo $usage14
    echo $usage15
    echo $usage16
    exit
    shift # past argument
    shift # past value
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters




echo Reference file             = "${reference_file}"
echo Mapping file               = "${Mapping_file}"
echo R1 file                    = "${R1}"
echo R2 file                    = "${R2}"
echo Number of index files      = "${index}"
echo I1 file                    = "${I1}"
echo I2 file                    = "${I2}"
echo Prevelence cut-off         = "${prevalence}"
echo Abundance cut-off          = "${abundance}"
echo Barcode mismatches allowed = "${barcode_mismatch}"
echo Forward trimmed length     = "${forward_trim}"
echo Reverse trimmed length     = "${reverse_trim}"



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



    PWD=`pwd`


    # This step demultiplxes the main folders to create files specific for each sample, named based on the samples ID from the mapping file
    perl ${BASH_SOURCE%/*}/Bin/runDeMux.pl --study ./  --map $Mapping_file --I1 $I1 --R1 $R1 --accept $barcode_mismatch
fi





if [ $index == '2' ]; then


    PWD=`pwd`

    ##################################################
    #
    #   De-multiplex sample
    #
    ##################################################
    # This step demultiplxes the main folders to create files specific for each sample, named based on the samples ID from the mapping file
    perl ${BASH_SOURCE%/*}/Bin/runDeMux.pl --study ./ --paired --2index --map $Mapping_file --I1 $I1 --I2 $I2 --R1 $R1 --R2 $R2 --accept $barcode_mismatch
fi

echo 'End; Demultiplexing samples'





#################################
#
#   Run DADA2 analysis
#
################################

echo 'Begin; DADA2 analysis'
if [ $index == '1' ]; then
    reverse_trim=0
    Rscript ${BASH_SOURCE%/*}/Bin/DADA2_analysis_single.R $forward_trim $reverse_trim $PWD ${BASH_SOURCE%/*}
fi
# This step does the majpr DADA2 ASV analysis and provides a sequence table 

if [ $index == '2' ]; then
    Rscript ${BASH_SOURCE%/*}/Bin/DADA2_analysis.R $forward_trim $reverse_trim $PWD ${BASH_SOURCE%/*}
fi
echo 'End; DADA2 analysis'



###########################################################################################################
#
#
#
#                                                   Basic analysis
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

python ${BASH_SOURCE%/*}/Bin/FASTA_creation.py $PWD 
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
muscle -in ${PWD}/RSV_sequences.fasta -out ${PWD}/RSV_seq_alignment.afa -maxiters 10 -quiet
echo "Creating Tree."
FastTree -quiet -nosupport -gtr -nt ${PWD}/RSV_seq_alignment.afa > ${PWD}/RSV_tree.tre 

echo "End; Phylogenetic tree creation."

##################################
#
#   Annotation against reference consortium dataset
#
##################################
echo "Begin; Consortium annotation."

blastn -subject $reference_file -qcov_hsp_perc 80.0 -evalue 0.0000000000000000000000001 -perc_identity 97.0 -strand both -outfmt 6 -query ${PWD}/RSV_sequences.fasta -out ${PWD}/Consortium_aligned_seqs.m8


echo "End; Consortium annotation."

#################################
#
#   Annotation selection
#
#################################
echo "Begin; Taxonomic assigner."

# This step assigns taxonomy to each RSV  
python ${BASH_SOURCE%/*}/Bin/Taxonomy_assigner.py $PWD
echo "End; Taxonomic assigner."


echo "Begin; Combining taxonomic and RSV abundance information"

#This step merges the taxonomy and abundance information to form a single file for analysis
python ${BASH_SOURCE%/*}/Bin/Combination_Abund_Taxon.py $PWD
echo "End; Combining taxonomic and RSV abundance information"











###########################################################################################################
#
#
#
#                                               Filtered output
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
python ${BASH_SOURCE%/*}/Bin/Filter_RSVs.py $PWD $prevalence $abundance
echo 'End; RSV filtering '

#Rerun FastTree to recreate using only the new OTUs
echo "Begin; Phylogenetic tree creation."
echo "Aligning RSVs."
muscle -in ${PWD}/RSV_filtered.fasta -out ${PWD}/RSV_filtered_alignment.afa -maxiters 10 -quiet
echo "Creating Tree."
FastTree -quiet -nosupport -gtr -nt ${PWD}/RSV_filtered_alignment.afa > ${PWD}/RSV_filtered_tree.tre 

echo "End; Phylogenetic tree creation."




















###########################################################################################################
#
#
#
#                                               Combined output
#
#
#
###########################################################################################################





#Create summed up abundances
echo "Begin; Summing up abundances for each taxonomic lineage for seperate analysis"
python ${BASH_SOURCE%/*}/Bin/Summing_up.py $PWD
muscle -in ${PWD}/RSV_taxonomic_groups.fasta -out ${PWD}/RSV_taxonomic_groups.afa -maxiters 10 -quiet
FastTree -quiet -nosupport -gtr -nt ${PWD}/RSV_taxonomic_groups.afa > ${PWD}/RSV_taxonomic_groups.tre 
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

python ${BASH_SOURCE%/*}/Bin/Summery_maker.py $PWD
