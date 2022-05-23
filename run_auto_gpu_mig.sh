set -x
workspace=${PWD}
rm -rf ${workspace}/logs
mkdir ${workspace}/logs

function main {
    set -x
    model_name="text-classification+google-electra-base-generator, \
                token-classification+gpt2, \
                token-classification+google-electra-base-generator, \
                multiple-choice+distilbert-base-cased, \
                multiple-choice+google-electra-base-discriminator, \
                masked-language-modeling+bert-base-cased, \
                masked-language-modeling+distilbert-base-cased, \
                casual-language-modeling+xlm-roberta-base, \
                question-answering+facebook-bart-large, \
                summarization+t5-base"
    model_name_list=($(echo "${model_name}" |sed 's/,/ /g'))

    for model_name in ${model_name_list[@]}
    do
        if [ ${model_name} == "text-classification+google-electra-base-generator" ];then
            export EXAMPLE_NAME="text-classification"
            export MODEL_NAME="google/electra-base-generator"
            export TASK_NAME="cola"
        elif [ ${model_name} == "token-classification+gpt2" ];then
            export EXAMPLE_NAME="token-classification"
            export MODEL_NAME="gpt2"
            export TASK_NAME="null"
        elif [ ${model_name} == "token-classification+google-electra-base-generator" ];then
            export EXAMPLE_NAME="token-classification"
            export MODEL_NAME="google/electra-base-generator"
            export TASK_NAME="null"
        elif [ ${model_name} == "multiple-choice+distilbert-base-cased" ];then
            export EXAMPLE_NAME="multiple-choice"
            export MODEL_NAME="distilbert-base-cased"
            export TASK_NAME="null"
        elif [ ${model_name} == "multiple-choice+google-electra-base-discriminator" ];then
            export EXAMPLE_NAME="multiple-choice"
            export MODEL_NAME="google/electra-base-discriminator"
            export TASK_NAME="null"
        elif [ ${model_name} == "question-answering+facebook-bart-large" ];then
            export EXAMPLE_NAME="question-answering"
            export MODEL_NAME="facebook/bart-large"
            export TASK_NAME="null"
        elif [ ${model_name} == "masked-language-modeling+bert-base-cased" ];then
            export EXAMPLE_NAME="masked-language-modeling"
            export MODEL_NAME="bert-base-cased"
            export TASK_NAME="null"
        elif [ ${model_name} == "masked-language-modeling+distilbert-base-cased" ];then
            export EXAMPLE_NAME="masked-language-modeling"
            export MODEL_NAME="distilbert-base-cased"
            export TASK_NAME="null"
        elif [ ${model_name} == "casual-language-modeling+xlm-roberta-base" ];then
            export EXAMPLE_NAME="casual-language-modeling"
            export MODEL_NAME="xlm-roberta-base"
            export TASK_NAME="null"
        elif [ ${model_name} == "summarization+t5-base" ];then
            export EXAMPLE_NAME="summarization"
            export MODEL_NAME="t5-base"
            export TASK_NAME="null"
        fi
        # generate benchmark
        launch_migs ${EXAMPLE_NAME} ${MODEL_NAME} ${TASK_NAME} > ${workspace}/logs/temp.log
        wait
        collect_perf
    done
}

function launch_migs {
    # MIG_list=$(nvidia-smi -L | grep 'UUID' | rev | cut -d' ' -f1 | rev | cut -d')' -f1 | tail -${INSTANCES})
    set -x
    CUDA_VISIBLE_DEVICES=MIG-fb4db3f1-449b-5f62-b2b6-885ccf1f0f6e EXAMPLE_NAME=$1 MODEL_NAME=$2 TASK_NAME=$3 bash run_workload.sh $1 NOIPEX FP16 1 & \
    CUDA_VISIBLE_DEVICES=MIG-282b0b25-f327-5934-afd9-1a467f91a307 EXAMPLE_NAME=$1 MODEL_NAME=$2 TASK_NAME=$3 bash run_workload.sh $1 NOIPEX FP16 1 & \
    CUDA_VISIBLE_DEVICES=MIG-38f9149c-9cce-53c5-bd3a-13401f15336b EXAMPLE_NAME=$1 MODEL_NAME=$2 TASK_NAME=$3 bash run_workload.sh $1 NOIPEX FP16 1 & \
    CUDA_VISIBLE_DEVICES=MIG-7839f662-c5dc-5204-a669-51c155c3de94 EXAMPLE_NAME=$1 MODEL_NAME=$2 TASK_NAME=$3 bash run_workload.sh $1 NOIPEX FP16 1 & \
    CUDA_VISIBLE_DEVICES=MIG-dcc281e6-86b8-57f6-880e-feb15d21e2cd EXAMPLE_NAME=$1 MODEL_NAME=$2 TASK_NAME=$3 bash run_workload.sh $1 NOIPEX FP16 1 & \
    CUDA_VISIBLE_DEVICES=MIG-f5a339d5-585d-59fd-898d-0dd0ab11d5c2 EXAMPLE_NAME=$1 MODEL_NAME=$2 TASK_NAME=$3 bash run_workload.sh $1 NOIPEX FP16 1 & \
    CUDA_VISIBLE_DEVICES=MIG-0e98ffb7-9d48-5bc7-9cb5-873e4c20aa22 EXAMPLE_NAME=$1 MODEL_NAME=$2 TASK_NAME=$3 bash run_workload.sh $1 NOIPEX FP16 1
}

function collect_perf {
    set -x
    throughput=$(grep 'inference Throughput:' ${workspace}/logs/temp.log |sed -e 's/.*Throughput//;s/,.*//;s/[^0-9.]//g' |awk '
        BEGIN {
            sum = 0;
        }
        {
            sum = sum + $1;
        }
        END {
            printf("%.3f", sum);
        }
    ')
    echo $EXAMPLE_NAME $MODEL_NAME $throughput >> ${workspace}/logs/summary_MIG.log
}

Start
main "$@"
