module VersatileDiamond

  module Modules

    module BoundaryTemperature
      def current_temperature(gases_num)
        # TODO: unqualified access
        temperature = -> klass do
          klass.instance.instance_variable_get(:@temperature)
        end

        # TODO: !!!
        gases_num > 0 ? temperature[Gas] : temperature[Surface]
      end
    end

  end

end
