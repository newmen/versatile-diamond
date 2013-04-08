def require_component(name)
  require_relative "lib/components/#{name}"
end

def Object.const_missing(name)
  filename = name.to_s.scan(/[A-Z][a-z0-9]*/).map(&:downcase).join('_')
  require_component(filename)
  component = const_get(name)
  return component if component
  raise "Component \"#{name}\" is not found"
end

Dir["#{__dir__}/lib/roots/*.rb"].each do |file|
  require_relative file
end

require_relative 'lib/analizer.rb'
