#!/bin/sh

current_dir=${1}
composit_name=${2}-${3}x${4}-${5}s
results_dir=${current_dir}/results/${composit_name}

engine_bin=${current_dir}/engine
tmp_dir=/tmp/vd-engine-${composit_name}

mkdir -p $tmp_dir
$engine_bin ${tmp_dir}/${2} $3 $4 $5 $6 $7 > ${tmp_dir}/log

mkdir -p $results_dir
mv ${tmp_dir}/* ${results_dir}/