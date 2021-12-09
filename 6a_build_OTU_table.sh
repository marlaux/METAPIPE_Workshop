#!/bin/bash

SCRIPT="6_OTU_contingency_table.py"
REPRESENTATIVES=$1
#filename=$(basename -- ${REPRESENTATIVES})
#filename="${filename%.*}"
QUALITY=$2
STATS="${REPRESENTATIVES/_representatives.fas/.stats}"
SWARMS="${REPRESENTATIVES/_representatives.fas/.swarms}"
UCHIME="${REPRESENTATIVES/.fas/.uchime}"
ASSIGNMENTS=$3
OTU_TABLE="${REPRESENTATIVES/_representatives.fas/_OTU_table_complete.tab}"
PWD="${4}"

#module --force purge
#module load StdEnv
#module load Python/2.7.15-GCCcore-8.2.0
#source ~/anaconda3/etc/profile.d/conda.sh
#source ~/.bashrc
#conda init bash
#conda activate env_py27
conda run -n env_py27 python \
    "${SCRIPT}" \
    "${REPRESENTATIVES}" \
    "${STATS}" \
    "${SWARMS}" \
    "${UCHIME}" \
    "${QUALITY}" \
    "${ASSIGNMENTS}" \
    ${PWD}/*_dp.fasta > "${OTU_TABLE}" 2>/dev/null
conda deactivate



