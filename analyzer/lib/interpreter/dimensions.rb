module VersatileDiamond
  module Interpreter

    # Interpret dimensions block
    class Dimensions < Component
      Tools::Dimension::ALL_VARIABLES.each do |var|
        # Defines method for each dimension variable
        # @param [String] value the value of dimension
        define_method(var) do |value|
          Tools::Dimension.send("#{var}_dimension", value.strip)
        end
      end
    end

  end
end
