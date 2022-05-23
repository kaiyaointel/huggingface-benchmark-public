cd ${WORKSPACE}

# setup ubuntu env and conda env
apt-get -y update
apt-get install -y wget git htop aha html2text numactl bc ffmpeg libsm6 libxext6 automake libtool
apt install -y build-essential
apt install -y gfortran

wget https://repo.continuum.io/archive/Anaconda3-5.0.0-Linux-x86_64.sh -O anaconda3.sh
chmod +x anaconda3.sh
./anaconda3.sh -b -p /root/anaconda3

/root/anaconda3/bin/conda create -yn py39 python=3.9
export PATH=/root/anaconda3/bin:$PATH
source activate py39

pip install numpy pyyaml typing_extensions cmake datasets scipy sklearn seqeval nltk absl-py rouge_score sentencepiece psutil -i https://pypi.tuna.tsinghua.edu.cn/simple
hash -r && cmake --version
conda install -y mkl mkl-include
	
source deactivate && source activate py37
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"} 

# clone and install pytorch-spr
git clone ssh://git@gitlab.devtools.intel.com:29418/intel-pytorch-extension/pytorch-spr.git
cd pytorch-spr
git checkout dev
git submodule sync && git submodule update --init --recursive
python setup.py install
cd ..

# clone and install ipex cpu-device
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/anaconda3/envs/py37/lib/
git clone https://github.com/intel-innersource/frameworks.ai.pytorch.ipex-cpu.git
cd frameworks.ai.pytorch.ipex-cpu
git checkout cpu-device
git submodule sync && git submodule update --init --recursive
python setup.py install
cd ..
