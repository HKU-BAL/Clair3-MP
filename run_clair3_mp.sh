#!/bin/bash
SCRIPT_NAME=$(basename "$0")
SCRIPT_PATH=`dirname "$0"`
set -e
VERSION='v0.1'
print_help_messages()
{
   echo "help you later"
}

print_version()
{
    echo "Clair3-Hybrid $1"
    exit 0
}
ARGS=`getopt -o b:f:t:p:o:hv \
-l bam_fn_c:,bam_fn_p1:,bam_fn_c_platform:,bam_fn_p1_platform:,ref_fn:,threads:,model_path_clair3_c:,model_path_clair3_p1:,model_path_clair3_trio:,output:,\
bed_fn::,vcf_fn::,ctg_name::,sample_name_c::,sample_name_p1::,qual::,samtools::,python::,pypy::,parallel::,whatshap::,chunk_num::,chunk_size::,var_pct_full::,\
resumn::,snp_min_af::,indel_min_af::,pileup_model_prefix::,trio_model_prefix::,fast_mode,gvcf,pileup_only,pileup_phasing,print_ref_calls,haploid_precise,haploid_sensitive,include_all_ctgs,no_phasing_for_fa,call_snp_only,remove_intermediate_dir,enable_phasing,enable_long_indel,help,version -n 'run_clair3_hybrid.sh' -- "$@"`

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
PLATFORM=ont
CHUNK_NUM=0
CHUNK_SIZE=5000000
QUAL=2
PHASING_PCT_C="0.7"
PHASING_PCT_P1="0.7"
PRO=0.3
REF_PRO_C=0.3
REF_PRO_P1=0.3
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
RM_TMP_DIR=False
ENABLE_PHASING=False
ENABLE_LONG_INDEL=False
PILEUP_PREFIX="pileup"
TRIO_PREFIX="trio"

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
    --trio_model_prefix ) TRIO_PREFIX="$2"; shift 2 ;;
    -o|--output ) OUTPUT_FOLDER="$2"; shift 2 ;;
    --bed_fn ) BED_FILE_PATH="$2"; shift 2 ;;
    --vcf_fn ) VCF_FILE_PATH="$2"; shift 2 ;;
    --ctg_name ) CONTIGS="$2"; shift 2 ;;
    --sample_name_c ) SAMPLE_C="$2"; shift 2 ;;
    --sample_name_p1 ) SAMPLE_P1="$2"; shift 2 ;;
    --chunk_num ) CHUNK_NUM="$2"; shift 2 ;;
    --chunk_size ) CHUNK_SIZE="$2"; shift 2 ;;
    --samtools ) SAMTOOLS="$2"; shift 2 ;;
    --qual ) QUAL="$2"; shift 2 ;;
    --samtools ) SAMTOOLS="$2"; shift 2 ;;
    --python ) PYTHON="$2"; shift 2 ;;
    --pypy ) PYPY="$2"; shift 2 ;;
    --parallel ) PARALLEL="$2"; shift 2 ;;
    --whatshap ) WHATSHAP="$2"; shift 2 ;;
    --var_pct_full ) PRO="$2"; shift 2 ;;
#    --ref_pct_full_c ) REF_PRO_C="$2"; shift 2 ;;
#    --ref_pct_full_p1 ) REF_PRO_P1="$2"; shift 2 ;;
#    --var_pct_phasing ) PHASING_PCT="$2"; shift 2 ;;
    --snp_min_af ) SNP_AF="$2"; shift 2 ;;
    --indel_min_af ) INDEL_AF="$2"; shift 2 ;;
    --gvcf ) GVCF=True; shift 1 ;;
    --resumn ) RESUMN="$2"; shift 2 ;;
    --pileup_only ) PILEUP_ONLY=True; shift 1 ;;
    --pileup_phasing ) PILEUP_PHASING=True; shift 1 ;;
    --fast_mode ) FAST_MODE=True; shift 1 ;;
    --call_snp_only ) SNP_ONLY=True; shift 1 ;;
    --print_ref_calls ) SHOW_REF=True; shift 1 ;;
    --haploid_precise ) HAP_PRE=True; shift 1 ;;
    --haploid_sensitive ) HAP_SEN=True; shift 1 ;;
    --include_all_ctgs ) INCLUDE_ALL_CTGS=True; shift 1 ;;
    --no_phasing_for_fa ) NO_PHASING=True; shift 1 ;;
    --remove_intermediate_dir ) RM_TMP_DIR=True; shift 1 ;;
    --enable_long_indel ) ENABLE_LONG_INDEL=True; shift 1 ;;
    --enable_phasing ) ENABLE_PHASING=True; shift 1 ;;
    -- ) shift; break; ;;
    -h|--help ) print_help_messages; exit 0 ;;
    -v|--version ) print_version ${VERSION}; exit 0 ;;
    * ) print_help_messages; break ;;
   esac
done
mkdir -p ${OUTPUT_FOLDER}
if [ ! -d ${OUTPUT_FOLDER} ]; then echo -e "${ERROR} Cannot create output folder ${OUTPUT_FOLDER}${NC}"; exit 1; fi

if [ "${PLATFORM_C}" = "ont" ]; then 
	REF_PRO_C=0.1
else
	REF_PRO_C=0.3
fi

if [ "${PLATFORM_P1}" = "ont" ]; then
	REF_PRO_P1=0.1
else
	REF_PRO_P1=0.3
fi
#echo "${BAM_FILE_PATH_C}"
BASE_MODEL=$(basename ${MODEL_PATH_C3_C})
if [ "${BASE_MODEL}" = "r941_prom_sup_g5014" ] || [ "${BASE_MODEL}" = "r941_prom_hac_g5014" ] || [ "${BASE_MODEL}" = "ont_guppy5" ]; then PHASING_PCT_C=0.8; fi
BASE_MODEL=$(basename ${MODEL_PATH_C3_P1})
if [ "${BASE_MODEL}" = "r941_prom_sup_g5014" ] || [ "${BASE_MODEL}" = "r941_prom_hac_g5014" ] || [ "${BASE_MODEL}" = "ont_guppy5" ]; then PHASING_PCT_P1=0.8; fi


(time (
echo "[INFO] BAM 1 FILE PATH: ${BAM_FILE_PATH_C}"
echo "[INFO] BAM 2 FILE PATH: ${BAM_FILE_PATH_P1}"
echo "[INFO] BAM 1 PLATFORM: ${PLATFORM_C}"
echo "[INFO] BAM 2 PLATFORM: ${PLATFORM_P1}"
echo "[INFO] REFERENCE PATH: ${REFERENCE_FILE_PATH}"
echo "[INFO] THREADS: ${THREADS}"
echo "[INFO] CLAIR3 PILE UP MODEL PATH FOR BAM 1: ${MODEL_PATH_C3_C}"
echo "[INFO] CLAIR3 PILE UP MODEL PATH FOR BAM 2: ${MODEL_PATH_C3_P1}"
echo "[DEPRECATED]  CLAIR3 PILE UP PREFIX: ${PILEUP_PREFIX}"
echo "[INFO] CLAIR3-TRIO MODEL PATH: ${MODEL_PATH_C3T}"
echo "[INFO] CLAIR3-TRIO MODEL PREFIX: ${TRIO_PREFIX}"
echo "[INFO] OUTPUT FOLDER: ${OUTPUT_FOLDER}"
echo "[INFO] BED FILE PATH: ${BED_FILE_PATH}"
echo "[INFO] VCF FILE PATH: ${VCF_FILE_PATH}"
echo "[INFO] CONTIGS: ${CONTIGS}"
echo "[INFO] BAM 1 NAME:   ${SAMPLE_C}"
echo "[INFO] BAM 2 NAME: ${SAMPLE_P1}"
echo "[INFO] CHUNK SIZE: ${CHUNK_SIZE}"
if [ ${CHUNK_NUM} -gt 0 ]; then echo "[INFO] CHUNK NUM: ${CHUNK_NUM}"; fi
echo "[INFO] SAMTOOLS PATH: ${SAMTOOLS}"
echo "[INFO] PYTHON PATH: ${PYTHON}"
echo "[INFO] PYPY PATH: ${PYPY}"
echo "[INFO] PARALLEL PATH: ${PARALLEL}"
echo "[INFO] WHATSHAP PATH: ${WHATSHAP}"
echo "[INFO] QUALITY THRESHOLD: ${QUAL}"
echo "[INFO] FULL ALIGN PROPORTION: ${PRO}"
echo "[INFO] FULL ALIGN REFERENCE PROPORTION FOR BAM 1: ${REF_PRO_C}"
echo "[INFO] FULL ALIGN REFERENCE PROPORTION FOR BAM 2: ${REF_PRO_P1}"
echo "[INFO] PHASING PROPORTION FOR BAM 1: ${PHASING_PCT_C}"
echo "[INFO] PHASING PROPORTION FOR BAM 2: ${PHASING_PCT_P1}"
if [ ${SNP_AF} -gt 0 ]; then echo "[INFO] USER DEFINED SNP THRESHOLD: ${SNP_AF}"; fi
if [ ${INDEL_AF} -gt 0 ]; then echo "[INFO] USER DEFINED INDEL THRESHOLD: ${INDEL_AF}"; fi
echo "[INFO] ENABLE FILEUP ONLY CALLING: ${PILEUP_ONLY}"
echo "[INFO] ENABLE PILEUP CALLING AND PHASING: ${PILEUP_PHASING}"
echo "[INFO] ENABLE FAST MODE CALLING: ${FAST_MODE}"
echo "[INFO] ENABLE CALLING SNP CANDIDATES ONLY: ${SNP_ONLY}"
echo "[INFO] ENABLE PRINTING REFERENCE CALLS: ${SHOW_REF}"
echo "[INFO] ENABLE OUTPUT GVCF: ${GVCF}"
echo "[INFO] ENABLE HAPLOID PRECISE MODE: ${HAP_PRE}"
echo "[INFO] ENABLE HAPLOID SENSITIVE MODE: ${HAP_SEN}"
echo "[INFO] ENABLE INCLUDE ALL CTGS CALLING: ${INCLUDE_ALL_CTGS}"
echo "[INFO] ENABLE NO PHASING FOR FULL ALIGNMENT: ${NO_PHASING}"
echo "[INFO] ENABLE REMOVING INTERMEDIATE FILES: ${RM_TMP_DIR}"
echo "[INFO] ENABLE PHASING VCF OUTPUT: ${ENABLE_PHASING}"
echo "[INFO] ENABLE LONG INDEL CALLING: ${ENABLE_LONG_INDEL}"

${SCRIPT_PATH}/mp/Call_Clair3_MP.sh \
    --bam_fn_c ${BAM_FILE_PATH_C} \
    --bam_fn_p1 ${BAM_FILE_PATH_P1} \
    --bam_fn_c_platform ${PLATFORM_C} \
    --bam_fn_p1_platform ${PLATFORM_P1} \
    --ref_fn ${REFERENCE_FILE_PATH} \
    --threads ${THREADS} \
    --model_path_clair3_c ${MODEL_PATH_C3_C} \
    --model_path_clair3_p1 ${MODEL_PATH_C3_P1} \
    --model_path_clair3_trio ${MODEL_PATH_C3T} \
    --output ${OUTPUT_FOLDER} \
    --bed_fn=${BED_FILE_PATH} \
    --vcf_fn=${VCF_FILE_PATH} \
    --ctg_name=${CONTIGS} \
    --sample_name_c=${SAMPLE_C} \
    --sample_name_p1=${SAMPLE_P1} \
    --chunk_num=${CHUNK_NUM} \
    --chunk_size=${CHUNK_SIZE} \
    --samtools=${SAMTOOLS} \
    --python=${PYTHON} \
    --pypy=${PYPY} \
    --parallel=${PARALLEL} \
    --whatshap=${WHATSHAP} \
    --qual=${QUAL} \
    --var_pct_full=${PRO} \
    --ref_pct_full_c=${REF_PRO_C} \
    --ref_pct_full_p1=${REF_PRO_P1} \
    --var_pct_phasing_c=${PHASING_PCT_C} \
    --var_pct_phasing_p1=${PHASING_PCT_P1} \
    --snp_min_af=${SNP_AF} \
    --indel_min_af=${INDEL_AF} \
    --pileup_only=${PILEUP_ONLY} \
    --pileup_phasing=${PILEUP_PHASING} \
    --gvcf=${GVCF} \
    --fast_mode=${FAST_MODE} \
    --call_snp_only=${SNP_ONLY} \
    --print_ref_calls=${SHOW_REF} \
    --haploid_precise=${HAP_PRE} \
    --haploid_sensitive=${HAP_SEN} \
    --include_all_ctgs=${INCLUDE_ALL_CTGS} \
    --no_phasing_for_fa=${NO_PHASING} \
    --pileup_model_prefix=${PILEUP_PREFIX} \
    --trio_model_prefix=${TRIO_PREFIX} \
    --remove_intermediate_dir=${RM_TMP_DIR} \
    --enable_phasing=${ENABLE_PHASING} \
    --enable_long_indel=${ENABLE_LONG_INDEL}


)) |& tee ${OUTPUT_FOLDER}/run_clair3_mp.log
