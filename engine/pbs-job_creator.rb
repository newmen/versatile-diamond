def content
<<PBSTASK
#PBS -l walltime=999:0:0,nodes=1:ppn=1
#PBS -N vde-#{ARGV[1]}-#{ARGV[2]}x#{ARGV[3]}-#{ARGV[4]}s

#!/bin/bash
cd #{ARGV[0]}
./local-run.sh #{ARGV.join(' ')}
PBSTASK
end

samples = ('aa'..'zz').to_a
salt = 3.times.reduce('') { |acc| acc << samples.sample }
filename = "run_#{salt}#{rand(9)}.job"
File.write(filename, content)

puts filename
