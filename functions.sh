function ,watch() {
	tmpfile="$(mktemp)"
	while true; 
 	do; 
  		$@ > "$tmpfile";
    		clear;
		cat "$tmpfile";
  		sleep 1;
    	done;
}


function ,myjobs() {
	watch "squeue -u $USER --format='%.18i | %.9P | %45j | %.2t | %.10M | %.8Q | %.20V | %.6D | %R'"
}

function ,ourjobs() {
	watch 'squeue --format="%.18i | %.12u | %.12P | %45j | %.2t | %.10M | %.8Q | %.20V | %.6D | %R"'
}

function ,sparsity() {
	cd /net/pr2/projects/plgrid/plggllmeffi/mpioro/sparsity
}

function ,cancel_all() {
	 scancel `squeue -u $USER | tail -n +2 | awk '{print $1}'`
}

function ,_go_to_latest_exp() {
	cd /net/pr2/projects/plgrid/plggllmeffi/mpioro/sparsity_code_cemetery
	latest_dir=$(ls -td -- */ | head -n 1)
	cd "$latest_dir"
}

function ,_print_latest_log(){
	latest_file=$(find . -maxdepth 1 -name "*.out" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d' ')
	cat "$latest_file"
}

function ,check_autoupdate_works(){
	echo "It works indeed"
}

function ,log(){
	,_go_to_latest_exp
	,_print_latest_log
}

function ,usage(){
	if [ -z "$1" ]; then
			1=250
	fi
	hpc-jobs-history -A plgplggllmeffi-gpu-a100 -d "$1" | awk '$11 ~ /^[0-9.]*$/ {sum += $11} END {print sum}'
}


function ,summarize_nodes(){
	python3 ~/mp-scripts/python_scripts/slurm_resources.py
}

# credit: https://hpc-wiki.info/hpc/Zsh
function ,slurmlogpath { 
	scontrol show job $1 | grep StdOut | sed -e 's/^\s*StdOut=//' 
}

function ,slurmerrlogpath { 
	scontrol show job $1 | grep StdErr | sed -e 's/^\s*StdErr=//' 
}

# credit: https://hpc-wiki.info/hpc/Zsh
function ,ftails { 
    JOBID=$1
    if [[ -z $JOBID ]]; then
        JOBS=$(squeue --format="%i \\'%j\\' " -u $USER -t RUNNING | grep -v JOBID)
        NUMBER_OF_JOBS=$(echo "$JOBS" | wc -l)
        JOBID=
        if [[ "$NUMBER_OF_JOBS" -eq 1 ]]; then
            JOBID=$(echo $JOBS | sed -e "s/'//g" | sed -e 's/ .*//')
        else
            JOBS=$(echo $JOBS | tr -d '\n')

            JOBID=$(eval "whiptail --title 'Choose jobs to tail' --menu 'Choose Job to tail' 25 78 16 $JOBS" 3>&1 1>&2 2>&3)
        fi
    fi
    SLURMLOGPATH=$(,slurmlogpath $JOBID)
    SLURMERRLOGPATH=$(,slurmerrlogpath $JOBID)
    if [[ -e $SLURMLOGPATH ]]; then
        tail -n100 -f $SLURMLOGPATH $SLURMERRLOGPATH
    else
        echo "No slurm-log-file found"
    fi
}


# deprecated

# credit: https://github.com/kuba-krj
# function ,gpu_blame(){
# 	nvidia-smi --query-gpu=index,uuid --format=csv,noheader,nounits | awk -F, '{print $1, $2}' | while read gpu_index gpu_uuid; do nvidia-smi --query-compute-apps=pid,used_memory,gpu_uuid --format=csv,noheader,nounits | grep $gpu_uuid | awk -v idx="$gpu_index" -F, '{printf("process %s on gpu-%s using %.2f GB memory: owner ", $1, idx, $2/1024); system("ps -o user= -p "$1)}'; done
# }
