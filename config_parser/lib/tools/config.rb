module VersatileDiamond
  module Tools

    # Configuration singleton which contain params about calculaton runtime
    class Config
      class << self
        # Setup total calculation time
        # @param [Float] value the time value
        # @param [String] dimension of time value
        def total_time(value, dimension = nil)
          @total_time = Dimension.convert_time(value, dimension)
        end

        def concentration(specific_spec, value, dimension = nil)
          @concs ||= {}
          @concs[specific_spec] =
            Dimension.convert_concentration(value, dimension)
        end


        %w(gas surface).each do |type|
          name = "#{type}_temperature"
          define_method(name) do |value, dimension = nil|
            instance_variable_set(
              "@#{name}", Dimension.convert_termperature(value, dimension))
          end
        end
      end
    end

  end
end
