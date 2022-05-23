### This is for automation of IPEX 1.10 broad test only
### This is for throughput mode only
set -x

rm -rf logs

# export IPEX_INPUT="IPEX_TD" # if using TorchDynamo with IPEX backend
export IPEX_INPUT="IPEX"
export PRECISION_INPUT="FP32"
export BATCH_SIZE_INPUT="80"
export JIT_MODE_INPUT="NOJIT"
export JIT_MODE_NAME_INPUT="NOJIT"
export NUMA_OPERATOR="numactl --cpunodebind=0 --membind=0"

export EXAMPLE_NAME="text-classification"
MODEL_NAME_ALL="gpt2,bert-base-cased,distilbert-base-cased,albert-base-v1,roberta-base,xlnet-base-cased,xlm-roberta-base,google/electra-base-generator,google/electra-base-discriminator"
MODEL_NAME_LIST=($(echo "${MODEL_NAME_ALL}" |sed 's/,/ /g'))
TASK_NAME_ALL="cola,mrpc,qnli,rte,sst2,stsb"
TASK_NAME_LIST=($(echo "${TASK_NAME_ALL}" |sed 's/,/ /g'))
for model_name in ${MODEL_NAME_LIST[@]}
do
    for task_name in ${TASK_NAME_LIST[@]}
    do
        export MODEL_NAME=$model_name
        export TASK_NAME=$task_name
        ${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} ${IPEX_INPUT} ${PRECISION_INPUT} ${BATCH_SIZE_INPUT} ${JIT_MODE_INPUT} ${JIT_MODE_NAME_INPUT}
    done
done

export EXAMPLE_NAME="token-classification"
MODEL_NAME_ALL="gpt2,bert-base-cased,distilbert-base-cased,albert-base-v1,roberta-base,xlnet-base-cased,xlm-roberta-base,google/electra-base-generator,google/electra-base-discriminator"
MODEL_NAME_LIST=($(echo "${MODEL_NAME_ALL}" |sed 's/,/ /g'))
for model_name in ${MODEL_NAME_LIST[@]}
do
    export MODEL_NAME=$model_name
    export TASK_NAME=""
    ${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} ${IPEX_INPUT} ${PRECISION_INPUT} ${BATCH_SIZE_INPUT} ${JIT_MODE_INPUT} ${JIT_MODE_NAME_INPUT}
done

export EXAMPLE_NAME="multiple-choice"
MODEL_NAME_ALL="bert-base-cased,distilbert-base-cased,albert-base-v1,roberta-base,xlnet-base-cased,xlm-roberta-base,google/electra-base-generator,google/electra-base-discriminator"
MODEL_NAME_LIST=($(echo "${MODEL_NAME_ALL}" |sed 's/,/ /g'))
for model_name in ${MODEL_NAME_LIST[@]}
do
    export MODEL_NAME=$model_name
    export TASK_NAME=""
    ${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} ${IPEX_INPUT} ${PRECISION_INPUT} ${BATCH_SIZE_INPUT} ${JIT_MODE_INPUT} ${JIT_MODE_NAME_INPUT}
done

export EXAMPLE_NAME="question-answering"
MODEL_NAME_ALL="bert-base-cased,distilbert-base-cased,albert-base-v1,roberta-base,xlnet-base-cased,xlm-roberta-base,google/electra-base-generator,google/electra-base-discriminator"
MODEL_NAME_LIST=($(echo "${MODEL_NAME_ALL}" |sed 's/,/ /g'))
for model_name in ${MODEL_NAME_LIST[@]}
do
    export MODEL_NAME=$model_name
    export TASK_NAME=""
    ${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} ${IPEX_INPUT} ${PRECISION_INPUT} ${BATCH_SIZE_INPUT} ${JIT_MODE_INPUT} ${JIT_MODE_NAME_INPUT}
done

export EXAMPLE_NAME="masked-language-modeling"
MODEL_NAME_ALL="bert-base-cased,distilbert-base-cased,albert-base-v1,roberta-base,xlm-roberta-base,google/electra-base-generator,google/electra-base-discriminator"
MODEL_NAME_LIST=($(echo "${MODEL_NAME_ALL}" |sed 's/,/ /g'))
for model_name in ${MODEL_NAME_LIST[@]}
do
    export MODEL_NAME=$model_name
    export TASK_NAME=""
    ${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} ${IPEX_INPUT} ${PRECISION_INPUT} ${BATCH_SIZE_INPUT} ${JIT_MODE_INPUT} ${JIT_MODE_NAME_INPUT}
done

export EXAMPLE_NAME="casual-language-modeling"
MODEL_NAME_ALL="gpt2,bert-base-cased,roberta-base,xlnet-base-cased,xlm-roberta-base"
MODEL_NAME_LIST=($(echo "${MODEL_NAME_ALL}" |sed 's/,/ /g'))
for model_name in ${MODEL_NAME_LIST[@]}
do
    export MODEL_NAME=$model_name
    export TASK_NAME=""
    ${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} ${IPEX_INPUT} ${PRECISION_INPUT} ${BATCH_SIZE_INPUT} ${JIT_MODE_INPUT} ${JIT_MODE_NAME_INPUT}
done

export EXAMPLE_NAME="summarization"
MODEL_NAME_ALL="t5-small,t5-base"
MODEL_NAME_LIST=($(echo "${MODEL_NAME_ALL}" |sed 's/,/ /g'))
for model_name in ${MODEL_NAME_LIST[@]}
do
    export MODEL_NAME=$model_name
    export TASK_NAME=""
    ${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} ${IPEX_INPUT} ${PRECISION_INPUT} ${BATCH_SIZE_INPUT} ${JIT_MODE_INPUT} ${JIT_MODE_NAME_INPUT}
done

# new models (Pls do not run them because they have not been validated.)
export EXAMPLE_NAME="text-classification"
MODEL_NAME_ALL="\
    allenai/longformer-base-4096, \
    google/mobilebert-uncased, \
    cross-encoder/ms-marco-MiniLM-L-12-v2, \
    bert-base-chinese, \
    distilbert-base-uncased-finetuned-sst-2-english, \
    ProsusAI/finbert, \
    finiteautomata/beto-sentiment-analysis, \
    mrm8488/bert-tiny-finetuned-sms-spam-detection, \
    microsoft/MiniLM-L12-H384-uncased, \
    explosion/en_textcat_goemotions, \
    arpanghoshal/EmoRoBERTa, \
    cardiffnlp/twitter-roberta-base-sentiment"
MODEL_NAME_LIST=($(echo "${MODEL_NAME_ALL}" |sed 's/,/ /g'))
TASK_NAME_ALL="cola,mrpc,qnli,rte,sst2,stsb"
TASK_NAME_LIST=($(echo "${TASK_NAME_ALL}" |sed 's/,/ /g'))
for model_name in ${MODEL_NAME_LIST[@]}
do
    for task_name in ${TASK_NAME_LIST[@]}
    do
        export MODEL_NAME=$model_name
        export TASK_NAME=$task_name
        ${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} ${IPEX_INPUT} ${PRECISION_INPUT} ${BATCH_SIZE_INPUT} ${JIT_MODE_INPUT} ${JIT_MODE_NAME_INPUT}
    done
done
