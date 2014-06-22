module VersatileDiamond
  module Generators
    module Code

      # Creates Env class and yaml config file
      class Env < CppClassWithGen

        # Also generates yaml config file
        # @param [String] root_dir the generation directory
        # @override
        def generate(root_dir)
          super
          EnvYaml.new(self).generate(root_dir)
        end

        # Makes yaml concentration name for gas specie
        # @param [Concepts::SpecificSpec | Organizers::DependentSpecificSpec] gas_spec
        #   the gas specie for which name will generated
        # @return [String] the result name
        def concentration_name(gas_spec)
          @generator.specie_class(gas_spec).class_name
        end

        # Combine class scope with concentration method name
        # @param [Concepts::SpecificSpec | Organizers::DependentSpecificSpec] gas_spec
        #   see at #concentration_name same argument
        # @return [String] the concentration method name with class scope
        def full_concentration_method(gas_spec)
          "Env::#{concentration_method(gas_spec)}"
        end

      private

        # Gets all used gas species
        # @return [Array] the array of used gas species
        def gas_species
          @generator.specific_gas_species
        end

        # Makes the concentration method name
        # @param [Concepts::SpecificSpec | Organizers::DependentSpecificSpec] gas_spec
        #   see at #concentration_name same argument
        # @return [String] the concentration method name
        def concentration_method(gas_spec)
          "c#{concentration_name(gas_spec)}()"
        end
      end

    end
  end
end