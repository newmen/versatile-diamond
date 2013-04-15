class String
  def underscore
    scan(/[A-Z][a-z0-9]*/).map(&:downcase).join('_')
  end
end

def Object.const_missing(class_name)
  filename = class_name.to_s.underscore
  require_relative "lib/components/#{filename}"
  component = const_get(class_name)
  raise "Component \"#{class_name}\" is not found" unless component
  component
end

Dir["#{__dir__}/lib/modules/*.rb"].each do |file|
  require_relative file
end

require_relative 'lib/analyzing_error.rb'
require_relative 'lib/analyzer.rb'

require 'i18n'
I18n.load_path << Dir["#{__dir__}/locales/*.yml"]
