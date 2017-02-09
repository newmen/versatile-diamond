current_dir = `pwd`.chomp

PLOTS_DIR = 'plots'
TOTAL_DIR = 'results/total'

[
  ['engine/hand-generations', 'hand', 'engine/calculations', '../../..'],
  ['results/eg1', 'auto', 'results/calculations', '../../../../engine'],
].each do |raw_path, suffix, result_path, pre_gp_path|
  (1..4).each do |i|
    Dir.chdir("#{current_dir}/#{raw_path}")
    prefix = "eh#{i}"

    unless Dir["#{prefix}*"].empty?
      bad_log_file = "eg#{i}-#{suffix}.log"
      new_log_file = "#{prefix}-#{suffix}.log"
      `[[ -f #{bad_log_file} ]] && mv #{bad_log_file} #{new_log_file}`

      tmp_dir = "temp_e#{i}"
      `mkdir -p #{tmp_dir}/#{PLOTS_DIR}`
      `[[ -f #{new_log_file} ]] && mv eh#{i}* #{tmp_dir}/`
      `[[ -d #{tmp_dir} ]] && mv #{tmp_dir}/*.sls #{tmp_dir}/#{PLOTS_DIR}`
      `[[ -d #{tmp_dir} ]] && mv #{tmp_dir} #{prefix}`
    end
    
    calc_dir = "#{current_dir}/#{result_path}"
    `[[ -d #{prefix} ]] && mv #{prefix} #{calc_dir}`

    Dir.chdir("#{calc_dir}/#{prefix}/#{PLOTS_DIR}")
    if Dir['*.png'].empty?
      sls_file = `ls *.sls`.chomp
      `ruby #{pre_gp_path}/slices_graphics_renderer.rb #{sls_file}`
    end

    Dir.chdir('..')
    total_dir = "#{current_dir}/#{TOTAL_DIR}/#{suffix}"
    `mkdir -p #{total_dir}`
    `cp -R #{PLOTS_DIR} #{total_dir}/#{prefix}-#{PLOTS_DIR}`
  end
end
