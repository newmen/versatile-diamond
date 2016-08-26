module VersatileDiamond
  module Generators
    module Code

      # Creates yaml file with run configuration
      class RunYaml < YamlFile

        # @return [Array]
        def atom_types
          code_class.atom_properties.map.with_index { |ap, i| [i, ap.to_s] }
        end

        # @return [String]
        def template_name
          'run'
        end
        alias :file_name :template_name
      end

    end
  end
end
