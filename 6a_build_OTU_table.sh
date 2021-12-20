#!/bin/bash

SCRIPT="6a_OTU_contingency_table.py"
REPRESENTATIVES=$1
QUALITY=$2
STATS="${REPRESENTATIVES/_representatives.fas/.stats}"
SWARMS="${REPRESENTATIVES/_representatives.fas/.swarms}"
UCHIME="${REPRESENTATIVES/.fas/.uchime}"
ASSIGNMENTS=$3
OTU_TABLE="${REPRESENTATIVES/_representatives.fas/_OTU_table_complete.tab}"
PWD="${4}"

conda run -n py27 python \
    "${SCRIPT}" \
    "${REPRESENTATIVES}" \
    "${STATS}" \
    "${SWARMS}" \
    "${UCHIME}" \
    "${QUALITY}" \
    "${ASSIGNMENTS}" \
    ${PWD}/*_dp.fasta > "${OTU_TABLE}" 2>/dev/null



