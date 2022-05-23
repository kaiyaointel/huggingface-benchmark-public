### This is for automation of IPEX 1.10 broad test only
### This is for throughput mode only
set -x

rm -rf logs

export IPEX_INPUT="IPEX"
export PRECISION_INPUT="FP32"
export BATCH_SIZE_INPUT="80"
export JIT_MODE_INPUT="JIT"
export JIT_MODE_NAME_INPUT="null"
export NUMA_OPERATOR="numactl --cpunodebind=0 --membind=0"

export EXAMPLE_NAME="text-classification"
MODEL_NAME_ALL="bert-base-cased,distilbert-base-cased,roberta-base,xlm-roberta-base"
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

export EXAMPLE_NAME="question-answering"
MODEL_NAME_ALL="bert-base-cased,distilbert-base-cased,albert-base-v1,roberta-base,xlnet-base-cased,xlm-roberta-base,google/electra-base-generator,google/electra-base-discriminator"
MODEL_NAME_LIST=($(echo "${MODEL_NAME_ALL}" |sed 's/,/ /g'))
for model_name in ${MODEL_NAME_LIST[@]}
do
    export MODEL_NAME=$model_name
    export TASK_NAME=""
    ${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} ${IPEX_INPUT} ${PRECISION_INPUT} ${BATCH_SIZE_INPUT} ${JIT_MODE_INPUT} ${JIT_MODE_NAME_INPUT}
done
