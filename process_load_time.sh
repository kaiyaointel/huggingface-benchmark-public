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
    t1=$(grep "loading configuration file" ./logs/$model_name_LOG.log | head -1 | sed -e 's/.*01-07 //;s/,.*//')
    s1=${t1:0-2:2}
    t2=$(grep "INFO|tokenization_utils_base.py" ./logs/$model_name_LOG.log | head -1 | sed -e 's/.*01-07 //;s/,.*//')
    s2=${t2:0-2:2}
    t3=$(grep "loading weights file" ./logs/$model_name_LOG.log | head -1 | sed -e 's/.*01-07 //;s/,.*//')
    s3=${t3:0-2:2}
    t4=$(grep "WARNING - datasets.arrow_dataset" ./logs/$model_name_LOG.log | head -1 | sed -e 's/.*2022 //;s/ -.*//')
    s4=${t4:0-2:2}
    t5=$(grep "***** Running Evaluation *****" ./logs/$model_name_LOG.log | head -1 | sed -e 's/.*01-07 //;s/,.*//')
    s5=${t5:0-2:2}
	
    d1=`expr $s2 - $s1`
    if [ ${d1} -lt 0 ];then
        d1=`expr $d1 + 60`
    fi
    d2=`expr $s3 - $s2`
    if [ ${d2} -lt 0 ];then
        d2=`expr $d2 + 60`
    fi
    d3=`expr $s4 - $s3`
    if [ ${d3} -lt 0 ];then
        d3=`expr $d3 + 60`
    fi
    d4=`expr $s5 - $s4`
    if [ ${d4} -lt 0 ];then
        d4=`expr $d4 + 60`
    fi
	
    echo $model_name_LOG $d1 $d2 $d3 $d4 | tee -a summary.log
done
