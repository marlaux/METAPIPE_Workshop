#!/bin/bash

TAXON=''
MARKER=''
GEO=''
URL="http://v3.boldsystems.org/index.php/API_Public/combined"

usage () {
        echo "##################################################"
        echo " "
        echo "DOWNLOAD BOLD SEQUENCES"
        echo " "
        echo "Usage: ${0} [-t taxon] [-m marker] [-g geo]"
        echo "-t     target taxon, e.g. Arthropoda"
        echo "-m     marker, e.g. COI"
        echo "-g     geographic location, e.g. Brazil"
        echo "-h     print this help"
        echo "More Details: http://boldsystems.org/index.php/resources/api?type=webservices#sequenceParameters"
        echo " "
        echo "##################################################"
                1>&2; exit 1;

}
while getopts "t:m:g:h" option; do
        case $option in
        t) TAXON="${OPTARG}"
                ;;
        m) MARKER="${OPTARG}"
                ;;
        g) GEO="${OPTARG}"
                ;;
        h | *) usage
                exit 0
                ;;
        \?) echo "Invalid option: -$OPTARG"
                exit 1
                ;;
   esac
done

if [ -z "${TAXON}" ] || [ -z "${MARKER}" ]
        then
                echo 'Missing argument' >&2
                exit 1
fi

echo "searching and downloading:"
echo "TAXON=${TAXON}"
echo "MARKER=${MARKER}"
echo "GEO=${GEO}"
QUERY1="${URL}?taxon=${TAXON}&marker=${MARKER}&format=tsv"
OUT1="BOLD_${TAXON}_${MARKER}.tsv"
QUERY2="${URL}?taxon=${TAXON}&marker=${MARKER}&geo=${GEO}&format=tsv"
OUT2="BOLD_${TAXON}_${MARKER}_${GEO}.tsv"


if [ -z "${GEO}" ]; then
	wget -O "${OUT1}" "${QUERY1}"

else
        wget -O "${OUT2}" "${QUERY2}"
fi

exit 0

