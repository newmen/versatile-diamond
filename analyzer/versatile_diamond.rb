require 'pry'

require 'graphviz'

require 'forwardable'
require 'fileutils'
require 'pathname'
require 'digest'
require 'tsort'
require 'erb'
require 'set'
require 'i18n'
I18n.enforce_available_locales = true
I18n.load_path << files_in('locales/*.yml')

require_relative 'load_helper' # useful methods
require_each 'patches/*.rb' # same as monkey's patches
using VersatileDiamond::Patches::RichString

LIB_DIR = 'lib'
AUTO_LOADING_DIRS = Dir["#{__dir__}/#{LIB_DIR}/**/*.rb"].map do |dir|
  dir.sub(%r{\A.+?#{LIB_DIR}/}, "#{LIB_DIR}/").sub(%r{/\w+\.rb\Z}, '')
end.uniq - [LIB_DIR]

# Finds directory where stored file with name as passed
# @param [String] file_name for which the directory will be found
# @param [Array] patches where find will occure
# @return [String] the directory where file stored
def find_dir(file_name, pathes)
  pathes.each do |path|
    files_in("#{path}/**/*.rb").each do |full_path|
      match = full_path.match(%r{(#{LIB_DIR}/(?:\w+/)*)(\w+).rb\Z})
      if match[2] == file_name
        return match[1][0..-2]
      end
    end
  end
  nil
end

# Gets name of module that corresponds to passed dir
# @param [String] dir which will transformed to module name
# @return [String] the name of module
def module_name(dir)
  dir.sub(%r{\A#{LIB_DIR}/}, '').classify
end

# Finds class or module instance
# @param [Symbol] class_name which should be found
# @param [String] dir where class or module should be found
# @return [Module] the found class or module instance
def VersatileDiamond.const_missing(class_name, dir = nil)
  file_name = class_name.to_s.underscore
  dir ||= find_dir(file_name, AUTO_LOADING_DIRS)

  if dir
    require_relative "#{dir}/#{file_name}.rb"
    component = const_get("#{module_name(dir)}::#{class_name}")
    return component if component
  end

  raise "#{class_name} is not found (it's realy!)"
end

# Global hook for autoload classes and modules
# @param [Symbol] class_name which should be found
# @return [Module] the found class or module instance
def Object.const_missing(class_name)
  VersatileDiamond.const_missing(class_name)
end

# Defines all using modules which uses as namespaces
RSPEC_SUPPORT_DIR = 'spec/support'
AUTO_LOADING_DIRS.each do |dir|
  module_name = "VersatileDiamond::#{module_name(dir)}"
  support_module_name = "#{module_name}::Support"
  support_dir = dir.sub(%r{\A#{LIB_DIR}/}, "#{RSPEC_SUPPORT_DIR}/")

  eval <<-DEFINE
    module #{module_name}; end
    module #{support_module_name}; end

    def (#{module_name}).const_missing(class_name)
      VersatileDiamond.const_missing(class_name, '#{dir}')
    end

    def (#{support_module_name}).const_missing(class_name)
      VersatileDiamond.const_missing(class_name, '#{support_dir}')
    end
  DEFINE
end

require_each "#{LIB_DIR}/**/*.rb"
