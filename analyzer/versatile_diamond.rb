require 'pry'

require 'graphviz'

require 'forwardable'
require 'fileutils'
require 'pathname'
require 'tsort'
require 'erb'
require 'set'
require 'i18n'
I18n.enforce_available_locales = true
I18n.load_path << files_in('locales/*.yml')

require_relative 'load_helper' # useful methods
require_each 'patches/*.rb' # same as monkey's patches
using VersatileDiamond::Patches::RichString

AUTO_LOADING_DIRS = Dir["#{__dir__}/lib/**/"].map do |dir|
  (m = dir.match(%r{/(\w+)/\Z})) && m[1]
end.compact +
  %w(
    generators/code
  )

def VersatileDiamond.const_missing(class_name, dir = nil)
  filename = class_name.to_s.underscore

  unless dir
    dir = find_dir(filename, *AUTO_LOADING_DIRS.map { |d| "lib/#{d}" })
  end

  if dir
    require_relative "lib/#{dir}/#{filename}.rb"
    component = const_get("#{dir.classify}::#{class_name}")
    return component if component
  end

  raise "#{class_name} is not found (it's realy!)"
end

AUTO_LOADING_DIRS.each do |dir|
  module_name = "VersatileDiamond::#{dir.classify}"
  eval <<-DEFINE
    module #{module_name}; end
    def (#{module_name}).const_missing(class_name)
      VersatileDiamond.const_missing(class_name, '#{dir}')
    end
  DEFINE
end

def Object.const_missing(class_name)
  VersatileDiamond.const_missing(class_name)
end

require_each 'lib/**/*.rb'
