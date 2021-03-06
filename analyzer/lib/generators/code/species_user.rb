module VersatileDiamond
  module Generators
    module Code

      # Provides method for getting specie code class from generator
      module SpeciesUser
      private

        # Gets the specie class code generator
        # @param [Concepts::Spec | Concepts::SpecificSpec | Organizers::DependentSpec]
        #   spec for which the code generator will be got
        # @return [Specie] the correspond specie code generator
        def specie_class(spec)
          generator.specie_class(spec.name)
        end

        # Gets the list of specie class code generators
        # @param [Array] specs for which the code generators will be got
        # @return [Array] the correspond specie code generators
        def specie_classes(specs)
          specs.map(&method(:specie_class))
        end
      end

    end
  end
end
