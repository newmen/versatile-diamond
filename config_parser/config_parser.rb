require 'forwardable'
require 'singleton'
require 'set'

def files_in(path)
  Dir["#{__dir__}/#{path}"]
end

def require_each(path)
  files_in(path).each { |filename| require filename }
end

def find_file(filename, *pathes)
  pathes.each do |path|
    files_in("#{path}/**/*.rb").each do |full_path|
      return full_path if File.basename(full_path) == "#{filename}.rb"
    end
  end
  nil
end

AUTO_LOADING_DIRS = [
  'components', # analyzer components: interpreters and concepts
  'mcs', # algorithms for searching maximal common substructure
  'visitors', # visitors of final components tree
]

require_each 'lib/patches/*.rb' # same as monkey's patches
using VersatileDiamond::RichString

# trap for autoloading
def VersatileDiamond.const_missing(class_name)
  filename = class_name.to_s.underscore
  path = find_file(filename, *AUTO_LOADING_DIRS.map { |dir| "lib/#{dir}" })
  if path
    require path
    component = const_get(class_name)
    return component if component
  end
  raise "#{class_name} is not found"
end

# TODO: i don't want this trap
def Object.const_missing(class_name)
  VersatileDiamond.const_missing(class_name)
end

require 'i18n'
I18n.load_path << files_in('locales/*.yml')

require_each 'lib/modules/*.rb' # common modules
require_each 'lib/errors/*.rb' # using errors

require_relative 'lib/matcher.rb' # regexp matcher
require_relative 'lib/analyzer.rb' # general analyzer
