# Clair3-MP: variant calling using with sequencing data from multiple platforms

Contact: Ruibang Luo, Huijing Yu

Email: rbluo@cs.hku.hk, hjyu@cs.hku.hk

---
## Introduction
Thorough benchmarking studies for variant calling have revealed distinct advantages and weakness using sequencing data from different platforms. In addition, it has become more common to possess sequencing data from different platforms for a sample. Clair3-MP(Multi-Platform) is a deep-learning based variant calling method that supports multi-platform data including ONT-Illumina, ONT-PacBio and PacBio-Illumina to facilitate research involving different data in variant calling. 

Detailed descriptions of the software and results for Clair3-MP can be found here (a link to bioarchive).

----

## Contents

* [Introduction](#introduction)
* [Installation](#installation)
* [Analysis Results](http://www.bio8.cs.hku.hk/clair3_mp/results/)
---

## Installation
**Anaconda install**:

Please install anaconda using the official [guide](https://docs.anaconda.com/anaconda/install) or using the commands below:

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x ./Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh
```

**Install Clair3 env and Clair3-MP using anaconda step by step:**


```bash
# create and activate an environment named clair3
conda create -n clair3 python=3.6.10 -y
source activate clair3

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
#download the Clair3-MP models based on your sequencing data platforms 
#(e.g., data from ONT and Illumina, download ont_ilmn)
wget http://www.bio8.cs.hku.hk/clair3_mp/clair3_mp_models/ont_ilmn.tar.gz
tar -zxvf ont_ilmn.tar.gz -C ./models/clair3_mp_models_ont_ilmn
```
:exclamation::exclamation::exclamation: **Important Note** :exclamation::exclamation::exclamation:

When using ONT-Illumina, indicate PLATFORM_A as "ont" and PLATFORM_B as "ilmn";

When using ONT-PacBio, indicate PLATFORM_A as "ont" and PLATFORM_B as "hifi";

When using PacBio-Illumina, indicate PLATFORM_A as "hifi" and PLATFORM_B as "ilmn".
```bash
# run clair3-mp
_INPUT_DIR="[YOUR_INPUT_FOLDER]"                                                        # e.g. ./input
_BAM_PLATFORM_A=${_INPUT_DIR}/input_platform_A.bam   # replace your bam file generated from platform A
_BAM_PLATFORM_B=${_INPUT_DIR}/input_platform_B.bam   # replace your bam file generated from platform B
_PLATFORM_A="[Platform A name]"                 #indicate which platform is used for ${_BAM_PLATFORM_A}
_PLATFORM_B="[Platform B name]"                 #indicate which platform is used for ${_BAM_PLATFORM_B}
_SAMPLE_PLATFORM_A="[sample ID+Platform A name]"                                       # e.g. HG003_ont
_SAMPLE_PLATFORM_B="[sample ID+Platform B name]"                                      # e.g. HG003_ilmn
_REF=${_INPUT_DIR}/ref.fa                                       # replace your reference file name here
_OUTPUT_DIR="[YOUR_OUTPUT_FOLDER]"                                                      # e.g. ./output
_THREADS="[MAXIMUM_THREADS]"                                                                   # e.g. 8
_MODEL_DIR_C3_PLATFORM_A="[Clair3 MODEL NAME for platform A data]"    # e.g. ./models/clair3_models/ont
_MODEL_DIR_C3_PLATFORM_B="[Clair3 MODEL NAME for platform B data]"   # e.g. ./models/clair3_models/ilmn
_MODEL_DIR_C3MP="[Clair3-MP MODEL for platform A+B]"      #e.g. ./models/clair3_mp_models/c3mp_ont_ilmn

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
--model_path_clair3_trio=${_MODEL_DIR_C3MP} \
--sample_name_c=${_SAMPLE_PLATFORM_A} \
--sample_name_p1=${_SAMPLE_PLATFORM_B} \
--trio_model_prefix=variables 
```
