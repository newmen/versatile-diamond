def files_in(path)
  Dir["#{__dir__}/#{path}"]
end

def require_each(path)
  files_in(path).each { |filename| require filename }
end

def find_file(filename, *pathes)
  pathes.each do |path|
    files_in("#{path}/*.rb").each do |full_path|
      return full_path if File.basename(full_path) == "#{filename}.rb"
    end
  end
  nil
end

require 'i18n'
I18n.load_path << files_in('locales/*.yml')

require_each 'lib/patches/*.rb'
require_each 'lib/modules/*.rb'
require_each 'lib/visitors/*.rb'

require_relative 'lib/analyzing_error.rb'
require_relative 'lib/analysis_tool.rb'
require_relative 'lib/analyzer.rb'
require_relative 'lib/matcher.rb'

AUTO_LOADING_DIRS = ['components']

using RichString

def Object.const_missing(class_name)
  filename = class_name.to_s.underscore
  if (path = find_file(filename, *AUTO_LOADING_DIRS.map { |dir| "lib/#{dir}" }))
    require path
    component = const_get(class_name)
    return component if component
  end
  raise "#{class_name} is not found"
end
