## Easy Guide

### Environment pre-requisites
PyTorch, IPEX-CPU (if needed)

Enable jemalloc if applicable:
```
export LD_PRELOAD=${CONDA_PREFIX}/lib/libjemalloc.so
export LD_PRELOAD=${LD_PRELOAD}:${CONDA_PREFIX}/lib/libiomp5.so
```
Enable AVX512_CORE_AMX if applicable:
```
export DNNL_MAX_CPU_ISA=AVX512_CORE_AMX
export ONEDNN_MAX_CPU_ISA=AVX512_CORE_AMX
```

### Prepare Transformers (Hugging-Face)
Do ```bash set_env.sh``` (CPU) or ```bash set_env_gpu.sh``` (GPU) to set up transformers patching and installation, and gpt2 predownloads.

### Quickstart
```
python ./transformers/examples/pytorch/text-classification/run_glue.py \
      --model_name_or_path bert-base-cased \
      --task_name cola \
      --do_eval \
      --max_seq_length 384 \
      --learning_rate 2e-5 \
      --overwrite_output_dir \
      --output_dir /tmp/cola/ \
```

### Example of throughput mode with BS=2*core on 1 socket:
```
export NUMA_OPERATOR="numactl --cpunodebind=0 --membind=0"
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="bert-base-cased"
export TASK_NAME="cola"

${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} IPEX BF16 80
```
runs benchmark for model "bert-base-cased" on example "text-classification" and task "cola" with IPEX, BF16, and BS=80. 

PS: 

1. For GPU, simply modify BF16 to FP16.
2. TASK_NAME is only needed when EXAMPLE_NAME is "text-classification", and for other EXAMPLE_NAME we don't need TASK_NAME.

Another example:
```
export NUMA_OPERATOR="numactl --cpunodebind=0 --membind=0"
export EXAMPLE_NAME="casual-language-modeling"
export MODEL_NAME="xlm-roberta-base"
export TASK_NAME=""

bash run_workload.sh ${EXAMPLE_NAME} NOIPEX FP32 56
```
runs benchmark for model "xlm-roberta-base" on example "casual-language-modeling" with no IPEX (just Stock PT), FP32, and BS=56.

### Example of multi-instance mode (4 cores/1 ins) with BS=1 per instance:
```
export cores_per_instance=4
```
```
unset NUMA_OPERATOR
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="bert-base-cased"
export TASK_NAME="cola"

bash run_workload_multi_instance.sh ${EXAMPLE_NAME} IPEX BF16 1
```
PS:

1. On any new machine, you must first run the whole multi-instance benchmark script once (to pre-download models/datasets) before you officially collect performance, because different instances might download models/datasets at different speed and lead to incorrect performance values. For exmample, if instances 0,1,3 are still downloading something but instances 2,4,5,6,7 are already running inference, the throughput you collected is not 8-instance but ~5-instance.
2. Need to unset ${NUMA_OPERATOR} here for Multi-instance Mode as multi-instance script will set its own ${NUMA_OPERATOR}.

### Example of JIT on specific case:
```
export NUMA_OPERATOR="numactl --cpunodebind=0 --membind=0"
export EXAMPLE_NAME="text-classification"
export MODEL_NAME="bert-base-cased"
export TASK_NAME="cola"

${NUMA_OPERATOR} bash run_workload.sh ${EXAMPLE_NAME} IPEX BF16 80 JIT bert
```
PS: JIT is in initial phase of deployment, so there might be errors.

### Example of GPU MIG (Multi-Instance):
First confirm MIG settings on your CUDA:
```
sudo nvidia-smi
sudo nvidia-smi -mig 1
sudo nvidia-smi mig --list-gpu-instance-profiles
sudo nvidia-smi mig --list-gpu-instances
sudo nvidia-smi mig --list-compute-instance-profiles
sudo nvidia-smi -L
```
If MIG instances are not set up or if you have turned off MIG by ```sudo nvidia-smi -mig 0```, build instances again:
```
sudo nvidia-smi -mig 1
sudo nvidia-smi mig --create-gpu-instance 19
sudo nvidia-smi mig --create-gpu-instance 19
sudo nvidia-smi mig --create-gpu-instance 19
sudo nvidia-smi mig --create-gpu-instance 19
sudo nvidia-smi mig --create-gpu-instance 19
sudo nvidia-smi mig --create-gpu-instance 19
sudo nvidia-smi mig --create-gpu-instance 19
sudo nvidia-smi mig --gpu-instance-id 7 --create-compute-instance 0
sudo nvidia-smi mig --gpu-instance-id 8 --create-compute-instance 0
sudo nvidia-smi mig --gpu-instance-id 9 --create-compute-instance 0
sudo nvidia-smi mig --gpu-instance-id 11 --create-compute-instance 0
sudo nvidia-smi mig --gpu-instance-id 12 --create-compute-instance 0
sudo nvidia-smi mig --gpu-instance-id 13 --create-compute-instance 0
sudo nvidia-smi mig --gpu-instance-id 14 --create-compute-instance 0
```
Then run benchmark in MIGs:
```
bash run_auto_gpu_mig.sh
```
Result in: ```./logs/summary_MIG.log```

### Example of IPEX 1.10 broad test
```
export NUMA_OPERATOR="numactl --cpunodebind=0 --membind=0"
bash run_auto_ipex_broad.sh
```
