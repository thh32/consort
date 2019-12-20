#!/usr/bin/env Rscript
args = commandArgs()
###########################################################################
#
#     Load packages
#
###########################################################################



.cran_packages <- c("ggplot2", "gridExtra",'knitr')
.bioc_packages <- c("dada2", "BiocStyle","phyloseq", "DECIPHER", "phangorn")
.inst <- .cran_packages %in% installed.packages()
if(any(!.inst)) {
  install.packages(.cran_packages[!.inst],repos = "http://cran.us.r-project.org")
}
.inst <- .bioc_packages %in% installed.packages()
if(any(!.inst)) {
  source("http://bioconductor.org/biocLite.R")
  biocLite(.bioc_packages[!.inst], ask = F)
}
# Load packages into session, and print package version
sapply(c(.cran_packages, .bioc_packages), require, character.only = TRUE)


library("knitr")
library("BiocStyle")
library('ggplot2')
library('gridExtra')
library('dada2')
library('phyloseq')
library('DECIPHER')
library('phangorn')


set.seed(100)


###########################################################################
#
#     User options
#
###########################################################################


#  Rscript DADA2_analysis.R pwd forward_trim reverse_trim
# Set working location
scriptwd <- args[9]
setwd(args[8])
getwd()
scriptwd

# Trim at which base?
forward_trim <- as.double(args[6])



###########################################################################
#
#     List files
#
###########################################################################

# Files must be in a folder called 'Demultiplexed'
miseq_path <- "./demultiplexed" # CHANGE to the directory containing the fastq files after unzipping.



###########################################################################
#
#     Quality check
#
###########################################################################


# Sort ensures forward/reverse reads are in same order
fnFs <- sort(list.files(miseq_path, pattern="@F.fastq"))
# Extract sample names, assuming filenames have format: SAMPLENAME_XXX.fastq
sampleNames <- sapply(strsplit(fnFs, "@"), `[`, 1)
# Specify the full path to the fnFs and fnRs
fnFs <- file.path(miseq_path, fnFs)
fnFs[1:3]
sampleNames[1:3]

plotQualityProfile(fnFs)





###########################################################################
#
#     Filter reads
#
###########################################################################




filt_path <- file.path("./Filtered") # Place filtered files in filtered/ subdirectory
if(!file_test("-d", filt_path)) dir.create(filt_path)
filtFs <- file.path(filt_path, paste0(sampleNames, "_F_filt.fastq.gz"))





out <- filterAndTrim(fnFs, filtFs, truncLen=c(forward_trim),
                     maxN=0, maxEE=c(2), truncQ=2, rm.phix=TRUE,
                     compress=TRUE, multithread=TRUE) # On Windows set multithread=FALSE
out





###########################################################################
#
#     Dereplication
#
###########################################################################





derepFs <- derepFastq(filtFs, verbose=TRUE)
# Name the derep-class objects by the sample names
names(derepFs) <- sampleNames




###########################################################################
#
#     Remove sequencing error
#
###########################################################################

errF <- learnErrors(filtFs, multithread=TRUE,pool=TRUE)


plotErrors(errF)


dadaFs <- dada(derepFs, err=errF, multithread=TRUE,pool=TRUE)






###########################################################################
#
#     Merge pairs
#
###########################################################################
seqtabAll <- makeSequenceTable(dadaFs[!grepl("Mock", names(dadaFs))])



###########################################################################
#
#     Remove chimeras
#
###########################################################################
seqtabNoC <- removeBimeraDenovo(seqtabAll)
write.csv(seqtabNoC, file = "./ASV_table.csv")



###########################################################################
#
#     Assign taxonomy
#
###########################################################################
fastaRef <- paste(scriptwd, "/Bin/silva_nr_v132_train_set.fa.gz", sep="")
taxTab <- assignTaxonomy(seqtabNoC, refFasta = fastaRef, multithread=TRUE)


taxTab


write.csv(taxTab, file = "./ASV_SILVA_taxonomy.csv")


