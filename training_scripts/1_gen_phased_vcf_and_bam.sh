#!/bin/bash
#Ensure that the BAM file is generated from the desired sequencing platform and it is indicated in the output name.
WHATSHAP="[WHATSHAP_PATH]"
PARALLEL="[PARALLEL_PATH]"
SAMTOOLS="[SAMTOOLS_PATH]"
CHR_PREFIX="chr"
CHR=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22)
OUTPUT_DIR="[OUTPUT_PATH_FOR_THIS_PLATFORM]"
PHASE_VCF_PATH="${OUTPUT_DIR}/phased_vcf"
PHASE_BAM_PATH="${OUTPUT_DIR}/phased_bam"
mkdir -p ${PHASE_VCF_PATH}
mkdir -p ${PHASE_BAM_PATH}
THREADS=24
VCF_FILE_PATH="[TRAINING_SAMPLE_TRUTH_VCF_PATH]"
BAM_FILE_PATH="[TRAINING_SAMPLE_BAM_FILE_PATH]"
REFERENCE_FILE_PATH="[REFERENCE_PATH]"
cd ${OUTPUT_DIR}

# WhatsHap phasing vcf file if vcf file includes '|' in INFO tag
${WHATSHAP} unphase ${VCF_FILE_PATH} > ${OUTPUT_DIR}/INPUT.vcf.gz

# WhatsHap phase vcf file
${PARALLEL} --joblog ${PHASE_VCF_PATH}/phase.log -j${THREADS} \
"${WHATSHAP} phase \
    --output ${PHASE_VCF_PATH}/phased_{1}.vcf.gz \
    --reference ${REFERENCE_FILE_PATH} \
    --chromosome ${CHR_PREFIX}{1} \
    --ignore-read-groups \
    --distrust-genotypes \
    ../INPUT.vcf.gz \
    ${BAM_FILE_PATH}" ::: ${CHR[@]}

# Index phased vcf file
${PARALLEL} -j ${THREADS} tabix -p vcf ${PHASE_VCF_PATH}/phased_{1}.vcf.gz ::: ${CHR[@]}

#generate phased bam
${PARALLEL} --joblog ${PHASE_BAM_PATH}/haplotag.log -j${THREADS} \
"${WHATSHAP} haplotag \
    --output ${PHASE_BAM_PATH}/{1}.bam \
    --reference ${REFERENCE_FILE_PATH} \
    --regions ${CHR_PREFIX}{1} \
    --ignore-read-groups \
    ${PHASE_VCF_PATH}/phased_{1}.vcf.gz \
    ${BAM_FILE_PATH}" ::: ${CHR[@]}

${SAMTOOLS} merge -@48 ${OUTPUT_DIR}/merged.bam ${PHASE_BAM_PATH}/*.bam 
${SAMTOOLS} index -@48 ${OUTPUT_DIR}/merged.bam ::: ${CHR[@]}
