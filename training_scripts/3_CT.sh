PARALLEL="[PARALLEL_PATH]"
PYPY="[PYPY_PATH]"
SAMTOOLS="[SAMTOOLS_PATH]"
PYTHON3="[PYTHON3_PATH]"

THREADS=16
#please follow the instruction here to specific the value for "PLATFORM"
#if you are training ONT-Illumina, please use 'ont';
#if you are training ONT-PacBio, please use 'ont';
#if you are training PacBio-Illumina, please use 'hifi'. 
PLATFORM="[PLATFORM_NAME]"


#DUAL_NAME=$1
CLAIR3_MP_PATH="[CLAIR3-MP_PATH]"
CLAIR3_MP="${CLAIR3_MP_PATH}/clair3.py"
# creating working folder
TRAIN_FOLDER_PREFIX="[OUTPUT_DIR]/4_build_tensors"
BUILD_N="[BUILD_NAME]"                      
# Temporary working directories
TRAIN_FOLDER="${TRAIN_FOLDER_PREFIX}"
mkdir -p ${TRAIN_FOLDER}

DATASET_FOLDER_PATH="${TRAIN_FOLDER}/build/${BUILD_N}"
TENSOR_CANDIDATE_FOLDER_PATH="${DATASET_FOLDER_PATH}/tensor_can"
BINS_FOLDER_PATH="${DATASET_FOLDER_PATH}/bins"
READ_FOLDER_PATH="${DATASET_FOLDER_PATH}/read_info"
INDEL_PATH="${DATASET_FOLDER_PATH}/alt_info"
SPLIT_BED_PATH="${DATASET_FOLDER_PATH}/split_beds"
PHASE_VCF_PATH="${DATASET_FOLDER_PATH}/phased_vcf"
PHASE_BAM_PATH="${DATASET_FOLDER_PATH}/phased_bam"
LOG_PATH="${DATASET_FOLDER_PATH}/log"
mkdir -p ${DATASET_FOLDER_PATH}
mkdir -p ${TENSOR_CANDIDATE_FOLDER_PATH}
mkdir -p ${BINS_FOLDER_PATH}
mkdir -p ${READ_FOLDER_PATH}
mkdir -p ${INDEL_PATH}
mkdir -p ${SPLIT_BED_PATH}
mkdir -p ${PHASE_VCF_PATH}
mkdir -p ${PHASE_BAM_PATH}
mkdir -p ${LOG_PATH}
cd ${DATASET_FOLDER_PATH}


# log file suffix name
_LOG_SUF=""                         # log file suffix

# input files and parameters
# training chrosome name, and prefix
CHR=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22)
CHR_PREFIX="chr"

SAMPLE_NAME_PLATFORM_A="[SAMPLE_NAME_SPECIFIC_FOR_PLATFORM_A]"
SAMPLE_NAME_PLATFORM_B="[SAMPLE_NAME_SPECIFIC_FOR_PLATFORM_B]"

# sample name
ALL_SAMPLE=(
${SAMPLE_NAME_PLATFORM_A}
${SAMPLE_NAME_PLATFORM_B}
)


MP_N="${BUILD_N}_MP"
DEPTH="[NAMES_FOR_DEPTH_COMBO]" #naming purposes, if samples coverages are 10x and 30x, could be 1030
DEPTHS=(                            # data coverage
${DEPTH}
${DEPTH}
)

REF_FILE_PATH="[REFERENCE_PATH]"
BED_FILE_PATH="[SAMPLE_TRUTH_VCF's_BED_FILE]"

ALL_REFERENCE_FILE_PATH=(
"${REF_FILE_PATH}"
"${REF_FILE_PATH}"
)


ALL_BED_FILE_PATH=(
"${BED_FILE_PATH}"
"${BED_FILE_PATH}"
)

PLATFORM_A_PILEUP="[SAMPLE_PLATFORM_A_PILEUP_FILE]"
PLATFORM_B_PILEUP="[SAMPLE_PLATFORM_B_PILEUP_FILE]"

ALL_PILEUP_VCF_FILE_PATH=(
${PLATFORM_A_PILEUP}
${PLATFORM_B_PILEUP}
)


# Each line represents one representation-unified path for each input sample platform
# note the all path have a folder called **var_ru**
# check the representation_unification.md page for more information
# for practical concerns, the representation_unification.md require only run once on the highest depth for each sample, while the low coverage can be sampled from the highest coverage data, i.e. merged.bam in the representation_unification folder

PLATFORM_A_RU="[RU_FOR_SAMPLE_PLATFORM_A]"
PLATFORM_B_RU="[RU_FOR_SAMPLE_PLATFORM_B]"
ALL_RU_FILE_PATH=(
"${PLATFORM_A_RU}"
"${PLATFORM_B_RU}"
)

PLATFORM_A_BAM="[BAM_FOR_SAMPLE_PLATFORM_A]"
PLATFORM_B_BAM="[BAM_FOR_SAMPLE_PLATFORM_B]"
ALL_PHASED_BAM_FILE_PATH=(
${PLATFORM_A_BAM}
${PLATFORM_B_BAM}
)
# GH
# set up array for create tensors input
INPUT_PILEUP_VCF_C=()
INPUT_PILEUP_VCF_P1=()

TRUE_RU_FILE_C=()
TRUE_RU_FILE_P1=()

DEPTH_S=()

# GH
# create the list for candidates input
for i in $(seq 0 $((${#ALL_SAMPLE[@]}-1)))
do
	
    if [ $(($i % 2)) -eq 0 ]; then
        INPUT_PILEUP_VCF_C+=("${ALL_PILEUP_VCF_FILE_PATH[$(($i))]}")
        INPUT_PILEUP_VCF_P1+=("${ALL_PILEUP_VCF_FILE_PATH[$(($i+1))]}")

        TRUE_RU_FILE_C+=("${ALL_RU_FILE_PATH[$(($i))]}")
        TRUE_RU_FILE_P1+=("${ALL_RU_FILE_PATH[$(($i+1))]}")
        
        DEPTH_S+=("${DEPTHS[$(($i))]}")
    fi
done

echo ${INPUT_PILEUP_VCF_C[@]}
echo ${INPUT_PILEUP_VCF_P1[@]}
echo ${TRUE_RU_FILE_C[@]}
echo ${TRUE_RU_FILE_P1[@]}
echo ${DEPTH_S[@]}
echo ${ALL_PILEUP_VCF_FILE_PATH[@]}
echo ${ALL_RU_FILE_PATH[@]}
# created tensors chunk number for each chr
chunk_num=20
CHUNK_LIST=`seq 1 ${chunk_num}`

# create tensors bin chunk number for each chr
bin_chunk_num=10
BIN_CHUNK_LIST=`seq 1 ${bin_chunk_num}`

echo "[INFO] Select Candidates"
# Select sample candidates from pileup candidates using the SelectHetSnp_Dual submodule
time ${PARALLEL} --joblog ${LOG_PATH}/S_fiter_hete_snp_pileup${_LOG_SUF}.log -j${THREADS} \
"${PYPY} ${CLAIR3_MP} SelectHetSnp_Dual \
--alt_fn_c {2} \
--alt_fn_p1 {3} \
--var_fn_c {4}/var_ru/var_{1} \
--var_fn_p1 {5}/var_ru/var_{1} \
--split_folder ${SPLIT_BED_PATH} \
--sampleName ${MP_N} \
--depth {6} \
--ref_pct_full 0.2 \
--var_pct_full 1.0 \
--ref_var_max_ratio 1.0 \
--for_train 1 \
--chunk_num ${chunk_num} \
--bed ${BED_FILE_PATH} \
--ctgName ${CHR_PREFIX}{1}" ::: ${CHR[@]} ::: ${INPUT_PILEUP_VCF_C[@]} :::+ ${INPUT_PILEUP_VCF_P1[@]} :::+ ${TRUE_RU_FILE_C[@]} :::+ ${TRUE_RU_FILE_P1[@]} :::+ ${DEPTH_S[@]} |& tee ${LOG_PATH}/FHSP${_LOG_SUF}.log

echo "[INFO] Create Tensors"
time ${PARALLEL} --joblog ${LOG_PATH}/S_create_tensor${_LOG_SUF}.log -j${THREADS} \
"${PYPY} ${CLAIR3_MP} CreateTensorFullAlignment \
--bam_fn {4} \
--ref_fn {5} \
--tensor_can_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_{2}_{3}_{1}_{6} \
--indel_fn ${INDEL_PATH}/{2}_{3}_{1}_{6} \
--ctgName ${CHR_PREFIX}{1} \
--samtools ${SAMTOOLS} \
--platform ${PLATFORM} \
--full_aln_regions ${SPLIT_BED_PATH}/${MP_N}_{3}_{1}_{6} \
--add_no_phasing_data_training \
--phasing_info_in_bam" ::: ${CHR[@]} ::: ${ALL_SAMPLE[@]} :::+ ${DEPTHS[@]} :::+ ${ALL_PHASED_BAM_FILE_PATH[@]} :::+ ${ALL_REFERENCE_FILE_PATH[@]} ::: ${CHUNK_LIST[@]} |& tee ${LOG_PATH}/CT${_LOG_SUF}.log

echo "[INFO] Merge Tensors"
# merge the tensors, noted that merged no depth info
time ${PARALLEL} --joblog ${LOG_PATH}/S_merge_tensors${_LOG_SUF}.log -j${THREADS} \
"${PYTHON3} ${CLAIR3_MP} Merge_Tensors_Dual \
--tensor_fn_c ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${ALL_SAMPLE[0]}_{3}_{1}_{2} \
--tensor_fn_p1 ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${ALL_SAMPLE[1]}_{3}_{1}_{2} \
--candidate_fn_c ${INDEL_PATH}/${ALL_SAMPLE[0]}_{3}_{1}_{2} \
--candidate_fn_p1 ${INDEL_PATH}/${ALL_SAMPLE[1]}_{3}_{1}_{2} \
--tensor_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${MP_N}_{3}_{1}_{2} \
--candidate_fn ${INDEL_PATH}/${MP_N}_{3}_{1}_{2} \
" ::: ${CHR[@]} ::: ${CHUNK_LIST[@]} ::: ${DEPTH_S[@]} |& tee ${LOG_PATH}/MT${_LOG_SUF}.log


IF_CHECK_MCV=0  # whether filter MCV in training data

echo "[INFO] Tensor to Bins"
time ${PARALLEL} --joblog ${LOG_PATH}/S_tensor2Bin${_LOG_SUF}.log -j${THREADS} \
"${PYTHON3} ${CLAIR3_MP} Tensor2Bin_Dual \
--tensor_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${MP_N}_{3}_{1} \
--var_fn_c {4}/var_ru/var_{1} \
--var_fn_p1 {5}/var_ru/var_{1} \
--bin_fn ${BINS_FOLDER_PATH}/${MP_N}_{3}_{1}_{2} \
--chunk_id {2} \
--chunk_num ${bin_chunk_num} \
--platform ${PLATFORM} \
--allow_duplicate_chr_pos \
--maximum_non_variant_ratio 1.0 \
--check_mcv ${IF_CHECK_MCV} \
--shuffle" ::: ${CHR[@]} ::: ${BIN_CHUNK_LIST[@]} ::: ${DEPTH_S[@]} :::+ ${TRUE_RU_FILE_C[@]} :::+ ${TRUE_RU_FILE_P1[@]} |& tee ${LOG_PATH}/T2B${_LOG_SUF}.log

#this step is optional, depends if downsample of the training data will be performed subsequently
ALL_BINS_FOLDER_PATH="${BINS_FOLDER_PATH}/../all_bins"
mkdir -p ${ALL_BINS_FOLDER_PATH}
${PARALLEL} --joblog ${LOG_PATH}/S_mergeBin${_LOG_SUF}.log -j${THREADS} \
"${PYTHON3} ${CLAIR3_MP} MergeBin_Dual \
    ${BINS_FOLDER_PATH}/${MP_N}_{2}_{1}_* \
    --platform ${PLATFORM} \
    --out_fn ${ALL_BINS_FOLDER_PATH}/bin_{2}_{1}" ::: ${CHR[@]} ::: ${DEPTH_S[@]}
