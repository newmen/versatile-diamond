#!/bin/sh

current_dir=${1}
composit_name=vde-${2}
results_dir=${current_dir}/results/${composit_name}

engine_bin=${current_dir}/engine
tmp_dir=/tmp/vd-engine-${composit_name}

mkdir -p $results_dir
cp ${current_dir}/configs/* ${results_dir}/

mkdir -p $tmp_dir
$engine_bin ${tmp_dir}/${2} > ${tmp_dir}/log

mv ${tmp_dir}/* ${results_dir}/
rm -rf ${tmp_dir}
cd ${results_dir}
${current_dir}/slices_graphics_renderer.rb ${composit_name}.sls
cd -
