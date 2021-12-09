#/bin/bash
##RUN preparing_tags_LCPI.pl to format your barcodes files.
#input mapping file format:
#Sample1    tagF      tagR
#Sample2  ACCTGAAT  ATACAGA
####tab delimited!
#check this mapping file for duplicates in excel before sending to cluster
#write sample names without space, e.g sample 23 as sample_23 or sample23.
####DO NOT USE NUMBERS in the beginning of your sample names
#perl preparing_tags_LCPI.pl
                #my_mapping_file.txt
                                #linked
#the perl script should create 3 barcode files, Barcodes_LA1.txt, Barcodes_LA2.txt, Barcodes_LA3.txt for 'linked'
#the linked mode is 5' and 3' anchored

#ANY CUTADAPT ISSUE OR DOUBTS, SEE: https://cutadapt.readthedocs.io/en/stable/guide.html

INPUT="${1}"
PAIR1="Barcodes_LA1.fa"
PAIR2="Barcodes_LA2.fa"
PAIR3="Barcodes_LA3.fa"

### demultiplex (Linked Adapter)

cutadapt	\
	--quiet	\
        -a file:${PAIR1}        \
        -a file:${PAIR2}        \
        -a file:${PAIR3}        \
        -o "{name}_LA.fq"  \
        --action=lowercase      \
        ${INPUT}
		
mkdir demulti_linked_samples		
mv *.fq demulti_linked_samples
cd demulti_linked_samples/
find . -type f -empty -print -delete
cd ..
