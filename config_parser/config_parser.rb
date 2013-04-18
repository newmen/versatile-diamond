def files_in(path)
  Dir["#{__dir__}/#{path}"]
end

require 'i18n'
I18n.load_path << files_in('locales/*.yml')

files_in('lib/patches/*.rb').each { |filename| require filename }
files_in('lib/modules/*.rb').each { |filename| require filename }

using RichString

def Object.const_missing(class_name)
  filename = class_name.to_s.underscore
  require_relative "lib/components/#{filename}"
  component = const_get(class_name)
  raise "Component \"#{class_name}\" is not found" unless component
  component
end

require_relative 'lib/analyzing_error.rb'
require_relative 'lib/analyzer.rb'
require_relative 'lib/matcher.rb'
