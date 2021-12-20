#/bin/bash

INPUT=''
PRIMER_F=''
PRIMER_R=''
PREFIX=''

usage () {
        echo "##################################################"
        echo "CUT THE REFERENCES SEQUENCES ACCORDING YOUR PRIMERS PAIR"
        echo "##################################################"
	echo " "
        echo "Usage: ${0} [-r reference_dataset.fasta] [-F primer forwad] [-R primer reverse] [-p prefix]"
        echo "-r     references fasta file downloaded"
        echo "-F     primer forward"
        echo "-R     primer reverse"
        echo "-p     prefix for primer pair"
        echo "-h     print this help"
        echo " "
        echo "##################################################"
                1>&2; exit 1;

}
while getopts "r:F:R:p:h" option; do
        case $option in
        r) INPUT="${OPTARG}"
                ;;
        F) PRIMER_F="${OPTARG}"
                ;;
        R) PRIMER_R="${OPTARG}"
                ;;
        p) PREFIX="${OPTARG}"
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

cutadapt	\
	--discard-untrimmed	\
	-g ${PRIMER_F}	\
	-a ${PRIMER_R}	\
	${INPUT} > "${PREFIX}_cutted_references.fasta"
