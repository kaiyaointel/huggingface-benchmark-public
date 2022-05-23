set -x

WS=${PWD}
rm -rf multi-instance-sh
mkdir multi-instance-sh
mkdir logs
mkdir logs/multi-instance-logs

# fetch cpu and core info for multi-instance setup
cores_per_instance=$cores_per_instance
numa_nodes_use=0
cat /etc/os-release
cat /proc/sys/kernel/numa_balancing
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
sync
uname -a
free -h
numactl -H
sockets_num=$(lscpu |grep 'Socket(s):' |sed 's/[^0-9]//g')
cores_per_socket=$(lscpu |grep 'Core(s) per socket:' |sed 's/[^0-9]//g')
phsical_cores_num=$( echo "${sockets_num} * ${cores_per_socket}" |bc )
numa_nodes_num=$(lscpu |grep 'NUMA node(s):' |sed 's/[^0-9]//g')
cores_per_node=$( echo "${phsical_cores_num} / ${numa_nodes_num}" |bc )
cpu_model="$(lscpu |grep 'Model name:' |sed 's/.*: *//')"
# cpu array
if [ "${numa_nodes_use}" == "all" ];then
    numa_nodes_use_='1,$'
elif [ "${numa_nodes_use}" == "0" ];then
    numa_nodes_use_=1
else
    numa_nodes_use_=${numa_nodes_use}
fi
cpu_array=($(numactl -H |grep "node [0-9]* cpus:" |sed "s/.*node [0-9]* cpus: *//" |\
sed -n "${numa_nodes_use_}p" |cut -f1-${cores_per_node} -d' ' |sed 's/$/ /' |tr -d '\n' |awk -v cpi=${cores_per_instance} -v cpn=${cores_per_node} '{
    for( i=1; i<=NF; i++ ) {
        if(i % cpi == 0 || i % cpn == 0) {
            print $i","
        }else {
            printf $i","
        }
    }
}' |sed "s/,$//"))
instance=${#cpu_array[@]}

# generate multiple instance scripts
for(( i=0; i<instance; i++ ))
do
    real_cores_per_instance=$(echo ${cpu_array[i]} |awk -F, '{print NF}')
    log_file="${WS}/logs/multi-instance-logs/rcpi${real_cores_per_instance}-ins${i}.log"
    NUMA_OPERATOR="numactl --localalloc --physcpubind ${cpu_array[i]}"
    printf "${NUMA_OPERATOR} bash run_workload.sh ${1} ${2} ${3} ${4} ${5} ${6} \
    > ${log_file} 2>&1 &  \n" |tee -a ${WS}/multi-instance-sh/temp.sh
done
echo -e "\n wait" >> ${WS}/multi-instance-sh/temp.sh
echo -e "\n\n\n\n Running..."
source ${WS}/multi-instance-sh/temp.sh
echo -e "Finished.\n\n\n\n"

throughput=$(grep 'output throughput:' ${WS}/logs/multi-instance-logs/rcpi* |sed -e 's/.*throughput//;s/,.*//;s/[^0-9.]//g' |awk '
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
echo multi-instance-mode example:${1} model:${MODEL_NAME} task:${TASK_NAME} ipex:${2} precision:${3} bs:${4} jit:${5} jitmodelname:${6} throughput:${throughput} | tee -a ${WS}/logs/summary.log

# for Stock PT Monitor
PATH_LOG="imperative"
if [ ${5} == "JIT" ];then
    PATH_LOG="jit"
fi
if [ ${5} == "JIT_OPT" ];then
    PATH_LOG="jit_optimize"
fi
echo broad_hf ${1}_${MODEL_NAME}_${TASK_NAME} multi_instance_mode ${PATH_LOG} ${3} ${4} ${throughput} | tee -a ${WS}/logs/summary_stockPT_mi.log
