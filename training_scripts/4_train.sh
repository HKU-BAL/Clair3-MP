# Training Clair3-MP model
PYTHON3="[PYTHON3_PATH]"

#please follow the instruction here to specific the value for "PLATFORM"
#if you are training ONT-Illumina, please use 'ont';
#if you are training ONT-PacBio, please use 'ont';
#if you are training PacBio-Illumina, please use 'hifi'.
PLATFORM="[PLATFORM_NAME]"
# Clair3-MP's path
CLAIR3_MP_PATH="[CLAIR3-MP_PATH]"      
CLAIR3_MP="${CLAIR3_MP_PATH}/clair3.py"
OUTPUT_DIR="[OUTPUT_PATH]"
 
# bins folder for training
ALL_BINS_FOLDER_PATH="[BINS_FOLDER]"
TRAIN_FOLDER_PREFIX="${OUTPUT_DIR}/5_train/"
TRAIN_N="[MODEL_NAME]"
MODEL_FOLDER_PATH="${TRAIN_FOLDER_PREFIX}/train/${TRAIN_N}"                        
mkdir -p ${MODEL_FOLDER_PATH}
cd ${MODEL_FOLDER_PATH}

# training setting
BATCH_SIZE="800"  #training batch size, e.g. 800
add_indel_length=1
MODEL_ARC=N1
MODEL_ALS="Clair3_Trio_Basic"
IF_ADD_MCV_LOSS=0
MCVLOSS_ALPHA=0

# A single GPU is used for model training
export CUDA_VISIBLE_DEVICES="[SPECIFIC_THE_GPU]"

echo "[INFO] Model training"
time ${PYTHON3} ${CLAIR3_MP} Train_Dual \
--bin_fn ${ALL_BINS_FOLDER_PATH} \
--ochk_prefix ${MODEL_FOLDER_PATH} \
--add_indel_length ${add_indel_length} \
--platform ${PLATFORM} \
--validation_dataset \
--learning_rate 0.001 \
--maxEpoch 30 \
--model_arc ${MODEL_ARC} \
--model_cls ${MODEL_ALS} \
--batch_size ${BATCH_SIZE} \
--add_mcv_loss ${IF_ADD_MCV_LOSS} \
--mcv_alpha ${MCVLOSS_ALPHA} \
 |& tee ${MODEL_FOLDER_PATH}/train_log
