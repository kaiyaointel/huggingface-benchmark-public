precision=$1
bs=$2

IPEX_OPTION="NOIPEX"
if [ ${use_ipex} == "yes" ];then
    IPEX_OPTION="IPEX"
elif [ ${use_ipex} == "no" ];then
    IPEX_OPTION="NOIPEX"
fi

### oneDNN Acceptance Test and Stock PT Monitor Nightly model list
# 1. text-classfication + bert-base-cased + mrpc (3 paths)
# 2. text-classfication + distilbert-base-cased + cola (3 paths)
# 3. qa + bert-large-cased (3 paths)
# 4. qa + albert-base-v1  (3 paths)

# 1. text-classfication + bert-base-cased + mrpc (3 paths)
unset NUMA_OPERATOR
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="bert-base-cased"
export TASK_NAME="mrpc"
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

unset NUMA_OPERATOR
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="bert-base-cased"
export TASK_NAME="mrpc"
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT bert

unset NUMA_OPERATOR
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="bert-base-cased"
export TASK_NAME="mrpc"
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT_OPT bert

# 2. text-classfication + distilbert-base-cased + cola (3 paths)
unset NUMA_OPERATOR
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="distilbert-base-cased"
export TASK_NAME="cola"
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

unset NUMA_OPERATOR
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="distilbert-base-cased"
export TASK_NAME="cola"
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT distilbert

unset NUMA_OPERATOR
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="distilbert-base-cased"
export TASK_NAME="cola"
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT_OPT distilbert

# 3. qa + bert-large-cased (3 paths)
unset NUMA_OPERATOR
export NUMA_OPERATOR="numactl --cpunodebind=0 --membind=0"
export EXAMPLE_NAME="question-answering"
export MODEL_NAME="bert-large-cased"
export TASK_NAME=""
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

unset NUMA_OPERATOR
export EXAMPLE_NAME="question-answering"
export MODEL_NAME="bert-large-cased"
export TASK_NAME=""
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT qa_models

unset NUMA_OPERATOR
export EXAMPLE_NAME="question-answering"
export MODEL_NAME="bert-large-cased"
export TASK_NAME=""
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT_OPT qa_models

# 4. qa + albert-base-v1  (3 paths)
unset NUMA_OPERATOR
export EXAMPLE_NAME="question-answering"
export MODEL_NAME="albert-base-v1"
export TASK_NAME=""
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

unset NUMA_OPERATOR
export EXAMPLE_NAME="question-answering"
export MODEL_NAME="albert-base-v1"
export TASK_NAME=""
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT qa_models

unset NUMA_OPERATOR
export EXAMPLE_NAME="question-answering"
export MODEL_NAME="albert-base-v1"
export TASK_NAME=""
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT_OPT qa_models

### Original model list
# 20 w/o JIT workloads
unset NUMA_OPERATOR
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="google/electra-base-generator"
export TASK_NAME="cola"
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs
	
# unset NUMA_OPERATOR
# export EXAMPLE_NAME="token-classification"
# export MODEL_NAME="gpt2"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs
	
# unset NUMA_OPERATOR
# export EXAMPLE_NAME="token-classification"
# export MODEL_NAME="google/electra-base-generator"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs
	
# unset NUMA_OPERATOR
# export EXAMPLE_NAME="multiple-choice"
# export MODEL_NAME="distilbert-base-cased"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="multiple-choice"
# export MODEL_NAME="google/electra-base-discriminator"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="masked-language-modeling"
# export MODEL_NAME="bert-base-cased"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="masked-language-modeling"
# export MODEL_NAME="distilbert-base-cased"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

unset NUMA_OPERATOR
export EXAMPLE_NAME="casual-language-modeling"
export MODEL_NAME="xlm-roberta-base"
export TASK_NAME=""
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="question-answering"
# export MODEL_NAME="facebook/bart-large"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="summarization"
# export MODEL_NAME="t5-base"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="albert-base-v1"
# export TASK_NAME="cola"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs
	
# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="roberta-base"
# export TASK_NAME="cola"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs
	
unset NUMA_OPERATOR
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="xlnet-base-cased"
export TASK_NAME="cola"
bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs
	
# unset NUMA_OPERATOR
# export EXAMPLE_NAME="multiple-choice"
# export MODEL_NAME="bert-base-cased"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="question-answering"
# export MODEL_NAME="xlnet-base-cased"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="question-answering"
# export MODEL_NAME="xlm-roberta-base"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="masked-language-modeling"
# export MODEL_NAME="albert-base-v1"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="masked-language-modeling"
# export MODEL_NAME="google-electra-base-discriminator"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="casual-language-modeling"
# export MODEL_NAME="bert-base-cased"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="casual-language-modeling"
# export MODEL_NAME="roberta-base"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs

# 10 w/ JIT workloads
# jit & jit.optimize_for_inference
# Case 1: text-classification, bert-base-cased, cola & mrpc
# Case 2: text-classficiation, distilbert-base-cased, cola & mrpc
# Case 3: question-answering, albert-base-v1

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="bert-base-cased"
# export TASK_NAME="cola"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT bert

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="bert-base-cased"
# export TASK_NAME="cola"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT_OPT bert

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="bert-base-cased"
# export TASK_NAME="mrpc"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT bert

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="bert-base-cased"
# export TASK_NAME="mrpc"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT_OPT bert

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="distilbert-base-cased"
# export TASK_NAME="cola"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT distilbert

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="distilbert-base-cased"
# export TASK_NAME="cola"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT_OPT distilbert

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="distilbert-base-cased"
# export TASK_NAME="mrpc"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT distilbert

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="text-classification"
# export MODEL_NAME="distilbert-base-cased"
# export TASK_NAME="mrpc"
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT_OPT distilbert

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="question-answering"
# export MODEL_NAME="albert-base-v1"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT qa_models

# unset NUMA_OPERATOR
# export EXAMPLE_NAME="question-answering"
# export MODEL_NAME="albert-base-v1"
# export TASK_NAME=""
# bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX_OPTION $precision $bs JIT_OPT qa_models
