#!/bin/bash
SCRIPT_NAME=$(basename "$0")
Usage="Usage: ./${SCRIPT_NAME} --bam_fn_c=BAM --bam_fn_p1=BAM --ref_fn=REF --output=OUTPUT_DIR --threads=THREADS --model_path_clair3=MODEL_PREFIX --model_path_clair3_trio=MODEL_PREFIX [--bed_fn=BED] [options]"
# INFO: whole calling workflow of clair3

set -e
ARGS=`getopt -o f:t:p:o:r::c::s::h::g \
-l bam_fn_c:,bam_fn_p1:,bam_fn_c_platform:,bam_fn_p1_platform:,ref_fn:,threads:,model_path_clair3_c:,model_path_clair3_p1:,model_path_clair3_trio:,output:,\
bed_fn::,vcf_fn::,ctg_name::,sample_name_c::,sample_name_p1::,help::,qual::,samtools::,python::,pypy::,parallel::,whatshap::,chunk_num::,chunk_size::,var_pct_full::,var_pct_phasing_c::,var_pct_phasing_p1::,\
snp_min_af::,indel_min_af::,ref_pct_full_c::,ref_pct_full_p1::,pileup_only::,pileup_phasing::,fast_mode::,gvcf::,print_ref_calls::,haploid_precise::,haploid_sensitive::,include_all_ctgs::,\
no_phasing_for_fa::,pileup_model_prefix::,trio_model_prefix::,call_snp_only::,remove_intermediate_dir::,enable_phasing::,enable_long_indel:: -n 'run_clair3_trio.sh' -- "$@"`

if [ $? != 0 ] ; then echo"No input. Terminating...">&2 ; exit 1 ; fi
eval set -- "${ARGS}"

# default options
SAMPLE_C="SAMPLE_C"
SAMPLE_P1="SAMPLE_P1"
BED_FILE_PATH="EMPTY"
VCF_FILE_PATH='EMPTY'
CONTIGS="EMPTY"
SAMTOOLS="samtools"
PYPY="pypy3"
PYTHON='python3'
PARALLEL='parallel'
WHATSHAP='whatshap'
PLATFORM="ont"
CHUNK_NUM=0
CHUNK_SIZE=5000000
QUAL=2
PRO=0.3
REF_PRO=0
GVCF=False
RESUMN=0
PILEUP_ONLY=False
PILEUP_PHASING=False
FAST_MODE=False
SHOW_REF=False
SNP_AF=0
INDEL_AF=0
HAP_PRE=False
HAP_SEN=False
SNP_ONLY=False
INCLUDE_ALL_CTGS=False
NO_PHASING=False
PILEUP_PREFIX="pileup"
TRIO_PREFIX="trio"
RM_TMP_DIR=False
ENABLE_PHASING=False
ENABLE_LONG_INDEL=False


#ILMN_MODEL_PATH="/autofs/bal36/zxzheng/testData/ilmn/model"
#ONT_MODEL_PATH="/autofs/bal33/zxzheng/Clair3/clair3_models/ont_guppy5"
#PB_MODEL_PATH="/autofs/bal36/zxzheng/testData/hifi/model"
ILMN="ilmn"
ONT="ont"
PB="hifi"



while true; do
   case "$1" in    
    --bam_fn_c ) BAM_FILE_PATH_C="$2"; shift 2 ;;
    --bam_fn_p1 ) BAM_FILE_PATH_P1="$2"; shift 2 ;;
    --bam_fn_c_platform ) PLATFORM_C="$2"; shift 2 ;;
    --bam_fn_p1_platform ) PLATFORM_P1="$2"; shift 2 ;;
    -f|--ref_fn ) REFERENCE_FILE_PATH="$2"; shift 2 ;;
    -t|--threads ) THREADS="$2"; shift 2 ;;
    --model_path_clair3_c ) MODEL_PATH_C3_C="$2"; shift 2 ;;
    --model_path_clair3_p1 ) MODEL_PATH_C3_P1="$2"; shift 2 ;;
    --model_path_clair3_trio ) MODEL_PATH_C3T="$2"; shift 2 ;;
    -o|--output ) OUTPUT_FOLDER="$2"; shift 2 ;;
    --bed_fn ) BED_FILE_PATH="$2"; shift 2 ;;
    --vcf_fn ) VCF_FILE_PATH="$2"; shift 2 ;;
    --ctg_name ) CONTIGS="$2"; shift 2 ;;
    --sample_name_c ) SAMPLE_C="$2"; shift 2 ;;
    --sample_name_p1 ) SAMPLE_P1="$2"; shift 2 ;;
    --chunk_num ) CHUNK_NUM="$2"; shift 2 ;;
    --chunk_size ) CHUNK_SIZE="$2"; shift 2 ;;
    --qual ) QUAL="$2"; shift 2 ;;
    --samtools ) SAMTOOLS="$2"; shift 2 ;;
    --python ) PYTHON="$2"; shift 2 ;;
    --pypy ) PYPY="$2"; shift 2 ;;
    --parallel ) PARALLEL="$2"; shift 2 ;;
    --whatshap ) WHATSHAP="$2"; shift 2 ;;
    --var_pct_full ) PRO="$2"; shift 2 ;;
    --ref_pct_full_c ) REF_PRO_C="$2"; shift 2 ;;
    --ref_pct_full_p1 ) REF_PRO_P1="$2"; shift 2 ;;
    --var_pct_phasing_c ) PHASING_PCT_C="$2"; shift 2 ;;
    --var_pct_phasing_p1 ) PHASING_PCT_P1="$2"; shift 2 ;;
    --pileup_only ) PILEUP_ONLY="$2"; shift 2 ;;
    --pileup_phasing ) PILEUP_PHASING="$2"; shift 2 ;;
    --fast_mode ) FAST_MODE="$2"; shift 2 ;;
    --call_snp_only ) SNP_ONLY="$2"; shift 2 ;;
    --print_ref_calls ) SHOW_REF="$2"; shift 2 ;;
    --gvcf ) GVCF="$2"; shift 2 ;;
    --snp_min_af ) SNP_AF="$2"; shift 2 ;;
    --indel_min_af ) INDEL_AF="$2"; shift 2 ;;
    --pileup_model_prefix ) PILEUP_PREFIX="$2"; shift 2 ;;
    --trio_model_prefix ) TRIO_PREFIX="$2"; shift 2 ;;
    --haploid_precise ) HAP_PRE="$2"; shift 2 ;;
    --haploid_sensitive ) HAP_SEN="$2"; shift 2 ;;
    --include_all_ctgs ) INCLUDE_ALL_CTGS="$2"; shift 2 ;;
    --no_phasing_for_fa ) NO_PHASING="$2"; shift 2 ;;
    --remove_intermediate_dir ) RM_TMP_DIR="$2"; shift 2 ;;
    --enable_long_indel ) ENABLE_LONG_INDEL="$2"; shift 2 ;;
    --enable_phasing ) ENABLE_PHASING="$2"; shift 2 ;;
    -- ) shift; break; ;;
    -h|--help ) print_help_messages; break ;;
    * ) print_help_messages; exit 0 ;;
   esac
done

#echo "${SAMPLE_C}"

SHELL_FOLDER=$(cd "$(dirname "$0")";pwd)
CLAIR3_TRIO="${SHELL_FOLDER}/../clair3.py"



# if [ ${BED_FILE_PATH} = "EMPTY" ] ; then BED_FILE_PATH= ; fi
RETRIES=4

PILEUP_CHECKPOINT_PATH="${MODEL_PATH}/${PILEUP_PREFIX}"
FULL_ALIGNMENT_CHECKPOINT_PATH="${MODEL_PATH}/${FA_PREFIX}"
LOG_PATH="${OUTPUT_FOLDER}/log"
TMP_FILE_PATH="${OUTPUT_FOLDER}/tmp"
SPLIT_BED_PATH="${TMP_FILE_PATH}/trio_input/split_beds"
TENSOR_CANDIDATE_FOLDER_PATH="${TMP_FILE_PATH}/trio_input/tensor_can"
INDEL_PATH="${TMP_FILE_PATH}/trio_input/alt_info"
PILEUP_VCF_PATH="${TMP_FILE_PATH}/pileup_output"
GVCF_TMP_PATH="${TMP_FILE_PATH}/gvcf_tmp_output"
PHASE_OUTPUT_PATH="${TMP_FILE_PATH}/phase_output"
PILEUP_VCF_PATH="${TMP_FILE_PATH}/pileup_output"
TRIO_ALIGNMENT_OUTPUT_PATH="${TMP_FILE_PATH}/trio_alignment_output"
PHASE_VCF_PATH="${PHASE_OUTPUT_PATH}/phase_vcf"
PHASE_BAM_PATH="${PHASE_OUTPUT_PATH}/phase_bam"
CANDIDATE_BED_PATH="${FULL_ALIGNMENT_OUTPUT_PATH}/candidate_bed"
CALL_PATH="${TMP_FILE_PATH}/trio_output"
CANDIDATE_BED_PATH="${CALL_PATH}/candidate_bed"
export OPENBLAS_NUM_THREADS=1
export GOTO_NUM_THREADS=1
export OMP_NUM_THREADS=1


mkdir -p ${SPLIT_BED_PATH}
mkdir -p ${TENSOR_CANDIDATE_FOLDER_PATH}
mkdir -p ${INDEL_PATH}

echo ${OUTPUT_FOLDER}
echo "[INFO] You are running ${PLATFORM_C} + ${PLATFORM_P1} hybrid."
echo "[INFO] * Clir3-Trio pipeline start"
echo "[INFO] * 0/7 Check environment variables"
${PYTHON} ${CLAIR3_TRIO} CheckEnvs_Dual \
    --bam_fn_c ${BAM_FILE_PATH_C} \
    --bam_fn_p1 ${BAM_FILE_PATH_P1} \
    --output_fn_prefix ${OUTPUT_FOLDER} \
    --ctg_name ${CONTIGS} \
    --bed_fn ${BED_FILE_PATH} \
    --ref_fn ${REFERENCE_FILE_PATH} \
    --vcf_fn ${VCF_FILE_PATH} \
    --chunk_num ${CHUNK_NUM} \
    --chunk_size ${CHUNK_SIZE} \
    --include_all_ctgs ${INCLUDE_ALL_CTGS} \
    --threads ${THREADS} \
    --python ${PYTHON} \
    --pypy ${PYPY} \
    --samtools ${SAMTOOLS} \
    --whatshap ${WHATSHAP} \
    --parallel ${PARALLEL} \
    --qual ${QUAL} \
    --sampleName_c ${SAMPLE_C} \
    --sampleName_p1 ${SAMPLE_P1} \
    --var_pct_full ${PRO} \
    --ref_pct_full ${REF_PRO} \
    --snp_min_af ${SNP_AF} \
    --indel_min_af ${INDEL_AF}


readarray -t CHR < "${OUTPUT_FOLDER}/tmp/CONTIGS"
if [ ${#CHR[@]} -eq 0 ]; then echo "[INFO] Exit in environment checking"; exit 0; fi
THREADS_LOW=$((${THREADS}*3/4))
if [[ ${THREADS_LOW} < 1 ]]; then THREADS_LOW=1; fi

cd ${OUTPUT_FOLDER}

export CUDA_VISIBLE_DEVICES=""
echo "[INFO] * 1/7 Call variants using pileup model"



ALL_SAMPLE=(
${SAMPLE_C}
${SAMPLE_P1}
)

ALL_UNPHASED_BAM_FILE_PATH=(
${BAM_FILE_PATH_C}
${BAM_FILE_PATH_P1}
)

ALL_MODEL_PATH_C3=(
${MODEL_PATH_C3_C}
${MODEL_PATH_C3_P1}
)
if [ "${PLATFORM_C}" = "ont" ] && [ "${PLATFORM_P1}" = "ilmn" ]; then 
    CT_C="ont"
    CT_P1="ont" 
fi

if [ "${PLATFORM_C}" = "hifi" ] && [ "${PLATFORM_P1}" = "ilmn" ]; then
    CT_C="hifi"
    CT_P1="hifi"
fi

if [ "${PLATFORM_C}" = "ont" ] && [ "${PLATFORM_P1}" = "hifi" ]; then
    CT_C="ont"
    CT_P1="hifi"
fi
ALL_CT_PLATFORMS=(
${CT_C}
${CT_P1}
)

ALL_PU_PLATFORMS=(
${PLATFORM_C}
${PLATFORM_P1}
)

ALL_REF_pct_full=(
${REF_PRO_C}
${REF_PRO_P1}
)
ALL_PHASING_PCT=(
${PHASING_PCT_C}
${PHASING_PCT_P1}
)

CLAIR3_THREADS=$((${THREADS}/2))
if [[ ${CLAIR3_THREADS} < 1 ]]; then CLAIR3_THREADS=1; fi

echo "sample with different platforms" ${ALL_SAMPLE[@]}
echo "bam files" ${ALL_UNPHASED_BAM_FILE_PATH[@]}
echo "pileup threads" ${CLAIR3_THREADS}

echo "running hybrid pileup for dual samples"


${PARALLEL} -j3 --joblog  ${LOG_PATH}/parallel_1_clair3_pileup_dual.log \
"${SHELL_FOLDER}/..//scripts/clair3.sh \
    --bam_fn={2} \
    --ref_fn=${REFERENCE_FILE_PATH} \
    --threads=${CLAIR3_THREADS} \
    --model_path={3} \
    --output=${PILEUP_VCF_PATH}/{1} \
    --platform={4} \
    --bed_fn=${BED_FILE_PATH} \
    --vcf_fn=${VCF_FILE_PATH} \
    --ctg_name=${CONTIGS} \
    --sample_name={1} \
    --chunk_num=${CHUNK_NUM} \
    --chunk_size=${CHUNK_SIZE} \
    --samtools=${SAMTOOLS} \
    --python=${PYTHON} \
    --pypy=${PYPY} \
    --parallel=${PARALLEL} \
    --whatshap=${WHATSHAP} \
    --qual=${QUAL} \
    --var_pct_full=${PRO} \
    --ref_pct_full={5} \
    --snp_min_af=${SNP_AF} \
    --indel_min_af=${INDEL_AF} \
    --var_pct_phasing={6} \
    --pileup_only=False \
    --pileup_phasing=True \
    --gvcf=${GVCF} \
    --fast_mode=${FAST_MODE} \
    --call_snp_only=${SNP_ONLY} \
    --print_ref_calls=${SHOW_REF} \
    --haploid_precise=${HAP_PRE} \
    --haploid_sensitive=${HAP_SEN} \
    --include_all_ctgs=${INCLUDE_ALL_CTGS} \
    --no_phasing_for_fa=${NO_PHASING} \
    --remove_intermediate_dir=${RM_TMP_DIR} \
    --enable_phasing=${ENABLE_PHASING} \
    --enable_long_indel=${ENABLE_LONG_INDEL} \
    --pileup_model_prefix=${PILEUP_PREFIX} \
    --fa_model_prefix=full_alignment" ::: ${ALL_SAMPLE[@]} :::+ ${ALL_UNPHASED_BAM_FILE_PATH[@]} :::+ ${ALL_MODEL_PATH_C3[@]} :::+ ${ALL_PU_PLATFORMS[@]} :::+ ${ALL_REF_pct_full[@]} :::+ ${ALL_PHASING_PCT[@]} |& tee ${LOG_PATH}/1_call_var_bam_pileup_dual.log


# phased bam organized in different chr
ALL_PHASED_BAM_FILE_DIR=(
${PILEUP_VCF_PATH}/${SAMPLE_C}/tmp/phase_output/phase_bam/
${PILEUP_VCF_PATH}/${SAMPLE_P1}/tmp/phase_output/phase_bam/
)



INPUT_PILEUP_VCF=(
${PILEUP_VCF_PATH}/${SAMPLE_C}/pileup.vcf.gz
${PILEUP_VCF_PATH}/${SAMPLE_P1}/pileup.vcf.gz
)


TRIO_N="${ALL_SAMPLE}_DUAL"

# note that the phased bam stored in separate files between chromosome
echo ${CHR[@]}

chunk_num=20
CHUNK_LIST=`seq 1 ${chunk_num}`

# select candidate from trio input
echo "[INFO] * 2/7 Select Trio Candidates"
time ${PARALLEL} --joblog ${LOG_PATH}/parallel_2_fiter_hete_snp_pileup.log -j${THREADS} \
"${PYPY} ${CLAIR3_TRIO} SelectHetSnp_Dual \
--alt_fn_c ${INPUT_PILEUP_VCF[0]} \
--alt_fn_p1 ${INPUT_PILEUP_VCF[1]} \
--split_folder ${SPLIT_BED_PATH} \
--sampleName ${TRIO_N} \
--ref_pct_full 0.03 \
--var_pct_full 1.0 \
--ref_var_max_ratio 1.2 \
--chunk_num ${chunk_num} \
--chr_prefix '' \
--ctgName {1}" ::: ${CHR[@]} |& tee ${LOG_PATH}/2_FHSP.log


echo 'check newcode'

#echo "[INFO] * 3/7 running Clair3-Trio model"
#time ${PARALLEL}  --joblog ${LOG_PATH}/parallel_3_run_model.log -j${THREADS} \
#echo "${PYPY} ${CLAIR3_TRIO} CallVarBam_Trio \
#--bam_fn {3}/{1}.bam \
#--ref_fn ${REFERENCE_FILE_PATH} \
#--tensor_can_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_{2}_{1}_{4} \
#--indel_fn ${INDEL_PATH}/{2}_{1}_{4} \
#--ctgName {1} \
#--samtools ${SAMTOOLS} \
#--platform ${PLATFORM} \
#--full_aln_regions ${SPLIT_BED_PATH}/${TRIO_N}_1000_{1}_{4} \
#--phasing_info_in_bam" ::: ${CHR[@]} ::: ${ALL_SAMPLE[@]} :::+ ${ALL_PHASED_BAM_FILE_DIR[@]} ::: ${CHUNK_LIST[@]} |& tee ${LOG_PATH}/3_RM.log
#
#exit 0

# note that in training included the add_no_phasing_data_training
# no using the giab bed files
echo "[INFO] * 3/7 Creating Tensors"
echo "[DEBUG] Running ${ALL_CT_PLATFORMS[0]} and ${ALL_CT_PLATFORMS[1]} respectively for Create Tensor"
time ${PARALLEL}  --joblog ${LOG_PATH}/parallel_3_create_tensor.log -j${THREADS} \
"${PYPY} ${CLAIR3_TRIO} CreateTensorFullAlignment \
--bam_fn {3}/{1}.bam \
--ref_fn ${REFERENCE_FILE_PATH} \
--tensor_can_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_{2}_{1}_{5} \
--indel_fn ${INDEL_PATH}/{2}_{1}_{5} \
--ctgName {1} \
--samtools ${SAMTOOLS} \
--platform {4} \
--full_aln_regions ${SPLIT_BED_PATH}/${TRIO_N}_1000_{1}_{5} \
--phasing_info_in_bam" ::: ${CHR[@]} ::: ${ALL_SAMPLE[@]} :::+ ${ALL_PHASED_BAM_FILE_DIR[@]} :::+ ${ALL_CT_PLATFORMS[@]} ::: ${CHUNK_LIST[@]} |& tee ${LOG_PATH}/3_CT.log


echo "[INFO] * 4/7 Merging Trio Tensors"
time ${PARALLEL} --joblog ${LOG_PATH}/parallel_4_merge_tensors.log -j${THREADS} \
"${PYTHON} ${CLAIR3_TRIO} Merge_Tensors_Dual \
--tensor_fn_c ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${ALL_SAMPLE[0]}_{1}_{2} \
--tensor_fn_p1 ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${ALL_SAMPLE[1]}_{1}_{2} \
--candidate_fn_c ${INDEL_PATH}/${ALL_SAMPLE[0]}_{1}_{2} \
--candidate_fn_p1 ${INDEL_PATH}/${ALL_SAMPLE[1]}_{1}_{2} \
--tensor_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${TRIO_N}_{1}_{2} \
--candidate_fn ${INDEL_PATH}/${TRIO_N}_{1}_{2} \
" ::: ${CHR[@]} ::: ${CHUNK_LIST[@]} |& tee ${LOG_PATH}/4_MT.log

BINS_FOLDER_PATH="${TMP_FILE_PATH}/trio_input/bins"
mkdir -p ${BINS_FOLDER_PATH}

# create tensors bin chunk number for each chr
bin_chunk_num=1
BIN_CHUNK_LIST=`seq 1 ${bin_chunk_num}`


if [ "${PLATFORM_C}" = "hifi" ] && [ "${PLATFORM_P1}" = "ilmn" ]; then 
      PLATFORM="hifi"
fi

if [ "${PLATFORM_C}" = "ilmn" ] && [ "${PLATFORM_P1}" = "hifi" ]; then
      PLATFORM="hifi"
fi

echo "[DEBUG] The following steps would be using ${PLATFORM} for matrix size"
echo "[INFO] * 5/7 Coverting Tensors to Bins"
time ${PARALLEL} --joblog ${LOG_PATH}/parallel_5_tensor2Bin.log -j${THREADS} \
"${PYTHON} ${CLAIR3_TRIO} Tensor2Bin_Dual \
--tensor_fn ${TENSOR_CANDIDATE_FOLDER_PATH}/tensor_can_${TRIO_N}_{1} \
--bin_fn ${BINS_FOLDER_PATH}/${TRIO_N}_{1}_{2} \
--chunk_id {2} \
--chunk_num ${bin_chunk_num} \
--platform ${PLATFORM} \
" ::: ${CHR[@]} ::: ${BIN_CHUNK_LIST[@]} |& tee ${LOG_PATH}/5_T2B.log

call_chunk_num=6
CALL_CHUNK_LIST=`seq 1 ${call_chunk_num}`
PREDICT_THREADS=6
add_indel_length=1
MODEL_ALS="Clair3_Trio_Basic"
MODEL_ARC=N1
use_gpu=0
# export CUDA_VISIBLE_DEVICES="0"


CALL_PATH=${TMP_FILE_PATH}/predict_tensors
mkdir -p ${CALL_PATH}



echo "[INFO] * 6/7 Calling Trio Variants, Generate Probabilities"
time ${PARALLEL} --joblog ${LOG_PATH}/parallel_6_predict.log -j${PREDICT_THREADS} \
"${PYTHON} ${CLAIR3_TRIO} CallVariants_Dual \
--tensor_fn ${BINS_FOLDER_PATH}/${TRIO_N}_{1}_{2} \
--chkpnt_fn ${MODEL_PATH_C3T}/${TRIO_PREFIX} \
--predict_fn ${CALL_PATH}/predict_${TRIO_N}_{1}_{2}_{3} \
--sampleName ${TRIO_N} \
--chunk_id {3} \
--chunk_num ${call_chunk_num} \
--is_from_tables \
--use_gpu ${use_gpu} \
--add_indel_length ${add_indel_length} \
--model_arc ${MODEL_ARC} \
--model_cls ${MODEL_ALS} \
--platform ${PLATFORM} \
--output_probabilities" ::: ${CHR[@]} ::: ${BIN_CHUNK_LIST[@]} ::: ${CALL_CHUNK_LIST[@]} |& tee ${LOG_PATH}/6_PREDICT.log

ALL_SAMPLE_IDX=(
0
)

echo "[INFO] * 7/7 Calling Trio Variants, Genreate VCFs"
time ${PARALLEL}  --joblog ${LOG_PATH}/parallel_7_call.log  -j ${THREADS} \
"${PYTHON} ${CLAIR3_TRIO} CallVariants_Dual \
--tensor_fn ${CALL_PATH}/predict_${TRIO_N}_{1}_{4}_{5} \
--chkpnt_fn 0 \
--call_fn ${CALL_PATH}/{2}_{1}_{4}_{5}.vcf \
--sampleName {2} \
--ref_fn ${REFERENCE_FILE_PATH} \
--add_indel_length ${add_indel_length} \
--model_arc ${MODEL_ARC} \
--platform ${PLATFORM} \
--trio_n_id {3} \
--input_probabilities" ::: ${CHR[@]} ::: ${ALL_SAMPLE[@]} :::+ ${ALL_SAMPLE_IDX[@]} ::: ${BIN_CHUNK_LIST[@]} ::: ${CALL_CHUNK_LIST[@]} |& tee ${LOG_PATH}/7_CV.log

ALL_SAMPLE=(
${SAMPLE_C}
)

time ${PARALLEL}  --joblog ${LOG_PATH}/parallel_8_sort.log  -j ${THREADS} \
"${PYTHON} ${CLAIR3_TRIO} SortVcf \
--input_dir ${CALL_PATH} \
--vcf_fn_prefix {1} \
--output_fn ${OUTPUT_FOLDER}/{1}.vcf \
--sampleName {1} \
--ref_fn ${REFERENCE_FILE_PATH} \
--contigs_fn ${TMP_FILE_PATH}/CONTIGS" ::: ${ALL_SAMPLE[@]}  |& tee ${LOG_PATH}/8_SORT.log




echo $''
echo "[INFO] Finish calling, output folder: ${OUTPUT_FOLDER}"
