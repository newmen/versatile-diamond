require 'colorize'
require 'stringio'

ENGINE_DIR = '..'
ENGINE_SRC_DIR = "#{ENGINE_DIR}/cpp"
ENGINE_OBJS_DIR = "#{ENGINE_DIR}/obj"

HANDG_DIR = '../hand-generations'
HANDG_SRC_DIR = "#{HANDG_DIR}/src"
HANDG_OBJS_DIR = "#{HANDG_DIR}/obj"

GCC_PATH = '/usr/local'
CC_BIN = 'g++-7'
CXX = "#{GCC_PATH}/bin/#{CC_BIN}"
FLAGS = "-I#{GCC_PATH}/include -I#{ENGINE_SRC_DIR} -I#{HANDG_SRC_DIR} -L#{GCC_PATH}/lib -std=c++11 -O2 -pthread -lyaml-cpp"

# Provides string by which compilation will do
# @return [String] the compilation string
def compile_line(file_in, file_out, additional_args = '')
  objs = [ENGINE_OBJS_DIR, HANDG_OBJS_DIR].reduce([]) do |acc, dir|
    acc + Dir["#{dir}/**/*.o"]
  end

  objs.reject! { |path| path =~ /main\.o$/ }
  objs_str = objs.join(' ')
  "#{CXX} #{FLAGS} #{additional_args} #{objs_str} -o #{file_out} #{file_in}"
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

# Compilates test file
# @param [String] file_name the name of compiling test file
# @param [String] random_name the name of binary output file
def compile_test(file_name, random_name)
  if (!@maked && ARGV.size == 0) || ARGV.size == 1
    `make -j#{processor_count}`
    @maked = true
  end

  supports = Dir['support/**/*.cpp']
  args = "#{supports.join(' ')}"
  compile_line(file_name, random_name, args)
end

# Gets the number of processor cores
# The original source code: https://github.com/grosser/parallel
# @return [Integer] the number of cores
def processor_count
  case RbConfig::CONFIG['host_os']
  when /darwin9/
    `hwprefs cpu_count`.to_i
  when /darwin/
    ((`which hwprefs` != '') ? `hwprefs thread_count` : `sysctl -n hw.ncpu`).to_i
  when /linux/
    `cat /proc/cpuinfo | grep processor | wc -l`.to_i
  when /freebsd/
    `sysctl -n hw.ncpu`.to_i
  when /mswin|mingw/
    require 'win32ole'
    wmi = WIN32OLE.connect("winmgmts://")
    # TODO: count hyper-threaded in this
    cpu = wmi.ExecQuery("select NumberOfCores from Win32_Processor")
    cpu.to_enum.first.NumberOfCores
  else
    1
  end
end

# Runs test
# @param [String] file_name the name of running test file
def check(file_name)
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
      return [file_name, true]
    end
  end
  puts " --- #{file_name} ---".red
  puts
  [file_name, false]
ensure
  `rm -f #{rn}`
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
    spec_files.shuffle.map(&method(:check))
  end

puts
groups = result.group_by(&:last)
if groups[false]
  result.sort.each do |file_name, status|
    puts file_name.send(status ? :green : :red)
  end
  puts
  print "Failed".red
  errors = groups[false].size
  puts " [ #{(result.size - errors).to_s.green} | #{errors.to_s.red} ]"
else
  print "Success".green
  puts " [ #{(result.size).to_s.green} ]"
end
