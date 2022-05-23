set -x

# install required pip packages
pip install datasets seqeval nltk rouge_score

# (CPU) install libiomp5.so and libjemalloc.so into conda env
conda install -y mkl mkl-include
conda install -y jemalloc

# install transformers (submodule)
git submodule sync && git submodule update --init --recursive
cd transformers
git apply ../transformers.patch
python setup.py install
cd ..

# manually download gpt-2 models for text- and token-classification
mkdir gpt2-model-for-classification_1
python gpt2_for_classification_1.py
mkdir gpt2-model-for-classification_2
python gpt2_for_classification_2.py
mkdir gpt2-model-for-classification_3
python gpt2_for_classification_3.py
