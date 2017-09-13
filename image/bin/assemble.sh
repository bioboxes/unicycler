#!/bin/bash

set -o nounset
set -o errexit
set -o xtrace

READ_1=$(mktemp --suffix=.fq.gz)
READ_2=$(mktemp --suffix=.fq.gz)

INPUT=$(biobox_args.sh 'select(has("fastq")) | .fastq | map(.value) | .[0]')

TASK=$1
MODE=$(fetch_task_from_taskfile.sh $TASKFILE $TASK)

# Split FASTQ into different files
zcat ${INPUT} \
	| paste - - - - - - - - \
	| tee >(cut -f 1-4 | tr "\t" "\n" | pigz --processes $(nproc) > ${READ_1}) \
	| cut -f 5-8 | tr "\t" "\n" | pigz --processes $(nproc) > ${READ_2}

TMP=$(mktemp -d)

unicycler \
	--short1 ${READ_1} \
	--short2 ${READ_2} \
	--out ${TMP} \
	--threads $(nproc) \
	--mode ${MODE} \
	--no_rotate \
	--keep 0

cp ${TMP}/assembly.fasta ${OUTPUT}/contigs.fa

rm -rf ${READ_1} ${READ_2} ${TMP}

cat << EOF > ${OUTPUT}/biobox.yaml
version: 0.9.0
arguments:
  - fasta:
    - id: contigs_1
      value: contigs.fa
      type: contigs
EOF
