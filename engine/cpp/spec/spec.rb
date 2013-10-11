require 'colorize'
require 'stringio'

CC = 'g++'
FLAGS = '--std=c++0x -DDEBUG -fopenmp -I../'
OBJS = Dir['obj/*.o'].reject { |file_name| file_name =~ /main.o$/ }

def random_name
  (rand(5) + 3).times.reduce('') { |acc| acc << ('a'..'z').to_a.sample } +
    (rand(2) + 1).times.reduce('') { |acc| acc << ('0'..'9').to_a.sample }
end

def compile_line(file_name, random_name)
  "#{CC} #{FLAGS} #{OBJS.join(' ')} #{file_name} -o #{random_name}"
end

def count_assert(file_name)
  File.open(file_name) do |f|
    f.readlines.join.scan(/\bassert\(/).size
  end
end

def check(file_name)
  @asserts ||= 0
  @asserts += count_assert(file_name)

  rn = random_name
  cl = compile_line(file_name, rn)
  puts cl

  `#{cl}`
  if $?.success?
    output = `./#{rn} 2>&1`
    puts output unless output.strip == ''

    run_result = $?.success?
    `rm -f #{rn}`
    if run_result
      puts " +++ #{file_name} +++".green
      puts
      return nil
    end
  end
  puts " --- #{file_name} ---".red
  puts
  file_name
end

def asserts
  @asserts
end

spec_files = Dir['**/*.cpp']
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
puts "Total #{asserts} examples..."
if result.any?
  print "Failed".red
  errors = result.compact.size
  puts " [ #{(result.size - errors).to_s.green} | #{errors.to_s.red} ]"
else
  print "Success".green
  puts " [ #{(result.size).to_s.green} ]"
end
