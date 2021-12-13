#!/bin/bash

TABLE="${1}"
QUAL="${2}"
EE="${QUAL/.qual/.ee}"
F1="${TABLE/_complete.tab/_f1_basics2.tab}"
F2="${TABLE/_complete.tab/_f2_97up2.tab}"
F3="${TABLE/_complete.tab/_f3_hits_only2.tab}"
F4="${TABLE/_complete.tab/_f4_no_hit2.tab}"
CUT2PHYLOSEQ1="${F1/.tab/_cut2phyloseq2.tab}"
CUT2PHYLOSEQ2="${F2/.tab/_cut2phyloseq2.tab}"
CUT2PHYLOSEQ3="${F3/.tab/_cut2phyloseq2.tab}"
CUT2PHYLOSEQ4="${F4/.tab/_cut2phyloseq2.tab}"

#PRINT ALL FIELDS FILTERED
head -n 1 "${TABLE}" > "${F1}"
head -n 1 "${TABLE}" > "${F2}"
head -n 1 "${TABLE}" > "${F3}"
head -n 1 "${TABLE}" > "${F4}"
awk -F "\t" '{ if(($7 == "N") && ($2 >= 5)) { print } }' "${TABLE}" >> "${F1}"
cat "${F1}" | cut -f 4,14- | sed 's/_dp//g' > "${CUT2PHYLOSEQ1}"
awk -F "\t" '{ if(($7 == "N") && ($2 >= 5) && ($9<=0.0002) && ($11 >= 97)) { print } }' "${TABLE}" >> "${F2}"
cat "${F2}" | cut -f 4,14- | sed 's/_dp//g' > "${CUT2PHYLOSEQ2}"
awk -F "\t" '{ if(($7 == "N") && ($2 >= 5) && ($9<=0.0002) && ($12 != "NA")) { print } }' "${TABLE}" >> "${F3}"
cat "${F3}" | cut -f 4,14- | sed 's/_dp//g' > "${CUT2PHYLOSEQ3}"
awk -F "\t" '{ if(($7 == "N") && ($2 >= 5) && ($9<=0.0002) && ($12 == "NA")) { print } }' "${TABLE}" >> "${F4}"
cat "${F4}" | cut -f 4,14- | sed 's/_dp//g' > "${CUT2PHYLOSEQ4}"

awk '{ ratio = $2/$3; print $0, ratio }' "${QUAL}" > "${EE}"


