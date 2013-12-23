require 'pry'

require 'graphviz'

require 'forwardable'
require 'singleton'
require 'set'
require 'i18n'
I18n.load_path << files_in('locales/*.yml')

require_relative 'load_helper' # useful methods
require_each 'patches/*.rb' # same as monkey's patches
using VersatileDiamond::Patches::RichString

AUTO_LOADING_DIRS = Dir["#{__dir__}/lib/**/"].map do |dir|
  (m = dir.match(/\/(\w+)\/\Z/)) && m[1]
end.compact

# p AUTO_LOADING_DIRS

def VersatileDiamond.const_missing(class_name, dir = nil)
# p "Catched #{class_name}; #{dir}"
  filename = class_name.to_s.underscore
# p filename

  unless dir
# p " =>- not directly"
    dir = find_dir(filename, *AUTO_LOADING_DIRS.map { |dir| "lib/#{dir}" })
  end

  if dir
    require_relative "lib/#{dir}/#{filename}.rb"
    component = const_get("#{dir.classify}::#{class_name}")
# puts "#{component} loaded"
    return component if component
  end

  raise "#{class_name} is not found (it's realy!)"
end

AUTO_LOADING_DIRS.each do |dir|
  module_name = "VersatileDiamond::#{dir.classify}"
  eval <<-DEFINE
    module #{module_name}; end
    def (#{module_name}).const_missing(class_name)
# print "=== Using module #{module_name}"
# puts " -> #{dir} "
# print "--- "
# puts class_name
      VersatileDiamond.const_missing(class_name, '#{dir}')
    end
  DEFINE
end

def Object.const_missing(class_name)
# puts "--->>>+++ GLOBAL OBJECT #{class_name}"
  VersatileDiamond.const_missing(class_name)
end

require_each 'lib/**/*.rb'
