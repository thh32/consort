import sys



Taxonomy = {}
temp = {}
for line in open(sys.argv[1] + '/Consortium_aligned_seqs.m8','r'):
    timber = line.replace('\n','').split('\t')
    if timber[0] in temp:
        nbit = float(timber[11])
        obit = temp[timber[0]][1]
        if nbit > obit:
            temp[timber[0]] = [timber[1], nbit]
            
for k,v in temp.iteritems():
    Taxonomy[k] = v[0] + '\n'
    
    
mapping_names = {}
for line in open(sys.argv[1] + '/Naming_RSVs.csv','r'):
    timber = line.replace('\n','').split(',')
    mapping_names[timber[1]] = timber[0]
    
    
numb = 0
for line in open(sys.argv[1] +  '/ASV_SILVA_taxonomy.csv','r'):
    numb +=1
    if numb >1:
        timber = line.split(',')
        name = mapping_names[timber[0]]
        tax = ';'.join(timber[1:]).replace('"','').replace('NA','').replace('\n','') + ';;\n'
        if name in Taxonomy:
            continue
        else:
            Taxonomy[name] = tax
            
            
outputting = open(sys.argv[1] + '/RSV_taxonomy.csv','w')
for k,v in Taxonomy.iteritems():
    outputting.write(k + ',' + v )
outputting.close()
