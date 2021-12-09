#!/bin/sh

FASTA=''
DB=''
SIM=''
COV=''
THREADS=''
OUT=''
TASK="megablast"
HITS_PER_SUBJECT="1"
EVALUE="0.001"

usage () {
        echo "##################################################"
        echo "BLAST alignment against custom or NCBI NT local database."
        echo " "
        echo "Usage: ${0} [-f fasta] [-d database] [-s float] [-c float] [-t treads] [-o output]"
        echo "-f     representative OTUs multifasta from clustering step"
        echo "-d     database to align against: 'NT' or 'My_refs.uniq.fasta'"
        echo "-s     minimum similarity between query and subject, float 0-1"
        echo "-c     minimum subject coverage reached by the query alignment, float 0-1"
        echo "-t     number of threads:"
        echo "           custom database: 2 threads for each 1000 seqs."
        echo "           NCBI NT database: 4 threads for each 1000 seqs."
        echo "-o     output name: 'name'_local_blast.tab"
        echo "-h     print this help"
        echo " "
        echo "##################################################"
                1>&2; exit 1;

}

while getopts "f:d:s:c:t:o:h" option; do
        case $option in
        f) FASTA="${OPTARG}"
                ;;
        d) DB="${OPTARG}"
                ;;
        s) SIM="${OPTARG}"
                ;;
        c) COV="${OPTARG}"
                ;;
        t) THREADS="${OPTARG}"
                ;;
        o) OUT="${OPTARG}"
                ;;
        h | *) usage
                exit 0
                ;;
        \?) echo "Invalid option: -$OPTARG"
                exit 1
                ;;
        : ) echo "Missing argument for -${OPTARG}" >&2
                exit 1
                ;;
   esac
done

if [ $DB == "nt" ] || [ $DB == "NT" ]; then
        #update_blastdb.pl --decompress nt
        DB="/nt"
else
        makeblastdb -in $DB -dbtype nucl -parse_seqids
fi

        blastn -query $FASTA \
        -task $TASK \
        -db $DB \
        -num_threads $THREADS \
        -perc_identity $SIM  \
        -qcov_hsp_perc $COV  \
        -max_target_seqs $HITS_PER_SUBJECT  \
        -evalue $EVALUE \
        -parse_deflines \
        -outfmt "6 qseqid pident stitle sseqid sscinames"       \
        -out ${OUT}_local_blast.tab

perl 5_Blast_results_format.pl ${OUT}_local_blast.tab
sed 's/||/|NA|/g' Blast_results_formatted2OTUtable_tmp.tab > Blast_results_formatted2OTUtable.tab
perl 5_taxa_assignment_table.pl Blast_results_formatted2OTUtable.tab ${OUT}
awk '!seen[$1]++' ${OUT}_OTU_tax_assignments_tmp.txt > ${OUT}_OTU_tax_assignments.txt
rm Blast_results_formatted2OTUtable_tmp.tab
rm ${OUT}_OTU_tax_assignments_tmp.txt
