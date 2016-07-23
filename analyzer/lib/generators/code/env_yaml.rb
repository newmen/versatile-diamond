module VersatileDiamond
  module Generators
    module Code

      # Creates yaml config file with information about macro parameters as
      # temperatures and concentrations of gas species
      class EnvYaml < YamlFile
        extend Forwardable

        def_delegators :code_class,
          :concentration_name, :gas_specs, :file_name, :template_name

        def_delegators :'VersatileDiamond::Tools::Config',
          :concentration_value, :gas_temperature_value, :surface_temperature_value

      end

    end
  end
end
