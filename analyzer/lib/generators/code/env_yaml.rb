module VersatileDiamond
  module Generators
    module Code

      # Creates yaml config file with information about macro parameters as
      # temperatures and concentrations of gas species
      class EnvYaml < YamlFile
        extend Forwardable

        def_delegators :@env_class, :concentration_name, :gas_species,
          :file_name, :template_name

        def_delegators :'VersatileDiamond::Tools::Config', :concentration_value,
          :gas_temperature_value, :surface_temperature_value

        # Initialize configs/env.yml file generator
        # @param [Env] env_class the instance env class files generator
        def initialize(env_class)
          @env_class = env_class
        end
      end

    end
  end
end