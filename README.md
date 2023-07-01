# Clair3-MP: variant calling using with sequencing data from multiple platforms

Contact: Ruibang Luo, Huijing Yu

Email: rbluo@cs.hku.hk, hjyu@cs.hku.hk

---
## Introduction

Clair3-MP (Multi-Platform) is a deep-learning based variant calling method that supports multi-platform data including ONT-Illumina, ONT-PacBio and PacBio-Illumina to facilitate research involving different data in variant calling. Clair3-MP features a neural network that supports multi-platform data and trains a series of new models, tailored to perform variant calling using different multi-platform data. In addition, Clair3-MP can incorporate reference genome stratification information by including a stratification channel in its input tensors. This channel encodes the platform preference into the neural network and enables better variant-calling performance for multi-platform data.

Detailed descriptions of the software and results for Clair3-MP can be found [here](https://www.biorxiv.org/content/10.1101/2023.05.31.543184v1).

----

## Contents

* [Introduction](#introduction)
* [Installation](#installation)
* [Analysis Results](http://www.bio8.cs.hku.hk/clair3_mp/results/)
---

## Installation



### Option 1. Docker pre-built image

A pre-built docker image is available [here](https://hub.docker.com/r/hkubal/clair3-mp). With it you can run Clair3-MP using a single command.

Caution: Absolute path is needed for both `_BAM_PLATFORM_A/B`, `_REF` and `_OUTPUT_DIR`.

```bash

_BAM_PLATFORM_A=$[ONT_BAM] #input bam
_BAM_PLATFORM_B=$[ILMN_BAM]
_REF="[REF file]"
_OUTPUT_DIR="[OUTPUT DIR]"

_PLATFORM_A="ont"
_PLATFORM_B="ilmn"
_SAMPLE_PLATFORM_A="XXX_ont" #sample name
_SAMPLE_PLATFORM_B="XXX_ilmn"
mkdir -p ${_OUTPUT_DIR}
_THREADS=36

# docker path
_MODEL_DIR_C3_PLATFORM_A="ont_guppy5"   
_MODEL_DIR_C3_PLATFORM_B="ilmn"    
_MODEL_DIR_MP="ont_ilmn"   


DIR_A="$(dirname "${_BAM_PLATFORM_A}")"
DIR_B="$(dirname "${_BAM_PLATFORM_B}")"
DIR_REF="$(dirname "${_REF}")"

docker run -it \
-v ${DIR_A}:${DIR_A} \
-v ${DIR_B}:${DIR_B} \
-v ${DIR_REF}:${DIR_REF} \
-v ${_OUTPUT_DIR}:${_OUTPUT_DIR} \
hkubal/clair3-mp:latest \
/opt/bin/run_clair3_mp.sh \
--bam_fn_c=${_BAM_PLATFORM_A} \
--bam_fn_p1=${_BAM_PLATFORM_B} \
--bam_fn_c_platform=${_PLATFORM_A} \
--bam_fn_p1_platform=${_PLATFORM_B} \
--output=${_OUTPUT_DIR} \
--ref_fn=${_REF} \
--threads=${_THREADS} \
--model_path_clair3_c=/opt/models/clair3_models/${_MODEL_DIR_C3_PLATFORM_A} \
--model_path_clair3_p1=/opt/models/clair3_models/${_MODEL_DIR_C3_PLATFORM_B} \
--model_path_clair3_mp=/opt/models/clair3_mp_models/${_MODEL_DIR_MP} \
--sample_name_c=${_SAMPLE_PLATFORM_A} \
--sample_name_p1=${_SAMPLE_PLATFORM_B} \
--ctg_name=chr20 

```





### Option 2. Anaconda install:

Please install anaconda using the official [guide](https://docs.anaconda.com/anaconda/install) or using the commands below:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x ./Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
```

**Install Clair3-MP env using anaconda step by step:**


```bash
# create and activate an environment named clair3
conda create -n clair3-mp python=3.6.10 -y
source activate clair3-mp

# install pypy and packages in the environemnt
conda install -c conda-forge pypy3.6 -y
pypy3 -m ensurepip
pypy3 -m pip install mpmath==1.2.1

# install python packages in environment
pip3 install tensorflow==2.2.0
pip3 install tensorflow-addons==0.11.2 tables==3.6.1
conda install -c anaconda pigz==2.4 -y
conda install -c conda-forge parallel=20191122 zstd=1.4.4 -y
conda install -c conda-forge -c bioconda samtools=1.10 -y
conda install -c conda-forge -c bioconda whatshap=1.0 -y

# clone Clair3-MP
git clone https://github.com/HKU-BAL/Clair3-MP.git
cd Clair3-MP

# download Clair3's pre-trained models
mkdir -p models/clair3_models
wget http://www.bio8.cs.hku.hk/clair3/clair3_models/clair3_models.tar.gz
tar -zxvf clair3_models.tar.gz -C ./models/clair3_models


# download Clair3-MP's pre-trained models
mkdir -p models/clair3_mp_models
# download the Clair3-MP models based on your sequencing data platforms 
# please use the correct clair3-mp models for specific platforms: ont_ilmn, ont_pb, pb_ilmn
wget http://www.bio8.cs.hku.hk/clair3_mp/clair3_mp_models/clair3_mp_models.tar.gz
tar -zxvf clair3_mp_models.tar.gz -C ./models/clair3_mp_models
```



### Option 3, install via Docker Dockerfile

```
# clone Clair3-MP
git clone https://github.com/hku-bal/Clair3-MP.git
cd Clair3-MP

# build a docker image named hkubal/clair3-mp:latest
# might require docker authentication to build docker image 
docker build -f ./Dockerfile -t hkubal/clair3-mp:latest .

# run clair3-mp docker image like 
docker run -it hkubal/clair3-mp:latest /opt/bin/run_clair3_mp.sh --help
```

## Usage
:exclamation::exclamation::exclamation: **Important Note** :exclamation::exclamation::exclamation:

For using ONT data, we currently only trained a model on ONT guppy5 data, i.e "clair3_models/ont_guppy5".
For using PacBio data, we currently only trained a model on PacBio hifi data, i.e "clair3_models/ont_hifi".

Argument setting for multiple platform data input:

|INPUT data Setting|bam_fn_c_platform|bam_fn_p1_platform|model_path_clair3_c             |model_path_clair3_p1      |model_path_clair3_mp             |
|------------------|-----------------|------------------|--------------------------------|--------------------------|---------------------------------|
|ONT + ILLUMINA    | ont             | ilmn             | models/clair3_models/ont_guppy5| models/clair3_models/ilmn| models/clair3_mp_models/ont_ilmn|
|ONT + PabBio      | ont             | hifi             | models/clair3_models/ont_guppy5| models/clair3_models/hifi| models/clair3_mp_models/ont_pb|
|PacBio + ILLUMINA | hifi            | ilmn             | models/clair3_models/hifi      | models/clair3_models/ilmn| models/clair3_mp_models/pb_ilmn |

```bash
# run clair3-mp
_BAM_PLATFORM_A="input_platform_A.bam"          # replace your bam file generated from platform A
_BAM_PLATFORM_B="input_platform_B.bam"          # replace your bam file generated from platform B
_PLATFORM_A="[Platform A name]"                 #indicate which platform is used for ${_BAM_PLATFORM_A}
_PLATFORM_B="[Platform B name]"                 #indicate which platform is used for ${_BAM_PLATFORM_B}
_SAMPLE_PLATFORM_A="[sample ID+Platform A name]"                                       # e.g. HG003_ont
_SAMPLE_PLATFORM_B="[sample ID+Platform B name]"                                      # e.g. HG003_ilmn
_REF="ref.fa"                                   # replace your reference file name here
_OUTPUT_DIR="[YOUR_OUTPUT_FOLDER]"                                                      # e.g. ./output
_THREADS="[MAXIMUM_THREADS]"                                                                   # e.g. 8
_MODEL_DIR_C3_PLATFORM_A="[Clair3 MODEL NAME for platform A data]"    # MODEL PATH for Clair3 pileup model for flatform A, e.g. ./models/clair3_models/ont_guppy5
_MODEL_DIR_C3_PLATFORM_B="[Clair3 MODEL NAME for platform B data]"    # MODEL PATH for Clair3 pileup model for flatform B, e.g. ./models/clair3_models/ilmn
_MODEL_DIR_MP="[Clair3-MP MODEL for platform A+B]"                    # MODEL PATH for Clair3-MP model, e.g. ./models/clair3_mp_models/${_PLATFORM_A}_${_PLATFORM_B}

./run_clair3_mp.sh \
--bam_fn_c=${_BAM_PLATFORM_A} \
--bam_fn_p1=${_BAM_PLATFORM_B} \
--bam_fn_c_platform=${_PLATFORM_A} \
--bam_fn_p1_platform=${_PLATFORM_B} \
--output=${_OUTPUT_DIR} \
--ref_fn=${_REF} \
--threads=${_THREADS} \
--model_path_clair3_c=${_MODEL_DIR_C3_PLATFORM_A} \
--model_path_clair3_p1=${_MODEL_DIR_C3_PLATFORM_B} \
--model_path_clair3_mp=${_MODEL_DIR_MP} \
--sample_name_c=${_SAMPLE_PLATFORM_A} \
--sample_name_p1=${_SAMPLE_PLATFORM_B}
```
