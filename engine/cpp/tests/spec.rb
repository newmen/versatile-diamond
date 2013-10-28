require 'colorize'
require 'stringio'

ENGINE_DIR = '../'
CC = 'g++'
FLAGS = "--std=c++0x -DDEBUG -fopenmp -I#{ENGINE_DIR}"
OBJS = Dir['obj/*.o'].reject { |file_name| file_name =~ /main.o$/ }

def random_name
  (rand(5) + 3).times.reduce('') { |acc| acc << ('a'..'z').to_a.sample } +
    (rand(2) + 1).times.reduce('') { |acc| acc << ('0'..'9').to_a.sample }
end

def compile_line(file_name, random_name)
  "#{CC} #{FLAGS} #{OBJS.join(' ')} #{file_name} -o #{random_name}"
end

def count_asserts(file_name)
  @asserts ||= 0

  File.open(file_name) do |f|
    @asserts += f.readlines.join.scan(/\bassert\(/).size
  end
end

def asserts
  @asserts
end

def check(file_name)
  count_asserts(file_name)

  rn = random_name
  cl = compile_line(file_name, rn)
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

def count_asserts_from_engine
  files = %w(h cpp).reduce([]) do |acc, ext|
    acc + Dir["#{ENGINE_DIR}**/*.#{ext}"]
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
