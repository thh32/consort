import csv
import sys


RSV_taxonomy = {}
for line in open(sys.argv[1] + '/RSV_taxonomy.csv','r'):
    timber = line.split(',')
    RSV_taxonomy[timber[0].replace('>','')] = timber[1]
    
 



with open(sys.argv[1] + '/RSV_abundance_table.tab') as fin:
    rows = csv.reader(fin, delimiter='\t', skipinitialspace=True)
    transposed = zip(*rows)
    with open(sys.argv[1] + '/RSV_table_Transposed.tab', 'w') as fout:
        w = csv.writer(fout, delimiter='\t')
        w.writerows(transposed)
        
        
 
outputting = open(sys.argv[1] + '/RSV_combined_table.tsv','w')

num = 0
for line in open(sys.argv[1] + '/RSV_table_Transposed.tab','r'):
    num +=1
    if num == 1:
        outputting.write(line[:-2] + '\tTaxonomy\n')
    else:
        outputting.write(line[:-2]  + '\t' + RSV_taxonomy[line.split('\t')[0]])
        
outputting.close()