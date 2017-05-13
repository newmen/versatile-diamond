PREFIX = 'ex'

current_dir = `pwd`.chomp

[
  ['engine/hand-generations', 'hand', 'simple-diamond'],
  ['results/eg1', 'auto', 'simulate'],
].each do |exec_dir, suffix, bin|
  Dir.chdir("#{current_dir}/#{exec_dir}")
  (1..4).each do |i|
    name = "#{PREFIX}#{i}-#{suffix}"
    `./#{bin} #{name} > #{name}.log &`
  end
end
