### This file is to test the loading time (before inference) of model/dataset every time you run a model (request from Haihao)
### and the script here is based on text-classifiation (cola). 
### This file can be used together with process_load_time.sh.

mkdir logs
model_name="gpt2,bert-base-cased,distilbert-base-cased,albert-base-v1,roberta-base,xlnet-base-cased,xlm-roberta-base,bert-large-cased,google/electra-base-generator,google/electra-base-discriminator"
model_name_list=($(echo "${model_name}" |sed 's/,/ /g'))

for model_name in ${model_name_list[@]}
do
    # scripts
    model_name_LOG=${model_name}
    # handles model names like xxx/yyy to make it xxx-yyy for log filename sake
    if [[ ${model_name} =~ "/" ]]; then
        model_name_LOG=${model_name//'/'/'-'}
    fi
    # handles gpt2
    if [ "${model_name}" == "gpt2" ];then #gpt-2 cannot use run_glue.py out-of-box, need to download specific model
        model_name="./gpt2-model-for-classification_2/"
        model_name_LOG=gpt2
    fi
    python ./transformers/examples/pytorch/text-classification/run_glue.py \
          --model_name_or_path $model_name \
          --task_name cola \
          --max_seq_length 384 \
          --learning_rate 2e-5 \
          --overwrite_output_dir \
          --do_eval \
          --early_stop_at_iter 10 \
          --output_dir /tmp/cola/ 2>&1 | tee ./logs/$model_name_LOG.log
done

