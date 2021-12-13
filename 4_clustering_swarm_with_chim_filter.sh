#/bin/bash

TMP_FASTA=$(mktemp --tmpdir=".")
PREFIX="${1}"
PWD="${2}"
GLOBAL_DB=${PREFIX}_global_dp.fas

####################################################################F
# Global dereplication
#####################################################################
cat "${PWD}"/*_dp.fasta > "${TMP_FASTA}"

vsearch --derep_fulllength "${TMP_FASTA}" \
        --sizein \
        --sizeout \
        --fasta_width 0 \
        --output ${GLOBAL_DB} > /dev/null

rm -f ${TMP_FASTA}

#####################################################################
#clustering with SWARM
#####################################################################

THREADS="8"
TMP_REPRESENTATIVES=$(mktemp --tmpdir=".")

swarm   \
    -d 1 -f -t ${THREADS} -z \
    -s ${PREFIX}_cluster_tmp.stats \
    -w ${TMP_REPRESENTATIVES} \
    -o ${PREFIX}_cluster_tmp.swarms < "${GLOBAL_DB}"

########################################################################
# Sort clustering representatives
########################################################################

REPRESENTATIVES=${PREFIX}_cluster_representatives_tmp.fas
STATS=${PREFIX}_cluster_tmp.stats
SWARMS=${PREFIX}_cluster_tmp.swarms

vsearch \
        --fasta_width 0 \
        --sortbysize ${TMP_REPRESENTATIVES} \
        --output ${REPRESENTATIVES}
rm ${TMP_REPRESENTATIVES}

FINAL1=${REPRESENTATIVES/_representatives_tmp.fas/_representatives.fas}
sed -e '/^>/ s/;ee=[0-9]*.[0-9]*//g' "${REPRESENTATIVES}" > "${FINAL1}"
FINAL2=${FINAL1/_representatives.fas/_representatives2blast.fas}
sed -e '/^>/ s/;size=/_/g' -e '/^>/ s/;//g' "${FINAL1}" > "${FINAL2}"
FINAL3=${STATS/_tmp.stats/.stats}
sed -e '/^>/ s/;ee=[0-9]*.[0-9]*//g' "${STATS}" > "${FINAL3}"
FINAL4=${SWARMS/_tmp.swarms/.swarms}
sed -e '/^>/ s/;ee=[0-9]*.[0-9]*//g' "${SWARMS}" > "${FINAL4}"
rm ${STATS}
rm ${SWARMS}

#####################################################################
# Chimera checking
#####################################################################
TMP_NOCHIMERAS=$(mktemp --tmpdir=".")
UCHIME=${REPRESENTATIVES/_tmp.fas/_tmp.uchime}
CHIMERAS=${REPRESENTATIVES/_tmp.fas/.chimeras}
#nonchimeras sorting with renaming
NOCHIMERAS=${REPRESENTATIVES/_tmp.fas/_nochimeras.fas}

vsearch --uchime_denovo "${REPRESENTATIVES}" \
        --chimeras "${CHIMERAS}"        \
        --abskew 2      \
        --fasta_score   \
        --nonchimeras "${TMP_NOCHIMERAS}"   \
        --sizeout       \
        --uchimeout "${UCHIME}"

vsearch \
        --fasta_width 0 \
        --sortbysize ${TMP_NOCHIMERAS} \
        --output ${NOCHIMERAS}
rm ${TMP_NOCHIMERAS}

#General abundance editing
FINAL5=${UCHIME/_tmp.uchime/.uchime}
sed -e '/^>/ s/;ee=[0-9]*.[0-9]*//g' "${UCHIME}" > "${FINAL5}"
rm ${UCHIME}
rm ${REPRESENTATIVES}
mkdir chimera_out
mv *_nochimeras.fas *.chimeras chimera_out

