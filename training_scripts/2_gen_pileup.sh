PARALLEL="[PARALLEL_PATH]"
PYPY="[PYPY_PATH]"
SAMTOOLS="[SAMTOOLS_PATH]"
PYTHON3="[PYTHON3_PATH]"
PLATFORM="[PLATFORM]" #ensure that if it is set to the platform that your data is generated from; 
                      #input "ont" for Oxford Nanopore, "hifi" for PacBio HiFi, "ilmn" for Illumina

# Clair3-MP folder
_ORI_CLAIR3="[CLAIR3-MP_PATH]"
# note the use right models for your training
# check https://github.com/HKU-BAL/Clair3 #pre-trained-models
PLATFORM_MODEL_PATH="[CLAIR3_MODEL_PATH_FOR_THIS_PLATFORM]"
C3_THREADS=3                                         # Clair3 threads number
THREADS=16    
DATASET_FOLDER_PATH="[OUTPUT_PATH]"

# creating working folder
PILEUP_OUTPUT_PATH="${DATASET_FOLDER_PATH}/pileup"

LOG_PATH="${PILEUP_OUTPUT_PATH}"
mkdir -p ${PILEUP_OUTPUT_PATH}
cd ${PILEUP_OUTPUT_PATH}


# input files and parameters
# training chrosome name, and prefix
CHR=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22)
CHR_PREFIX="chr"

SAMPLE_NAME="[SAMPLE_NAME]"

# sample name
ALL_SAMPLE=(
${SAMPLE_NAME}
)


DEPTHS=(                            # data coverage
"[COVERAGE_OF_THE_SAMPLE]"
)

ALL_PHASED_BAM_FILE_PATH=(
"[SAMPLE_PHASED_BAM_PATH]"
)

REF_FILE_PATH="[REFERENCE_PATH]"
BED_FILE="[TRUTH_BED_FILE_FOR_THE_SAMPLE]"

ALL_REFERENCE_FILE_PATH=(
"${REF_FILE_PATH}"
)


ALL_BED_FILE_PATH=(
"${BED_FILE}"
)

ALL_MODELS=(
${PLATFORM_MODEL_PATH}
)
ALL_PLATFORMS=(
"${PLATFORM}"
)

# log file suffix name
_LOG_SUF=""                         # log file suffix

# Run Clair3 pileup model
time ${PARALLEL} -j${C3_THREADS} --joblog  ${LOG_PATH}/input_pileup${_LOG_SUF}.log ${_ORI_CLAIR3}/run_clair3.sh \
  --bam_fn={5} \
  --ref_fn=${REF_FILE_PATH} \
  --threads=${THREADS} \
  --platform={2} \
  --model_path={3} \
  --output=${PILEUP_OUTPUT_PATH}/{1}_{4} \
  --bed_fn={6} \
  --pileup_only ::: ${ALL_SAMPLE[@]} :::+ ${ALL_PLATFORMS[@]} :::+ ${ALL_MODELS[@]} :::+ ${DEPTHS[@]} :::+ ${ALL_PHASED_BAM_FILE_PATH[@]} :::+ ${ALL_BED_FILE_PATH[@]}

