import HTSeq
import sys
import random


prevalence = float(sys.argv[2]) # prevalence used for RSV filtering
abundance = int(sys.argv[3]) # number of reads required for an RSV within a sample to count as positive



counts = {}
num = 0
outputting = open(sys.argv[1] + '/RSV_filtered.fasta','w')
outputtingtable = open(sys.argv[1] + '/RSV_filtered_table.tsv','w')

keeping = []

for line in open(sys.argv[1] + '/RSV_combined_table.tsv','r'):
    num +=1
    if num >1:
        timber = line.replace('\n','').split('\t')
        name = timber[0]
        count = timber[1:-1]
        prev = 0
        samples = len(count)
        for i in count:
            if int(i) >= abundance:
                prev +=1
        prev_perc = (float(prev)/samples)*100
        if prev_perc >= prevalence:
            keeping.append(name)
            outputtingtable.write(line)
    else:
        outputtingtable.write(line)
            
outputtingtable.close()           

for read in HTSeq.FastaReader(sys.argv[1] + '/RSV_sequences.fasta'):
    if read.name in keeping:
        outputting.write('>' + read.name + '\n')
        outputting.write(read.seq + '\n')
        
outputting.close()