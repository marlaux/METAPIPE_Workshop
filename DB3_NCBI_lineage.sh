#!/bin/bash

REFERENCES=''
PREFIX=''
DIR=''

usage () {
	echo "##################################################"
	echo " "
	echo "Format and include taxonomic lineage in the NCBI reference fasta."
	echo "This script edit the headers from the reference multifasta file,"
	echo "in order to build your local database to run BLAST."
	echo ""
        echo "Usage: $0 [-r NCBI_references.fasta] [-p output_prefix]" 
	echo "-r     references fasta file"
	echo "-p     prefix to output filenames (e.g ITS_NCBI)"
	echo "-h     Print this Help." 
	echo ""
	echo "This script needs the two embedded Perl scripts to run:"
        echo "NCBI_lineage_dups.pl and NCBI_lineage_edit.pl"
        echo "DO NOT EDIT THEM."
	echo " "
	echo "##################################################"	
		1>&2; exit 1;
}

while getopts "r:p:h" option; do
        case $option in
	r) REFERENCES="${OPTARG}"
                ;;
	p) PREFIX=${OPTARG}
                ;;
	h | *) usage
		exit 0
                ;;
	\?) echo "Invalid option: -$OPTARG" >&2
		exit 1
                ;;
	: ) echo "Missing argument for -${OPTARG}" >&2
		exit 1
		;;
   esac
done

if [ -z "$REFERENCES" ] || [ -z "$PREFIX" ]; then
	echo "Missing argument"
        echo "Missing argument" &>>"${PREFIX}.log"
        exit 1
fi

echo "ATTENTION: original NCBI reference sequences:"
echo ">LC384553.1 Scutellaria orientalis genes for 18S rRNA and ITS1..."
echo "TGAACCATCGAGTCTTTGAACGCAAGTTGCGCCCGAACCCATCAGGCCGAGGGCAC..."
echo "Presenting the accession.version, a white-space and the complete"
echo "description [TI esearch field]"
echo "##############################################" >> "${PREFIX}.log"
echo "## SUMMARY FORMATTING NCBI REFERENCES FASTA ##" >> "${PREFIX}.log"
echo "##                            Laux, Marcele ##" >> "${PREFIX}.log"
echo "##############################################" >> "${PREFIX}.log"
echo " " >> "${PREFIX}.log"
echo " "
echo "FILES CHECK UP:" 
nucl_gb="nucl_gb.accession2taxid.gz"
taxdb="taxdb.btd"
edit="NCBI_lineage_edit.pl"
dups="NCBI_lineage_dups.pl"
taxonkit="taxonkit"
if [ -f "$nucl_gb" ]; then
	echo "$nucl_gb ... OK"
else
	echo "$nucl_gb NOT FOUND."
	echo "$nucl_gb NOT FOUND." >> "${PREFIX}.log"
	echo "Download: wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz" >> "${PREFIX}.log"
	echo " " >> "${PREFIX}.log"
fi

if [ -f "$taxdb" ]; then
	echo "taxdb ... OK"
else
	echo "taxdb NOT FOUND."
	echo "taxdb NOT FOUND." >> "${PREFIX}.log"
	echo "Download: wget https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz" >> "${PREFIX}.log"
	echo "tar -zxvf taxdb.tar.gz" >> "${PREFIX}.log"
	echo " " >> "${PREFIX}.log"
fi

if [ -f "$taxonkit" ]; then
	echo "$taxonkit ... OK"
else
	echo "$taxonkit NOT FOUND."
	echo "taxonkit NOT FOUND." >> "${PREFIX}.log"
	echo "Download and install TaxonKit:" >> "${PREFIX}.log"
	echo "wget https://github.com/shenwei356/taxonkit/releases/download/v0.8.0/taxonkit_linux_amd64.tar.gz" >> "${PREFIX}.log"
	echo "tar -zxvf taxonkit_linux_amd64.tar.gz" >> "${PREFIX}.log"
	echo " " >> "${PREFIX}.log"
fi

if [[ -f "$edit" && -f "$dups" ]]; then
	echo "$edit and $dups ... OK"
else
	echo "$edit and $dups NOT FOUND."
	echo "$edit and $dups NOT FOUND." >> "${PREFIX}.log"
	echo " " >> "${PREFIX}.log"
fi

echo "Output filename: $PREFIX.uniq.fasta"
echo "Output filename: $PREFIX.uniq.fasta" >> "${PREFIX}.log" 
echo "References file: $REFERENCES"
echo "References file: $REFERENCES" >> "${PREFIX}.log"
refswc=$(grep -c "^>" $REFERENCES) 2>>"${PREFIX}.log"
TMP1=$(mktemp --tmpdir=".") 
TMP2=$(mktemp --tmpdir=".") 
TMP3=$(mktemp --tmpdir=".") 
TMP4=$(mktemp --tmpdir=".") 
TMP5=$(mktemp --tmpdir=".") 
TMP6=$(mktemp --tmpdir=".") 
TMP7=$(mktemp --tmpdir=".") 

#module --force purge
#module load StdEnv
#module load SeqKit/0.13.2

##extract accession code from NCBI references
echo "extracting accession code from NCBI references..."
echo "extracting accession code from NCBI references..." >> "${PREFIX}.log"
#source ~/anaconda3/etc/profile.d/conda.sh
#conda activate seqkitenv
seqkit seq --quiet -n -i $REFERENCES > "${TMP1}" 2>>"${PREFIX}.log"
#conda deactivate
accwc=$(wc -l $TMP1) 2>>"${PREFIX}.log"
echo "$accwc accession codes extracted:" 
echo "$accwc accession codes extracted:" >> "${PREFIX}.log"
head -3 $TMP1
echo "..."
head -3 $TMP1 >> "${PREFIX}.log"
echo "..." >> "${PREFIX}.log"
	
#join accession + taxid
echo "Parsing accession to taxid..."
echo "Parsing accession to taxid..." >> "${PREFIX}.log"
zcat nucl_gb.accession2taxid.gz | grep -w -f $TMP1 | cut -f 2,3 > "${TMP2}" 2>>"${PREFIX}.log"
acctaxwc=$(wc -l $TMP2) 2>>"${PREFIX}.log"
####get lineage
echo "Parsing accession/taxid to lineage..."
echo "Parsing accession/taxid to lineage..." >> "${PREFIX}.log"
cat $TMP2 | taxonkit lineage -i 2 | sed 1d | cut -f 1,3 > "${TMP3}" 2>>"${PREFIX}.log"
####lineage formatted to kingdom,phyla, class...
cat $TMP2 | taxonkit lineage -i 2 | taxonkit reformat -i 3 | sed 1d | cut -f 1,4 > "${TMP3}" 2>>"${PREFIX}.log"
linwc=$(wc -l $TMP3) 2>>"${PREFIX}.log"
#change the semicolon to pipe
sed 's/;/\|/g' $TMP3 > "${TMP4}" 2>>"${PREFIX}.log"
edwc=$(wc -l $TMP4) 2>>"${PREFIX}.log"
echo "removing NCBI sequences header, linearizing sequences..."
echo "removing NCBI sequences header, linearizing sequences..." >> "${PREFIX}.log"
sed '/^>/ s/ .*//' $REFERENCES > "${TMP5}" 2>>"${PREFIX}.log"
#source ~/anaconda3/etc/profile.d/conda.sh
#conda activate seqkitenv
seqkit seq --quiet -w 0 $TMP5 > "${TMP6}" 2>>"${PREFIX}.log"
#conda deactivate
#add a '+' sign in binomial species last lineage field
perl NCBI_lineage_edit.pl "${TMP4}" 2>>"${PREFIX}.log"
mv edit_lineage.out "${PREFIX}_edit_lineage.out" 2>>"${PREFIX}.log"
echo "joining edited lineage file with linearized sequences..."
echo "joining edited lineage file with linearized sequences..." >> "${PREFIX}.log"
#join final edited lineage file with the linearized NCBI sequences file
awk '/>/ {getline seq} {sub (">","",$0);print $0, seq}' $TMP6 | sort -k1 | join -1 1 -2 1 - <(sort -k1 "${PREFIX}_edit_lineage.out") -o 1.1,2.2,1.2 | awk '{print ">"$1" "$2"\n"$3}' > "${TMP7}" 2>>"${PREFIX}.log"
linedwc=$(grep -c "^>" $TMP7) 2>>"${PREFIX}.log"

#module --force purge
#module load StdEnv
#module load BioPerl/1.7.2-GCCcore-8.2.0-Perl-5.28.1

echo "removing sequence duplicates..."
echo "removing sequence duplicates..." >> "${PREFIX}.log"
perl NCBI_lineage_dups.pl "${TMP7}" "${PREFIX}" 2>>"${PREFIX}.log"
dupwc=$(grep -c "^>" "${PREFIX}.uniq.fasta") 2>>"${PREFIX}.log"
difference=$(( $(grep -c "^>" $TMP7) - $(grep -c "^>" "${PREFIX}.uniq.fasta") )) 2>>"${PREFIX}.log"
echo "Total number of original NCBI downloaded sequences: $refswc" >> "${PREFIX}.log"
echo "Total of accession codes extracted: $accwc" >> "${PREFIX}.log"
echo "Total accession + taxid joined: $acctaxwc" >> "${PREFIX}.log"
echo "Total lineage headers formatted: $edwc" >> "${PREFIX}.log"
echo "$linedwc sequences with lineage headers were succesfully formatted." >> "${PREFIX}.log"
echo "A total of $difference duplicates were removed, remaining $dupwc final sequences." &>> "${PREFIX}.log"
rm tmp* 2>>"${PREFIX}.log"
rm "${PREFIX}_edit_lineage.out"






