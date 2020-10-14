#extract small RNAs from BSRD
from csv import reader
import csv
opened_file = open("../NC_005126_sRNA_Jan2020.csv")
read_file = reader(opened_file)
data= list(read_file) 

filtered = []
for row in data:
	TSS_info = row[8]
	if "with_TSS=NA" not in TSS_info:
		filtered.append(row)



with open("output.txt", 'w', newline = '') as outfile:
		for row in filtered:
			tsv_out = csv.writer(outfile, delimiter = '\t')
			tsv_out.writerow(row)
