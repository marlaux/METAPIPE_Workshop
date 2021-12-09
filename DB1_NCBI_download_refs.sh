#!/bin/bash

TAXON_NAME=''
TXID=''
MARKER=''

usage () {
        echo "##################################################"
        echo " "
        echo "DOWNLOAD NCBI SEQUENCES"
        echo " "
        echo "Usage: ${0} [-n taxon name] [-t taxonid] [-m marker]"
        echo "-n     target taxon name, e.g. Arachnida"
        echo "-t     NCBI Taxonomy ID, e.g txid6854"
        echo "-m     marker, e.g. COI, ITS, ITS1, ITS2, trnL, rbcL, matK..."
        echo "-h     print this help"
        echo "srun --ntasks=1 --mem-per-cpu=8G --time=02:00:00 --qos=devel --account=nn9813k --pty bash -i"
        echo "make sure that '--account=nn9813k' is your user project!"
        echo " "
        echo "##################################################"
                > /dev/null 2>&1; exit 1;

}
while getopts "n:t:m:h" option; do
        case $option in
        n) TAXON_NAME="${OPTARG}"
                ;;
        t) TXID="${OPTARG}"
                ;;
        m) MARKER="${OPTARG}"
                ;;
        h | *) usage
                exit 0
                ;;
        \?) echo "Invalid option: -$OPTARG"
                exit 1
                ;;
   esac
done

if [ -z "${TAXON_NAME}" ] || [ -z "${TXID}" ] || [ -z "${MARKER}" ]
        then
                echo 'Missing argument' >&2
                exit 1
fi
if [ "$MARKER" = "COI" ] || [ "$MARKER" = "CO1" ] || [ "$MARKER" = "COX" ]; then
        QUERY="${TXID} [ORGN] AND (COI [TI] OR CO1 [TI] OR COX [TI] OR cytochrome oxidase subunit 1 [TI])"
        OUT="${TAXON_NAME}_${MARKER}_NCBI.fasta"
        esearch -db nuccore -query "${QUERY}" | efetch -format fasta >> "${OUT}"
fi

if [ "$MARKER" = "ITS1" ] || [ "$MARKER" = "ITS-1" ] || [ "$MARKER" = "ITS 1" ]; then
        QUERY="${TXID} [ORGN] AND (ITS1 [TI] OR ITS-1 [TI] OR ITS 1 [TI] OR ITS_1 [TI] OR internal transcribed spacer 1 [TI])"
        OUT="${TAXON_NAME}_${MARKER}_NCBI.fasta"
        esearch -db nuccore -query "${QUERY}" | efetch -format fasta >> "${OUT}"
fi

if [ "$MARKER" = "ITS2" ] || [ "$MARKER" = "ITS-2" ] || [ "$MARKER" = "ITS 2" ]; then
        QUERY="${TXID} [ORGN] AND (ITS2 [TI] OR ITS-2 [TI] OR ITS 2 [TI] OR ITS_2 [TI] OR internal transcribed spacer 2 [TI])"
        OUT="${TAXON_NAME}_${MARKER}_NCBI.fasta"
        esearch -db nuccore -query "${QUERY}" | efetch -format fasta >> "${OUT}"
fi

if [ "$MARKER" = "ITS" ]; then
        QUERY="${TXID} [ORGN] AND (ITS1 [TI] OR ITS2 [TI] OR internal transcribed spacer [TI])"
        OUT="${TAXON_NAME}_${MARKER}_NCBI.fasta"
        esearch -db nuccore -query "${QUERY}" | efetch -format fasta >> "${OUT}"
fi

if [ "$MARKER" != "COI" ] || [ "$MARKER" != "CO1" ] || [ "$MARKER" != "COX" ] || [ "$MARKER" != "ITS" ] || [ "$MARKER" != "ITS1" ] || [ "$MARKER" != "ITS-1" ] || [ "$MARKER" != "ITS 1" ] || [ "$MARKER" != "ITS2" ] || [ "$MARKER" != "ITS-2" ] || [ "$MARKER" != "ITS 2" ]; then
        OUT="${TAXON_NAME}_${MARKER}_NCBI.fasta"
        esearch -db nuccore -query "${TXID} [ORGN] AND ${MARKER} [TI]" | efetch -format fasta >> "${OUT}"
fi
