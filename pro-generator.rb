require 'pathname'

ENGINE_DIR = Pathname.new('engine/cpp').freeze
SRC_SUB_DIR = 'src'.freeze

def head(relative_path_to_engine_dir)
  <<-HEAD
TEMPLATE = app
CONFIG -= app_bundle
CONFIG -= qt

QMAKE_INCDIR += #{relative_path_to_engine_dir}
QMAKE_INCDIR += /usr/local/include
QMAKE_LIBDIR += /usr/local/lib

QMAKE_CXXFLAGS_RELEASE += -DNDEBUG
QMAKE_CXXFLAGS += -std=c++11
QMAKE_CXXFLAGS += -w

LIBS += -pthread
LIBS += -lyaml-cpp
LIBS += -w

  HEAD
end

def join_files(files)
  files.map { |file| "    #{file}" }.join(" \\\n")
end

def body(head_files, body_files)
  <<-BODY
HEADERS += \\
#{join_files(head_files)}

SOURCES += \\
#{join_files(body_files)}

  BODY
end

def find_files(dir, path_prefix)
  pwd = `pwd`
  raw = `cd #{dir} && find . -type f`.split("\n")
  `cd #{pwd}`
  list = raw.map { |file| "#{path_prefix}/#{file[2..-1]}" }
  groups = list.group_by { |path| path.scan(/\.(?:h|cpp)$/).first }
  [groups['.h'], groups['.cpp']]
end

def generate(src_gen_dir)
  relative_engine_dir = ENGINE_DIR.relative_path_from(src_gen_dir)
  engine_heads, engine_bodies = find_files(ENGINE_DIR, relative_engine_dir)
  gen_heads, gen_bodies = find_files("#{src_gen_dir}/#{SRC_SUB_DIR}", SRC_SUB_DIR)

  content =
    head(relative_engine_dir) +
    body(engine_heads + gen_heads, engine_bodies + gen_bodies)

  File.open(src_gen_dir + "#{src_gen_dir.basename}.pro", 'w') do |f|
    f.write(content)
  end
end

def main
  if ARGV.size == 1 && Dir.exist?("#{ARGV[0]}/#{SRC_SUB_DIR}")
    generate(Pathname.new(ARGV[0]).freeze)
  else
    puts 'Please pass just the path to generated source directory'
    puts "ruby #{__FILE__} <path-to-directory>"
  end
end

main
