require 'erb'
require 'colorize'
require 'stringio'

ENGINE_DIR = '..'
RESULTS_DIR = '../../../results'
GENERATIONS_DIR = "#{RESULTS_DIR}/hand-generations"
OBJS_DIR = 'obj'

CC = 'g++'
FLAGS = "--std=c++0x -DPARALLEL -DTHREADS_NUM=3 -fopenmp -I#{ENGINE_DIR}/ -I#{RESULTS_DIR}/"
# FLAGS = "--std=c++0x -DPRINT -DTHREADS_NUM=1 -I#{ENGINE_DIR}/ -I#{RESULTS_DIR}/"
# FLAGS = "--std=c++0x -DTHREADS_NUM=1 -I#{ENGINE_DIR}/ -I#{RESULTS_DIR}/"

# Provides string by which compilation will do
# @return [String] the compilation string
def compile_line(file_in, file_out, additional_args = '')
  "#{CC} #{FLAGS} #{additional_args} #{file_in} -o #{file_out}"
end

# Makes random sequence of chars
# @param [Range] range of chars which will be used for random sequence
# @param [Integer] min_length the minimal length of result sequence
# @param [Integer] add_length the additional length of result sequence
# @return [String] the random sequence of characters
def random_sequence(range, min_length, add_length)
  (min_length + rand(add_length)).times.reduce('') do |acc|
    acc << range.to_a.sample
  end
end

# Makes random name
# @return [String] the random name
def random_name
  random_sequence('a'..'z', 3, 5) + random_sequence('0'..'9', 1, 2)
end

# Gets all directories with source files
# @return [Array] the array of directories
def all_dirs
  Dir["#{ENGINE_DIR}/**/"] + Dir["#{GENERATIONS_DIR}/**/"]
end

# Collects files in directories by pattern
# @param [Array] dirs directories in which all files will collected by pattern
# @param [String] pattern by which files will collected
# @return [Array] collected files
def collect_files(dirs, pattern)
  dirs.reduce([]) do |acc, dir|
    acc + Dir["#{dir}/#{pattern}"].map { |filepath| filepath.gsub('//', '/') }
  end
end

# Finds all C++ code files and makes Makefile by them, after that do `make` command
# @return [String] the make command output
def make
  source_dirs = all_dirs.reduce([]) do |acc, dir_name|
    dir_name =~ /^#{Regexp.escape(ENGINE_DIR)}\/tests/ ?
      acc :
      acc << dir_name
  end

  objects_dirs = source_dirs.map do |dir|
    rep_dir = dir =~ /^#{Regexp.escape(RESULTS_DIR)}/ ? RESULTS_DIR : ENGINE_DIR
    dir.sub(rep_dir, OBJS_DIR)
  end

  makefile = ERB.new(File.read('Makefile.erb'))

  objects_dirs = objects_dirs.join(' ')
  header_files = collect_files(source_dirs, '*.h').join(' ')
  source_files = collect_files(source_dirs, '*.cpp').reject do |filename|
    filename =~ /main\.cpp$/
  end
  source_files = source_files.join(' ')

  File.open('Makefile', 'w') do |f|
    f.write(makefile.result(binding))
  end

  `make clean; make`
end

# Compilates test file
# @param [String] file_name the name of compiling test file
# @param [String] random_name the name of binary output file
def compile_test(file_name, random_name)
  if !@maked && ARGV.size == 0
    make
    @maked = true
  end

  supports = Dir['support/**/*.cpp']
  objs = Dir["#{OBJS_DIR}/**/*.o"]
  args = "#{supports.join(' ')} #{objs.join(' ')}"
  compile_line(file_name, random_name, args)
end

# Counts assert expressions in some file
# @param [String] file_name the name of scanning file
def count_asserts(file_name)
  @asserts ||= 0
  @asserts += File.read(file_name).scan(/\bassert/).size
end

# Gets number of counted asserts
# @return [Integer] the number of assert expressions
def asserts
  @asserts
end

# Runs test
# @param [String] file_name the name of running test file
def check(file_name)
  count_asserts(file_name)

  rn = random_name
  cl = compile_test(file_name, rn)
  puts cl

  `#{cl}`
  if $?.success?
    output = `./#{rn} 2>&1`
    puts output unless output.strip == ''

    run_result = $?.success?
    if run_result
      puts " +++ #{file_name} +++".green
      puts
      return nil
    end
  end
  puts " --- #{file_name} ---".red
  puts
  file_name
ensure
  `rm -f #{rn}`
end

# Counts asserts in engine source
def count_asserts_from_engine
  files = %w(h cpp).reduce([]) do |acc, ext|
    acc + [ENGINE_DIR, GENERATIONS_DIR].reduce([]) do |a, dir|
      a + Dir["#{dir}/**/*.#{ext}"]
    end
  end

  files.each(&method(:count_asserts))
end

spec_files = Dir['**/*.cpp'] - Dir['support/*.cpp']
result =
  if ARGV.size > 0
    ARGV.map do |spec_file_name|
      if spec_files.include?(spec_file_name)
        check(spec_file_name)
      else
        puts "Undefined spec: #{spec_file_name}"
        spec_file_name
      end
    end
  else
    count_asserts_from_engine
    spec_files.shuffle.map(&method(:check))
  end

puts
puts "Total #{asserts} examples..."
if result.any?
  print "Failed".red
  errors = result.compact.size
  puts " [ #{(result.size - errors).to_s.green} | #{errors.to_s.red} ]"
else
  print "Success".green
  puts " [ #{(result.size).to_s.green} ]"
end
