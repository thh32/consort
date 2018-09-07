import random
import sys


outputting = open( sys.argv[1] + '/RSV_sequences.fasta','w')
tableoutput = open( sys.argv[1] + '/RSV_abundance_table.tab','w')
namingfile = open( sys.argv[1] + '/Naming_RSVs.csv','w')




tableline = '#RSVID\t'
num = 0
for line in open(sys.argv[1] + '/ASV_table.csv','r'):
    num +=1
    if num == 1:
        timber = line.replace('\n','').split(',')
        for i in timber[1:]:
            number = ''
            for k in range(0,30):
                number = number + str(random.randint(0,9))
            name = 'RSV_' + number
            outputting.write( '>' + name + '\n')
            tableline = tableline + name + '\t'
            outputting.write(i.replace('"','').replace('"','') + '\n')
            namingfile.write(name + ',' + i + '\n')
        tableoutput.write(tableline[:-1] + '\n')
    else:
        tableoutput.write(line.replace(',','\t'))
outputting.close()
tableoutput.close()
namingfile.close()