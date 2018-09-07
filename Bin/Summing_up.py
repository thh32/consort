import csv
import sys
import HTSeq



counts = {}
num = 0
outputting = open(sys.argv[1] + '/RSV_taxonomic_groups_table.tab','w')

speciesTax = {}
selection = {}

rsv_for_taxa = {}

for line in open(sys.argv[1] + '/RSV_filtered_table.tsv','r'):
    num +=1
    if num >1:
        timber = line.replace('\n','').split('\t')
        species = timber[-1:][0]
        count = timber[1:-1]
        speciesTax[species] = timber[-1:][0]
        rsv_for_taxa[species] = timber[0]
        if species in counts:
                new = []
                for k,v in zip(counts[species],count):
                    new.append(int(k) + int(v))
                counts[species] = new
        else:
            counts[species] = count
    else:
        outputting.write(line.replace('RSVID','OTUid').replace('Taxonomy','taxonomy'))
                

for k,v in counts.iteritems():
    line = k
    for i in v:
        line = line + '\t' + str(i)
    outputting.write(line + '\t' + speciesTax[k] + '\n')
    
outputting.close()


outputting = open(sys.argv[1] + '/RSV_taxonomic_groups.fasta','w')


for read in HTSeq.FastaReader(sys.argv[1] + '/RSV_sequences.fasta'):
    for k,v in rsv_for_taxa.iteritems():
        if v == read.name:
            outputting.write('>' + k + '\n')
            outputting.write(read.seq + '\n')

            
outputting.close()

