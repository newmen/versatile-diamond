module VersatileDiamond
  module Generators
    module Code

      # Creates Env class and yaml config file
      class Env < CppClassWithGen

        # Gets name of file which will be generated
        # @return [String] the name of result file without extention
        def file_name
          template_name
        end

        # Also generates yaml config file
        # @param [String] root_dir the generation directory
        # @override
        def generate(root_dir)
          super
          EnvYaml.new(self).generate(root_dir)
        end

        # Gets all used gas species
        # @return [Array] the array of used gas species
        def gas_species
          config_specs + @generator.specific_specs.select(&:gas?)
        end

        # Makes yaml concentration name for gas specie
        # @param [Concepts::SpecificSpec | Organizers::DependentSpecificSpec] gas_spec
        #   the gas specie for which name will generated
        # @return [String] the result name
        # @example generating name
        #   'hydrogen(h: *)' => 'HydrogenHs'
        def concentration_name(gas_spec)
          gas_spec.name.to_s.capitalize.
            gsub('*', 's').
            gsub(/(\w+):/) { |label| label.upcase }.
            gsub(/[\(\) :]/, '')
        end

        # Combine class scope with concentration method name
        # @param [Concepts::SpecificSpec | Organizers::DependentSpecificSpec] gas_spec
        #   see at #concentration_name same argument
        # @return [String] the concentration method name with class scope
        def full_concentration_method(gas_spec)
          "Env::#{concentration_method(gas_spec)}"
        end

      private

        # Gets the species from configuration tool
        # @return [Array] the array of gas concept species
        def config_specs
          Tools::Config.concs.keys
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