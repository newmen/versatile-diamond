require 'singleton'

using AtomSpecification # need to use it at surface_spec.rb

class Analizer
  include Singleton

  def self.analize(config)
    instance.instance_eval(config)
  end

  %w(
    elements
    gas
    surface
  ).each do |root|
    define_method(root) do |*args, &block|
      puts "analizing '#{root}'"
      constantize(root).new.instance_eval(*args, &block)
    end
  end

  private

  def constantize(root)
    klass = root.split('_').map(&:capitalize).join
    eval(klass)
  end
end
