# Consort: amplicon sequence variant based analysis of 16S rRNA datasets from minimal consortia



Consort has been designed to specifically for 16S rRNA analysis of minimal microbial consortia. 

Utilising the DADA2 package to conduct amplicon sequence varient analysis (https://www.nature.com/articles/nmeth.3869) allows Consort to provide information on both the diversity of each consortium member and its total abundance

# Installation
Consort consists of a series of python and perl scripts called from a main bash script.
We suggest installation via downloading the Github repository (`git clone https://github.com/thh32/consort`) and then placing the consort directory in your path variable by editing your `.bashrc` file. 

You must also download the following file (do not decompress) and place it within the `Bin/` folder for DADA2 taxonomic assignment; https://zenodo.org/record/1172783/files/silva_nr_v132_train_set.fa.gz?download=1

### Python modules
The following python modules must be installed before running Consort. These can simple be installed using the `pip install [module]` command on linux/mac machines

* HTSeq


### R packages
Whilst the following R packages and their dependancies are needed, they will be installed during the running of Consort if not already installed, however a base installation of R is required.

* dada2
* BiocStyle
* phyloseq
* DECIPHER
* phangorn
* ggplot2
* gridextra
* knitr


### Programs
Users must ensure that each of the following programs are installed and within the path variable;

* BLASTN is used to annotate ribosomal sequence varients (RSVs) against the provided reference file containing the 16S rRNA sequences of all consortium members. Testing was conducted using BLAST 2.6.0+.

* MUSCLE is used for alignment of the RSV sequences. Testing was done using MUSCLE v3.8.31.

* FastTree is used to convert the MUSCLE alignment into a tree for downstream analysis and visualisation. Testing was done using FastTree version 2.1.7 SSE3.



# Usage
Consort can accept both single indexed and double indexed paired sequencing datasets.

To run Consort you must enter the Consort directory and then edit the `Consort.sh` file with the following information;
* Identify if dataset is single or double indexed
* Index file/files
* Sequence files (both R1 and R2)
* Defined trimming length for forward and reverse reads
* Number of mismatches to allow in the barcode
* Prevalence and abundance cut-off for filtering (an RSV must have [abundance] reads assigned to it within [prevalence] percentage of the samples); the default is 0.0% prevalence and 25 reads based on the rationale of removing spurious ASVs
* A reference file containing the 16s rRNA sequences for each member of your consortium must be provided in FASTA format. We provide reference files for both the OligoMM10 and OligoMM12 minimal consortiums within the `Reference_files/` folder (https://www.nature.com/articles/nmicrobiol2016215). Each reference file must include the full lineage of each consortium member in the FASTA header as shown in the example below;
```
>Bacteria;Verrucomicrobia;Verrucomicrobiae;Verrucomicrobiales;Akkermansiaceae;Akkermansia;Akkermansia_muciniphila_strain_YL44
AGAGTTTGATTCTGGCTCAGAACGAACGCTGGCGGCGTGGATAAGACATGCAAGTCGAACGGGAGAATTG...
```


| Command| Description                                                                                              | Suggestion |
| ------------- | -------------------------------------------------------------------------------------------------------- | ------- |
|-r $FILE    | Reference file containing full length 16S rRNA sequences of each consortium member          |       |
| -i $INT    | State if dataset is double or single indexed                                                    |        |
| -i1 $FILE    | Index 1 file                                                    |        |
| -i2 $FILE    | Index 2 file if double indexed                                                    |        |
| -r1 $FILE       | Read file 1                                            |      |
| -r2 $FILE       | Read file 2                                            |      |
| -tf $INT     | Mapping file linking index sequences to sample names     |       |
| -tr $INT     | Reverse read length wanted after trimming     |       |
| -m $FILE     | Reverse read length wanted after trimming     |       |
| -p $FLOAT     | Percentage of files that must be positive for a RSV for it to pass filtering  |  0.0     |
| -a $INT     |  Number of reads an RSV must have within a sample to be deemed present  |  25     |
| -b $INT     | Number of mismatches to allow within the barcode during demultiplexing  |  2     |


### Example

For the test dataset used in the paper the following command line options were provided;

`Consort.sh  -r OligoMM10_plus2.fa -i1 OligoMM-rwth_Jan18-I1.fastq -i2 OligoMM-rwth_Jan18-I2.fastq -r1 OligoMM-rwth_Jan18-R1.fastq -r2 OligoMM-rwth_Jan18-R2.fastq -tf 250 -tr 250 -m Mapping_file.tab -i 2 -p 30.0 -a 1 -b 2`

### Reduce RAM usage
Consort by default pools all sequencing data for error correction and RSV identification, however the increased sensitivity to rare varients comes at the cost of increased RAM usage. If RAM usage is too high the `Bin/DADA2_analysis.R` script can be edited by changing `pool=TRUE` to `pool=FALSE` on line 146,147,154 and 155. This will mean that error correction will be less accurate and rare varients may be missed and so is not recommended.

# Downstream analysis
Consort produces three sets of output; the full RSV dataset, the filtered RSV dataset and a taxonomically combined dataset.

Both the RSV datasets are provided for advance users who wish to study the variation within each consortium member, however the taxonomically combined dataset is design for quick downstream analysis and produces files compatible with the Rhea (https://github.com/Lagkouvardos/Rhea) 16S rRNA OTU analysis script set.

The RSV datasets can easily be made acceptable by Rhea by chaning the following elements in the header of the file;
* RSVID to OTUid
* Taxonomy to taxonomy


# Suggested analysis
### Manual identification of consortium members
During the filtering process it is possible that consortium members that are present in a subset of the samples or under the defined abundance. Therefore we suggest that users search the `RSV_abundance_table.tab` file for any consortium members not present within the filtered output.


### Investigation of potential contamination sources
As discussed within our paper, indepth study of the RSV diversity can provide novel insight into the sample specific, as well as dataset wide diversity of both the consortium members but also contaminants. Visualisation of the `RSV_tree.tre` file can be used to identify single RSV contaminants (likely introduced during sequencing and therefore can be ignored) or clusters of highly related RSVs not asigned to consortium members (presence of multiple highly related RSVs suggested either large scale contamination of the samples during sequencing, or contamination within the host).

The ability to distinguish between single isolate contamination and community contamination is unique to amplicon sequence varient analysis methods (ASV) over operational taxonomic unit (OTU) based analysis as no clustering of highly related sequences occurs.


## Common mistakes
* If species level annotation arnt showing; Make sure your reference file is correct with the full lineage in the FASTA header
* If no filtering is occuring remember; the abundance is that required for a sample to be deemed positive, NOT the cumulative abundance

# Known errors
* If Rcurl cannot be installed try running `sudo apt-get install libcurl4-openssl-dev`




