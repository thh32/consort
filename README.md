# Consort: amplicon sequence variant based analysis of 16S rRNA datasets from minimal consortia



Consort has been designed to specifically for 16S rRNA analysis of minimal microbial consortia. 

By utilising the DADA2 package to conduct amplicon seaquence varient analysis, Consort is able to provide information on both the diversity of each consortium member and its total abundance

# Installation
Consort consists of a series of python scripts called from a main bash script, therefore does not require installation as such however a list of depandancies are provided below;

### Python modules
The following python modules must be installed before running Consort. These can simple be installed using the `pip install [module]` command on linux/mac machines

* HTSeq
* glob


### R packages
Whilst the following R packages are needed they will be installed during the running of Consort if not already installed, however a base installation of R is required.

* dada2
* BiocStyle
* phyloseq
* DECIPHER
* phangorn
* ggplot2
* gridextra
* knitr

### Programs
Consort utilises the following programs that must be installed by the user before running Consort;

* Usearch (64 bit version of 8.1 used in paper)



# Usage
Consort can accept both single indexed and double indexed paired sequencing datasets.

To run Consort you must enter the Consort directory and then edit the `Consort.sh` file with the following information;


# Downstream analysis
Consort produces three sets of output; the full RSV dataset, the filtered RSV dataset and a taxonomically combined dataset.

Both the RSV datasets are provided for advance users who wish to study the variation within each consortium member, however the taxonomically combined dataset is design for quick downstream analysis and produces files compatible with the Rhea (https://github.com/Lagkouvardos/Rhea) 16S rRNA OTU analysis script set.

The RSV datasets can easily be made acceptable by Rhea by chaning the following elements in the header of the file;
* RSVID to OTUid
* Taxonomy to taxonomy


# Advanced usage




