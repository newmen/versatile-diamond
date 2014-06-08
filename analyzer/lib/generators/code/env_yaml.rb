module VersatileDiamond
  module Generators
    module Code

      # Creates yaml config file with information about macro parameters as
      # temperatures and concentrations of gas species
      class EnvYaml < YamlFile
        extend Forwardable

        def_delegators :@env_class, :concentration_name, :gas_species,
          :file_name, :template_name

        # Initialize configs/env.yml file generator
        # @param [Env] env_class the instance env class files generator
        def initialize(env_class)
          @env_class = env_class
        end

      private

        # Finds concenctration value for some spec
        # @param [Organizers::DependentSpecificSpec] spec for which concentration value
        #   will be found
        # @return [Float] the value of concentration
        def concentration_value(spec)
          _, value = Tools::Config.concs.find do |s, _|
            s.name == spec.name
          end
          value || 0
        end

        # Deligates temperature methods to configuration tool
        %w(gas surface).each do |phase|
          define_method(:"#{phase}_temperature") do
            Tools::Config.public_send(:"get_#{phase}_temperature")
          end
        end
      end

    end
  end
end