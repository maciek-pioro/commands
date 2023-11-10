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

function ,log(){
	,_go_to_latest_exp
	,_print_latest_log
}

