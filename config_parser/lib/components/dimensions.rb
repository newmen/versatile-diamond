class Dimensions < Component
  def initialize
    @temperature = nil
    @concentration = nil
    @energy = nil
    @rate = nil
    @time = nil
  end

  %w(temperature concentration energy rate time).each do |method_name|
    define_method(method_name) do |value|
      instance_variable_set("@#{method_name}".to_sym, value)
    end
  end
end
