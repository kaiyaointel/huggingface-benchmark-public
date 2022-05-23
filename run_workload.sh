#!/bin/bash
set -x

WS_DIR=${PWD}
mkdir logs

# export DNNL_MAX_CPU_ISA=AVX512_CORE_AMX
export LD_PRELOAD=${CONDA_PREFIX}/lib/libjemalloc.so
export LD_PRELOAD=${LD_PRELOAD}:${CONDA_PREFIX}/lib/libiomp5.so
export MALLOC_CONF="oversize_threshold:1,background_thread:true,metadata_thp:auto,dirty_decay_ms:9000000000,muzzy_decay_ms:9000000000"
export KMP_AFFINITY="granularity=fine,compact,1,0"
export KMP_BLOCKTIME=1
export DNNL_PRIMITIVE_CACHE_CAPACITY=1024
export KMP_SETTINGS=1

# print env info
echo "cpu info: " | tee -a ${WS_DIR}/logs/env-info.log
lscpu | tee -a ${WS_DIR}/logs/env-info.log
echo "python info: " | tee -a ${WS_DIR}/logs/env-info.log
echo "`python --version`" | tee -a ${WS_DIR}/logs/env-info.log
echo "`gcc --version`" | tee -a ${WS_DIR}/logs/env-info.log
echo "`cmake --version`" | tee -a ${WS_DIR}/logs/env-info.log
echo "`pip list freeze`" | tee -a ${WS_DIR}/logs/env-info.log
echo "`export`" | tee -a ${WS_DIR}/logs/env-info.log

# benchmark
EXAMPLE_NAME=${1}
echo Now running example: ${EXAMPLE_NAME}

if [ "${EXAMPLE_NAME}" == "text-classification" ];then
    CODE_NAME=run_glue.py
elif [ "${EXAMPLE_NAME}" == "token-classification" ];then
    CODE_NAME=run_ner.py
elif [ "${EXAMPLE_NAME}" == "multiple-choice" ];then
    CODE_NAME=run_swag.py
elif [ "${EXAMPLE_NAME}" == "question-answering" ];then
    CODE_NAME=run_qa.py
elif [ "${EXAMPLE_NAME}" == "masked-language-modeling" ];then
    CODE_NAME=run_mlm.py
elif [ "${EXAMPLE_NAME}" == "casual-language-modeling" ];then
    CODE_NAME=run_clm.py
elif [ "${EXAMPLE_NAME}" == "summarization" ];then
    CODE_NAME=run_summarization.py
fi

### Switches
CHANNELS_LAST=1
PROFILE=0

AUTO_BATCH_SIZE=0
# BS switch
BATCH_SIZE_INF=${4}

DONT_TRAIN=1
TRAIN_BS=0
TRAIN_EPS=0

# IPEX switch
IPEX_MODE=0
if [ ${2} == "IPEX" ];then
    IPEX_MODE=1
fi
if [ ${2} == "IPEX_TD" ];then
    IPEX_MODE=2
fi
# JIT switch - JIT or JIT_OPT
JIT_MODE=0
PATH_LOG="imperative"
if [ ${5} == "JIT" ];then
    JIT_MODE=1
    PATH_LOG="jit"
fi
if [ ${5} == "JIT_OPT" ];then
    JIT_MODE=2
    PATH_LOG="jit_optimize"
fi
JIT_MODEL_NAME=${6}
# Precision switch
BF16_MODE=0
if [ ${3} == "BF16" ];then
    BF16_MODE=1
fi
FP16_MODE=0
if [ ${3} == "FP16" ];then
    FP16_MODE=1
fi
INT8_MODE=0
if [ ${3} == "INT8" ];then
    INT8_MODE=1
fi

ADDITIONAL_ARGS=""
PRECISION="FP32" #by default FP32, this is for summary.log

if [ "${AUTO_BATCH_SIZE}" == "0" ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --per_device_eval_batch_size ${BATCH_SIZE_INF}"
fi
if [ "${DONT_TRAIN}" == "0" ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --do_train --num_train_epochs ${TRAIN_EPS} --per_device_train_batch_size ${TRAIN_BS} "
fi
if [ "${IPEX_MODE}" == "1" ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --ipex True "
fi
if [ "${IPEX_MODE}" == "2" ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --torchdynamo_ipex True "
fi
if [ "${JIT_MODE}" == "1" ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --jit True --jit_model_name ${JIT_MODEL_NAME}"
fi
if [ "${JIT_MODE}" == "2" ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --jit True --jit_optimize True --jit_model_name ${JIT_MODEL_NAME}"
fi
if [ "${BF16_MODE}" == "1" ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --precision bfloat16"
    PRECISION="BF16"
fi
if [ "${FP16_MODE}" == "1" ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --precision bfloat16 --fp16"
    PRECISION="FP16"
fi
if [ "${INT8_MODE}" == "1" ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --precision int8 --int8_calibration"
    PRECISION="INT8"
fi
EARLY_STOP_AT_ITER=${EARLY_STOP_AT_ITER:-50}
if [ ${EARLY_STOP_AT_ITER} -gt 0 ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --early_stop_at_iter ${EARLY_STOP_AT_ITER}"
fi
MINIMUM_ITER=50
if [ ${MINIMUM_ITER} -gt 0 ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --minimum_iter ${MINIMUM_ITER}"
fi
WARMUP_ITER=10
if [ ${WARMUP_ITER} -gt 0 ];then
    ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --num_warmup_iter ${WARMUP_ITER}"
fi

# scripts
MODEL_NAME_LOG=${MODEL_NAME}
# handles model names like xxx/yyy to make it xxx-yyy for log filename sake
if [[ ${MODEL_NAME} =~ "/" ]]; then
    MODEL_NAME_LOG=${MODEL_NAME//'/'/'-'}
fi

# scripts by example
if [ "${EXAMPLE_NAME}" == "text-classification" ];then
    if [ "${MODEL_NAME}" == "gpt2" ];then #gpt-2 cannot use run_glue.py out-of-box, need to download specific model
        if [ "${TASK_NAME}" == "mnli" ];then
            MODEL_NAME="./gpt2-model-for-classification_3/"
        elif [ "${TASK_NAME}" == "stsb" ];then
            MODEL_NAME="./gpt2-model-for-classification_1/"
        else
            MODEL_NAME="./gpt2-model-for-classification_2/"
        fi
        MODEL_NAME_LOG=gpt2
    fi
    python ./transformers/examples/pytorch/${EXAMPLE_NAME}/${CODE_NAME} \
      --model_name_or_path ${MODEL_NAME} \
      --task_name ${TASK_NAME} \
      --do_eval \
      --max_seq_length 16 \
      --learning_rate 2e-5 \
      --overwrite_output_dir \
      --output_dir /tmp/${TASK_NAME}/ \
      --channels_last ${CHANNELS_LAST} \
      --profile ${PROFILE} \
      ${ADDITIONAL_ARGS} \
      2>&1 | tee -a ${WS_DIR}/logs/hf---${EXAMPLE_NAME}---${MODEL_NAME_LOG}---${TASK_NAME}.log
elif [ "${EXAMPLE_NAME}" == "token-classification" ];then
    if [ "${MODEL_NAME}" == "gpt2" ];then #gpt-2 cannot use run_ner.py out-of-box, need to download specific model
        MODEL_NAME="./gpt2-model-for-classification_2/"
        MODEL_NAME_LOG=gpt2
    fi
    python ./transformers/examples/pytorch/${EXAMPLE_NAME}/${CODE_NAME} \
      --model_name_or_path ${MODEL_NAME} \
      --dataset_name conll2003 \
      --do_eval \
      --overwrite_output_dir \
      --output_dir /tmp/${TASK_NAME}/ \
      --channels_last ${CHANNELS_LAST} \
      --profile ${PROFILE} \
      ${ADDITIONAL_ARGS} \
      2>&1 | tee -a ${WS_DIR}/logs/hf---${EXAMPLE_NAME}---${MODEL_NAME_LOG}---${TASK_NAME}.log
elif [ "${EXAMPLE_NAME}" == "multiple-choice" ];then
    python ./transformers/examples/pytorch/${EXAMPLE_NAME}/${CODE_NAME} \
      --model_name_or_path ${MODEL_NAME} \
      --do_eval \
      --learning_rate 5e-5 \
      --overwrite_output_dir \
      --output_dir /tmp/${TASK_NAME}/ \
      --channels_last ${CHANNELS_LAST} \
      --profile ${PROFILE} \
      ${ADDITIONAL_ARGS} \
      2>&1 | tee -a ${WS_DIR}/logs/hf---${EXAMPLE_NAME}---${MODEL_NAME_LOG}---${TASK_NAME}.log
elif [ "${EXAMPLE_NAME}" == "question-answering" ];then
    if [ "${LEGACY_PREDICTION}" == "1" ];then
        ADDITIONAL_ARGS="${ADDITIONAL_ARGS} --use_legacy_prediction_loop"
    fi
    python ./transformers/examples/pytorch/${EXAMPLE_NAME}/${CODE_NAME} \
      --model_name_or_path ${MODEL_NAME} \
      --dataset_name squad \
      --do_eval \
      --max_seq_length 384 \
      --learning_rate 3e-5 \
      --doc_stride 128 \
      --overwrite_output_dir \
      --output_dir /tmp/${TASK_NAME}/ \
      --channels_last ${CHANNELS_LAST} \
      --profile ${PROFILE} \
      ${ADDITIONAL_ARGS} \
      2>&1 | tee -a ${WS_DIR}/logs/hf---${EXAMPLE_NAME}---${MODEL_NAME_LOG}---${TASK_NAME}.log
elif [ "${EXAMPLE_NAME}" == "masked-language-modeling" ];then
    python ./transformers/examples/pytorch/language-modeling/${CODE_NAME} \
      --model_name_or_path ${MODEL_NAME} \
      --dataset_name wikitext \
      --dataset_config_name wikitext-2-raw-v1 \
      --do_eval \
      --overwrite_output_dir \
      --output_dir /tmp/${TASK_NAME}/ \
      --channels_last ${CHANNELS_LAST} \
      --profile ${PROFILE} \
      ${ADDITIONAL_ARGS} \
      2>&1 | tee -a ${WS_DIR}/logs/hf---${EXAMPLE_NAME}---${MODEL_NAME_LOG}---${TASK_NAME}.log
elif [ "${EXAMPLE_NAME}" == "casual-language-modeling" ];then
    python ./transformers/examples/pytorch/language-modeling/${CODE_NAME} \
      --model_name_or_path ${MODEL_NAME} \
      --dataset_name wikitext \
      --dataset_config_name wikitext-2-raw-v1 \
      --do_eval \
      --overwrite_output_dir \
      --output_dir /tmp/${TASK_NAME}/ \
      --channels_last ${CHANNELS_LAST} \
      --profile ${PROFILE} \
      ${ADDITIONAL_ARGS} \
      2>&1 | tee -a ${WS_DIR}/logs/hf---${EXAMPLE_NAME}---${MODEL_NAME_LOG}---${TASK_NAME}.log
elif [ "${EXAMPLE_NAME}" == "summarization" ];then
    python ./transformers/examples/pytorch/${EXAMPLE_NAME}/${CODE_NAME} \
      --model_name_or_path ${MODEL_NAME} \
      --do_eval \
      --dataset_name xsum \
      --source_prefix "summarize: " \
      --output_dir /tmp/${TASK_NAME}/ \
      --overwrite_output_dir \
      --predict_with_generate \
      --channels_last ${CHANNELS_LAST} \
      --profile ${PROFILE} \
      ${ADDITIONAL_ARGS} \
      2>&1 | tee -a ${WS_DIR}/logs/hf---${EXAMPLE_NAME}---${MODEL_NAME_LOG}---${TASK_NAME}.log
fi

# outputs (handles different metrics)
LATENCY=$(grep 'output latency:' ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*latency//;s/[^0-9.]//g')
THROUGHPUT=$(grep 'output throughput:' ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*throughput//;s/[^0-9.]//g')
EVAL_BS=$(grep 'output batch size:' ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*batch size//;s/[^0-9.]//g')
key_words="None"
if [ "${EXAMPLE_NAME}" == "text-classification" ];then
    if [ "${TASK_NAME}" == "cola" ];then
        key_words="eval_matthews_correlation"
    elif [ "${TASK_NAME}" == "stsb" ];then
        key_words="eval_pearson"
        METRIC=$(grep ${key_words} ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*${key_words}//;s/[^0-9.]//g')
        echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${key_words} ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${METRIC} | tee -a ./logs/summary_accuracy.log

        key_words="eval_spearmanr"
    elif [ "${TASK_NAME}" == "mrpc" ];then
        key_words="eval_f1"
        METRIC=$(grep ${key_words} ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*${key_words}//;s/[^0-9.]//g')
        echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${key_words} ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${METRIC} | tee -a ./logs/summary_accuracy.log

        key_words="eval_accuracy"
    else
        key_words="eval_accuracy"
    fi
elif [ "${EXAMPLE_NAME}" == "token-classification" ];then
    key_words="eval_f1"
    METRIC=$(grep ${key_words} ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*${key_words}//;s/[^0-9.]//g')
    echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${key_words} ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${METRIC} | tee -a ./logs/summary_accuracy.log

    key_words="eval_accuracy"
elif [ "${EXAMPLE_NAME}" == "multiple-choice" ];then
    key_words="eval_accuracy"
elif [ "${EXAMPLE_NAME}" == "question-answering" ];then
    key_words="eval_f1"
    METRIC=$(grep ${key_words} ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*${key_words}//;s/[^0-9.]//g')
    echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${key_words} ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${METRIC} | tee -a ./logs/summary_accuracy.log

    key_words="eval_exact_match"
elif [[ "${EXAMPLE_NAME}" == "masked-language-modeling" || "${EXAMPLE_NAME}" == "casual-language-modeling" ]];then
    key_words="perplexity"
elif [ "${EXAMPLE_NAME}" == "summarization" ];then
    key_words="eval_rouge1"
    METRIC=$(grep ${key_words} ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | awk '{print $3}')
    echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${key_words} ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${METRIC} | tee -a ./logs/summary_accuracy.log

    key_words="eval_rouge2"
    METRIC=$(grep ${key_words} ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | awk '{print $3}')
    echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${key_words} ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${METRIC} | tee -a ./logs/summary_accuracy.log

    key_words="eval_rougeL"
    METRIC=$(grep ${key_words} ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*${key_words}//;s/[^0-9.]//g')
    echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${key_words} ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${METRIC} | tee -a ./logs/summary_accuracy.log

    key_words="eval_rougeLsum"
    METRIC=$(grep ${key_words} ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*${key_words}//;s/[^0-9.]//g')
    echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${key_words} ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${METRIC} | tee -a ./logs/summary_accuracy.log

    key_words="eval_gen_len"
fi

# profiler
if [ "${PROFILE}" == "True" ];then
    TIMELINE_FILENAME=$(grep 'timeline filename:' ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*timeline filename: //')
    python profile_parser.py -f ${TIMELINE_FILENAME} 2>&1 | tee ${WS_DIR}/logs/hf---${EXAMPLE_NAME}---${MODEL_NAME_LOG}---${TASK_NAME}---ProfilerTimeline.log
fi
    
echo ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${IPEX_MODE} ${PRECISION} ${EVAL_BS} ${THROUGHPUT} | tee -a ./logs/summary.log
echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} throughput_mode ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${THROUGHPUT} | tee -a ./logs/summary_stockPT_throughput.log

METRIC=$(grep ${key_words} ./logs/hf---$EXAMPLE_NAME---$MODEL_NAME_LOG---$TASK_NAME.log | tail -1 | sed -e 's/.*${key_words}//;s/[^0-9.]//g')
echo broad_hf ${EXAMPLE_NAME}_${MODEL_NAME_LOG}_${TASK_NAME} ${key_words} ${PATH_LOG} ${PRECISION} ${EVAL_BS} ${METRIC} | tee -a ./logs/summary_accuracy.log