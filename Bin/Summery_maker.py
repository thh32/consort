import HTSeq
import sys
import glob


outputting = open(sys.argv[1] + '/Summery.tab','w')

total_rsv = 0
filtered_rsv = 0
taxonomic_groups = 0

for read in HTSeq.FastaReader(sys.argv[1] + '/RSV_sequences.fasta'):
	total_rsv +=1

for read in HTSeq.FastaReader(sys.argv[1] + '/RSV_filtered.fasta'):
	filtered_rsv +=1

for read in HTSeq.FastaReader(sys.argv[1] + '/RSV_taxonomic_groups.fasta'):
	taxonomic_groups +=1




tot_reads = 0
tot_sample = {}
filtered_reads = 0
filtered_sample = {}
num = 0
samples = ''
for line in open(sys.argv[1] + '/RSV_combined_table.tsv','r'):
    num +=1
    if num >1:
        timber = line.replace('\n','').split('\t')
        name = timber[0]
        count = timber[1:-1]
        for i,h in zip(count,samples):
        	if h in tot_sample:
        		prev = tot_sample[h]
        		prev = prev + int(i)
        		tot_sample[h] = prev
        	else:
        		tot_sample[h] = int(i)

        for i in count:
             tot_reads += int(i)
    else:
        timber = line.replace('\n','').split('\t')
    	samples = timber[1:-1]
                
                
num = 0
samples = ''
for line in open(sys.argv[1] + '/RSV_filtered_table.tsv','r'):
    num +=1
    if num >1:
        timber = line.replace('\n','').split('\t')
        name = timber[0]
        count = timber[1:-1]
        for i,h in zip(count,samples):
        	if h in filtered_sample:
        		prev = filtered_sample[h]
        		prev = prev + int(i)
        		filtered_sample[h] = prev
        	else:
        		filtered_sample[h] = int(i)
        for i in count:
             filtered_reads += int(i)
    else:
        timber = line.replace('\n','').split('\t')
    	samples = timber[1:-1]
                
                                
                

original_sample = {}

for cfile in glob.glob(sys.argv[1] + '/demultiplexed/*@F.fastq'):
    count = 0
    name = cfile.split('@')[0].split('/')[-1:][0]
    for read in HTSeq.FastqReader(cfile):
        count +=1
    original_sample[name] = count


     


outputting.write('# Basic stats\n')
outputting.write('Total RSVs:\t' +  str(total_rsv) + '\n')
outputting.write('Filtered RSVs:\t' + str(filtered_rsv) + '\n')
outputting.write('Taxonomic groups:\t' + str(taxonomic_groups) + '\n')

outputting.write('Total reads:\t' +  str(sum(original_sample.values())) + '\n')
outputting.write('RSV annotated reads:\t' + str(tot_reads) + '\n')
outputting.write('Filtered RSV reads:\t' + str(filtered_reads) + '\n')

outputting.write('# Sample specific counts')
outputting.write('# Sample name\tRaw reads\tRSV reads\tFiltered RSV reads\n')

for i in samples:
	line = i + '\t'  + str(original_sample[i]) + '\t' + str(tot_sample[i]) + '\t' + str(filtered_sample[i]) + '\n'
	outputting.write(line)

outputting.close()