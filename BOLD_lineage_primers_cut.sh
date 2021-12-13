#!/bin/bash

INPUT="${1}"
PRIMER_F="${2}"
PRIMER_R="${3}"
filename=$(basename -- "$INPUT")
filename="${filename%.*}"
TMP_FASTA="tmp.fasta"
TMP_FASTA2="tmp2.fasta"
TMP_FASTA3="tmp3.fasta"
FINAL=${filename}_cut.fasta

if [ -z "${PRIMER_F}" ] || [ -z "${PRIMER_R}" ]; then

awk 'BEGIN {FS = "\t"}
     {if (NR > 1) {
           print ">"$1"/"$7" "$9"|"$11"|"$13"|"$15"|"$17"|"$19"|"$21"|"$23"\n"$45
           }}' "${INPUT}" >> "${TMP_FASTA}"
sed -e '/^[a-zA-Z]/ s/-*//g' "${TMP_FASTA}" >> "${TMP_FASTA2}"
sed -e '/^>  / s/  /BOLD? /g' "${TMP_FASTA2}" >> "${FINAL}"
rm "${TMP_FASTA}"
rm "${TMP_FASTA2}"

else

awk 'BEGIN {FS = "\t"}
     {if (NR > 1) {
           print ">"$1"/"$7" "$9"|"$11"|"$13"|"$15"|"$17"|"$19"|"$21"|"$23"\n"$45
           }}' "${INPUT}" >> "${TMP_FASTA}"
sed -e '/^[a-zA-Z]/ s/-*//g' "${TMP_FASTA}" >> "${TMP_FASTA2}"
sed -e '/^>  / s/  /BOLD? /g' "${TMP_FASTA2}" >> "${TMP_FASTA3}"

cutadapt --quiet --discard-untrimmed -g "${PRIMER_F}" -a "${PRIMER_R}" -o "${FINAL}" "${TMP_FASTA3}"

rm "${TMP_FASTA}"
rm "${TMP_FASTA2}"
rm "${TMP_FASTA3}"

fi


